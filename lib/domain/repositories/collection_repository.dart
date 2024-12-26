import 'dart:convert';
import 'dart:io';
import 'dart:math' show pow;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nft_marketplace_mobile/core/services/pinata_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_storage_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:web3dart/web3dart.dart';

class CollectionRepository {
  final Web3Client _client;
  final DeployedContract _contract;
  final PinataService _pinataService;
  final EthereumAddress _marketplaceAddress;
  final WalletService _walletService;
  final WalletStorageService _storageService;

  CollectionRepository._({
    required Web3Client client,
    required String marketplaceAddress,
    required DeployedContract contract,
    required PinataService pinataService,
    required WalletService walletService,
    required WalletStorageService storageService,
  })  : _client = client,
        _contract = contract,
        _pinataService = pinataService,
        _marketplaceAddress = EthereumAddress.fromHex(marketplaceAddress),
        _walletService = walletService,
        _storageService = storageService;

  static Future<CollectionRepository> create({
    required Web3Client client,
    required String marketplaceAddress,
    required PinataService pinataService,
    required WalletService walletService,
    required WalletStorageService storageService,
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
      walletService: walletService,
      storageService: storageService,
    );
  }

  Future<List<Collection>> fetchCollections() async {
    try {
      final function = _contract.function('fetchCollections');

      // Add error handling for the contract call
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Contract call timeout'),
      );

      if (result.isEmpty) return [];

      debugPrint('Raw contract result: $result');

      final collectionsData = result[0] as List<dynamic>;
      final collections = <Collection>[];

      for (var data in collectionsData) {
        try {
          if (data is List && data.length >= 2) {
            // Ensure we have both basic info and details
            final collection = Collection.fromContract(data);
            collections.add(collection);
          } else {
            debugPrint('Invalid collection data structure: $data');
          }
        } catch (e) {
          debugPrint('Error parsing collection: $e');
          debugPrint('Problematic data: $data');
          // Continue to next item instead of failing completely
          continue;
        }
      }

      return collections;
    } catch (e) {
      if (e.toString().contains('Value not in range')) {
        debugPrint(
            'Contract data format mismatch. Ensuring proper ABI and data structure.');
        // You might want to implement a retry mechanism here
        return [];
      }
      debugPrint('Error fetching collections: $e');
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

  Future<List<Collection>> fetchCreatedCollections() async {
    try {
      if (!_walletService.isConnected) {
        throw Exception('Wallet not connected');
      }

      final function = _contract.function('fetchUserCreatedCollections');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [_walletService.address],
      );

      if (result.isEmpty) return [];

      final collectionsData = result[0] as List<dynamic>;
      return collectionsData
          .map((data) => Collection.fromContract(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching created collections: $e');
      rethrow;
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final function = _contract.function('getCategories');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );

      if (result.isEmpty) return [];

      final categories = (result[0] as List<dynamic>).cast<String>();
      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<List<Collection>> fetchCollectionsByCategory(String category) async {
    try {
      final function = _contract.function('fetchCollectionsByCategory');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [category],
      );

      if (result.isEmpty) return [];

      final collections = (result[0] as List<dynamic>)
          .map((data) => Collection.fromContract(data))
          .toList();

      return collections;
    } catch (e) {
      debugPrint('Error fetching collections by category: $e');
      rethrow;
    }
  }

  Future<List<Collection>> searchCollections({
    required String searchTerm,
    String? category,
    double? minFloorPrice,
    double? maxFloorPrice,
  }) async {
    try {
      final function = _contract.function('searchCollectionsWithFilters');

      // Convert floor prices to Wei
      final minPriceWei = minFloorPrice != null
          ? BigInt.from(minFloorPrice * pow(10, 18))
          : BigInt.zero;
      final maxPriceWei = maxFloorPrice != null
          ? BigInt.from(maxFloorPrice * pow(10, 18))
          : BigInt.zero;

      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [
          searchTerm,
          category ?? '',
          minPriceWei,
          maxPriceWei,
        ],
      );

      if (result.isEmpty) return [];

      final searchResults = result[0] as List<dynamic>;
      final collections = <Collection>[];

      for (var data in searchResults) {
        try {
          // Convert the search result to collection format
          final collection = Collection(
            address: (data[0] as EthereumAddress).hex,
            name: data[1] as String,
            symbol: data[2] as String,
            category: data[3] as String,
            owner: '', // Search results don't include owner
            isActive: data[6] as bool,
            createdAt:
                DateTime.now(), // Search results don't include creation date
            baseURI: '', // Search results don't include baseURI
            totalSupply: (data[4] as BigInt).toInt(),
            floorPrice: data[5] as BigInt,
            totalVolume: BigInt.zero, // Search results don't include volume
            ownerCount: 0, // Search results don't include owner count
          );
          collections.add(collection);
        } catch (e) {
          debugPrint('Error parsing collection from search: $e');
          continue;
        }
      }

      return collections;
    } catch (e) {
      debugPrint('Error searching collections: $e');
      rethrow;
    }
  }
}
