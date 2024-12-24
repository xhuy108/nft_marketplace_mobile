import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nft_marketplace_mobile/core/services/pinata_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:web3dart/web3dart.dart';

class CollectionRepository {
  final Web3Client _client;
  final DeployedContract _contract;
  final PinataService _pinataService;
  final EthereumAddress _marketplaceAddress;

  CollectionRepository._({
    required Web3Client client,
    required String marketplaceAddress,
    required DeployedContract contract,
    required PinataService pinataService,
  })  : _client = client,
        _contract = contract,
        _pinataService = pinataService,
        _marketplaceAddress = EthereumAddress.fromHex(marketplaceAddress);

  static Future<CollectionRepository> create({
    required Web3Client client,
    required String marketplaceAddress,
    required PinataService pinataService,
  }) async {
    final abiString =
        await rootBundle.loadString('assets/contracts/NFTMarketplace.json');
    final abiJson = jsonDecode(abiString);
    final abi = abiJson['abi'] as List<dynamic>;

    final contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'NFTMarketplace'),
      EthereumAddress.fromHex(marketplaceAddress),
    );

    return CollectionRepository._(
      client: client,
      marketplaceAddress: marketplaceAddress,
      contract: contract,
      pinataService: pinataService,
    );
  }

  Future<List<Collection>> fetchCollections() async {
    try {
      final function = _contract.function('fetchCollections');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );

      if (result.isEmpty) return [];

      debugPrint('Raw contract result: $result');

      final collectionsData = result[0] as List<dynamic>;

      final collections = collectionsData
          .map((data) {
            try {
              return Collection.fromContract(data);
            } catch (e) {
              print('Error parsing collection data: $e');
              print('Problematic data: $data');
              return null;
            }
          })
          .whereType<Collection>()
          .toList();

      return collections;
    } catch (e, stackTrace) {
      print('Error fetching collections: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Collection> getCollectionDetails(String collectionAddress) async {
    try {
      final function = _contract.function('fetchCollectionDetails');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [EthereumAddress.fromHex(collectionAddress)],
      );

      if (result.isEmpty) {
        throw Exception('No collection details found');
      }

      return Collection.fromContract(result[0]);
    } catch (e, stackTrace) {
      print('Error fetching collection details: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> createCollection({
    required String name,
    required String symbol,
    required File imageFile,
    required String category,
    required Credentials credentials,
  }) async {
    try {
      // Upload image to IPFS
      final imageUri = await _pinataService.uploadImage(imageFile);

      // Create metadata JSON
      final metadata = {
        'name': name,
        'symbol': symbol,
        'image': imageUri,
        'category': category,
      };

      // Upload metadata to IPFS
      final metadataUri = await _pinataService.uploadJson(metadata);

      final function = _contract.function('createCollection');

      // Prepare the transaction
      final transaction = Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          name,
          symbol,
          metadataUri, // Use the metadata URI as baseURI
          category,
        ],
      );

      // Send the transaction
      final result = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: null, // Add your chain ID if required
      );

      // Wait for transaction receipt
      final receipt = await _client.getTransactionReceipt(result);
      if (receipt == null) {
        throw Exception('Transaction failed');
      }

      // Parse the CollectionCreated event
      final events = receipt.logs
          .map((log) => _contract
              .event('CollectionCreated')
              .decodeResults(log.topics ?? [], log.data ?? ''))
          .where((event) => event.isNotEmpty)
          .toList();

      if (events.isEmpty) {
        throw Exception('Collection creation event not found');
      }

      final collectionAddress = (events.first[0] as EthereumAddress).hex;
      return collectionAddress;
    } catch (e) {
      debugPrint('Error creating collection: $e');
      rethrow;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final function = _contract.function('getCategories');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );

      return (result[0] as List<dynamic>).cast<String>();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  // Helper method to estimate gas for collection creation
  Future<BigInt> estimateGasForCollectionCreation({
    required String name,
    required String symbol,
    required String baseURI,
    required String category,
    required EthereumAddress sender,
  }) async {
    try {
      final function = _contract.function('createCollection');

      final transaction = Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [name, symbol, baseURI, category],
        from: sender,
      );

      final estimatedGas = await _client.estimateGas(
        sender: sender,
        to: _marketplaceAddress,
        data: transaction.data,
      );

      return estimatedGas;
    } catch (e) {
      debugPrint('Error estimating gas: $e');
      rethrow;
    }
  }
}
