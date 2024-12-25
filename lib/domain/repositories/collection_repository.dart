import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nft_marketplace_mobile/core/services/pinata_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
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
      debugPrint('Uploading image to IPFS...');
      final imageUri = await _pinataService.uploadImage(imageFile);
      debugPrint('Image uploaded: $imageUri');

      // Create metadata JSON
      final metadata = {
        'name': name,
        'symbol': symbol,
        'image': imageUri,
        'description': 'NFT Collection',
      };

      // Upload metadata to IPFS
      debugPrint('Uploading metadata to IPFS...');
      // final baseUri = await _pinataService.uploadJson(metadata);
      // debugPrint('Metadata uploaded: $baseUri');

      // Get contract function
      final function = _contract.function('createCollection');

      // Log function parameters
      debugPrint('Creating collection with params:');
      debugPrint('Name: $name');
      debugPrint('Symbol: $symbol');
      debugPrint('BaseURI: $imageUri');
      debugPrint('Category: $category');

      // Create transaction
      final transaction = Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [name, symbol, imageUri, category],
      );

      // Send transaction
      debugPrint('Sending transaction...');
      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 31337,
      );
      debugPrint('Transaction sent: $txHash');

      // Wait for transaction receipt
      debugPrint('Waiting for transaction receipt...');
      final receipt = await _client.getTransactionReceipt(txHash);
      if (receipt == null) {
        // If receipt is null, wait a bit and try again
        await Future.delayed(const Duration(seconds: 2));
        final retryReceipt = await _client.getTransactionReceipt(txHash);
        if (retryReceipt == null) {
          throw Exception(
              'Transaction failed: No receipt received after retry');
        }
        debugPrint(
            'Transaction mined after retry: ${retryReceipt.transactionHash}');

        // Parse CollectionCreated event from retry receipt
        final collectionCreatedEvent = _contract.event('CollectionCreated');
        final events = retryReceipt.logs
            .map((log) {
              try {
                return collectionCreatedEvent.decodeResults(
                  log.topics ?? [],
                  log.data ?? '',
                );
              } catch (e) {
                debugPrint('Failed to decode event: $e');
                return null;
              }
            })
            .where((event) => event != null && event.isNotEmpty)
            .toList();

        if (events.isEmpty) {
          throw Exception(
              'Collection creation event not found in transaction logs');
        }

        // Get collection address from event
        final collectionAddress = (events.first![0] as EthereumAddress).hex;
        debugPrint('Collection created at: $collectionAddress');
        return collectionAddress;
      }

      debugPrint('Transaction mined: ${receipt.transactionHash}');

      // Parse CollectionCreated event
      final collectionCreatedEvent = _contract.event('CollectionCreated');
      final events = receipt.logs
          .map((log) {
            try {
              return collectionCreatedEvent.decodeResults(
                log.topics ?? [],
                log.data ?? '',
              );
            } catch (e) {
              debugPrint('Failed to decode event: $e');
              return null;
            }
          })
          .where((event) => event != null && event.isNotEmpty)
          .toList();

      if (events.isEmpty) {
        throw Exception(
            'Collection creation event not found in transaction logs');
      }

      // Get collection address from event
      final collectionAddress = (events.first![0] as EthereumAddress).hex;
      debugPrint('Collection created at: $collectionAddress');
      return collectionAddress;
    } catch (e, stackTrace) {
      debugPrint('Error creating collection: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get available categories
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

  Future<List<MarketItem>> fetchCollectionItems(
      String collectionAddress) async {
    try {
      final function = _contract.function('fetchCollectionItems');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [EthereumAddress.fromHex(collectionAddress)],
      );

      if (result.isEmpty) return [];

      final itemsData = result[0] as List<dynamic>;

      return itemsData.map((data) => MarketItem.fromContract(data)).toList();
    } catch (e, stackTrace) {
      debugPrint('Error fetching collection items: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
