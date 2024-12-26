// lib/domain/repositories/profile_repository.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_storage_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/entities/profile_stats.dart';

class ProfileRepository {
  final WalletService _walletService;
  final WalletStorageService _storageService;
  final Web3Client _web3client;
  final DeployedContract _marketplaceContract;

  ProfileRepository._({
    required WalletService walletService,
    required WalletStorageService storageService,
    required Web3Client web3client,
    required DeployedContract marketplaceContract,
  })  : _walletService = walletService,
        _storageService = storageService,
        _web3client = web3client,
        _marketplaceContract = marketplaceContract;

  static Future<ProfileRepository> create({
    required WalletService walletService,
    required WalletStorageService storageService,
    required Web3Client web3client,
    required String marketplaceAddress,
  }) async {
    final abiString =
        await rootBundle.loadString('assets/contracts/NFTMarketplace.json');
    final abiJson = jsonDecode(abiString);
    final abi = abiJson['abi'] as List<dynamic>;

    final contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'NFTMarketplace'),
      EthereumAddress.fromHex(marketplaceAddress),
    );

    return ProfileRepository._(
      walletService: walletService,
      storageService: storageService,
      web3client: web3client,
      marketplaceContract: contract,
    );
  }

  Future<void> connectWallet(String privateKey) async {
    try {
      await _walletService.connectWithPrivateKey(privateKey);
      await _storageService.savePrivateKey(privateKey);
    } catch (e) {
      debugPrint('Error connecting wallet: $e');
      rethrow;
    }
  }

  Future<void> disconnectWallet() async {
    try {
      _walletService.disconnect();
      await _storageService.clearPrivateKey();
    } catch (e) {
      debugPrint('Error disconnecting wallet: $e');
      rethrow;
    }
  }

  Future<void> copyAddressToClipboard(String address) async {
    try {
      await Clipboard.setData(ClipboardData(text: address));
    } catch (e) {
      debugPrint('Error copying address: $e');
      rethrow;
    }
  }

  Future<String?> getStoredPrivateKey() async {
    return _storageService.getPrivateKey();
  }

  Future<List<MarketItem>> fetchCollectedNFTs() async {
    try {
      if (!_walletService.isConnected) {
        throw Exception('Wallet not connected');
      }

      final function = _marketplaceContract.function('fetchUserPurchasedItems');
      final result = await _web3client.call(
        contract: _marketplaceContract,
        function: function,
        params: [_walletService.address],
      );

      if (result.isEmpty) return [];

      final itemsData = result[0] as List<dynamic>;
      final items =
          itemsData.map((data) => MarketItem.fromContract(data)).toList();

      // Load metadata for each item
      await Future.wait(items.map((item) => item.loadMetadata()));

      return items;
    } catch (e) {
      debugPrint('Error fetching collected NFTs: $e');
      rethrow;
    }
  }

  Future<List<Collection>> fetchCreatedCollections() async {
    try {
      if (!_walletService.isConnected) {
        throw Exception('Wallet not connected');
      }

      final function =
          _marketplaceContract.function('fetchUserCreatedCollections');
      final result = await _web3client.call(
        contract: _marketplaceContract,
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

  Future<double> getAccountBalance() async {
    try {
      if (!_walletService.isConnected) {
        throw Exception('Wallet not connected');
      }
      return await _walletService.getBalance();
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      rethrow;
    }
  }

  String? getConnectedAddress() =>
      _walletService.isConnected ? _walletService.addressHex : null;
  bool isConnected() => _walletService.isConnected;

  Future<ProfileStats> calculateProfileStats({
    required List<MarketItem> collectedNfts,
    required List<Collection> createdCollections,
  }) async {
    try {
      if (!_walletService.isConnected) {
        throw Exception('Wallet not connected');
      }

      // Calculate total value of all collected NFTs
      double totalValue = 0;
      for (var nft in collectedNfts) {
        totalValue += EtherAmount.fromBigInt(EtherUnit.wei, nft.price)
            .getValueInUnit(EtherUnit.ether);
      }

      return ProfileStats(
        collected: collectedNfts.length,
        created: createdCollections.length,
        totalValue: totalValue,
      );
    } catch (e) {
      debugPrint('Error calculating profile stats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      if (!_walletService.isConnected) {
        throw Exception('Wallet not connected');
      }

      // Fetch all data in parallel
      final results = await Future.wait([
        getAccountBalance(),
        fetchCollectedNFTs(),
        fetchCreatedCollections(),
      ]);

      final balance = results[0] as double;
      final collectedNfts = results[1] as List<MarketItem>;
      final createdCollections = results[2] as List<Collection>;

      // Calculate stats
      final stats = await calculateProfileStats(
        collectedNfts: collectedNfts,
        createdCollections: createdCollections,
      );

      return {
        'balance': balance,
        'collectedNfts': collectedNfts,
        'createdCollections': createdCollections,
        'stats': stats,
      };
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      rethrow;
    }
  }
}
