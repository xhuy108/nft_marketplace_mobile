import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:nft_marketplace_mobile/core/services/pinata_service.dart';
import 'package:web3dart/web3dart.dart';

class MarketItemRepository {
  final Web3Client _client;
  final DeployedContract _marketplaceContract;
  final PinataService _pinataService;

  MarketItemRepository._({
    required Web3Client client,
    required DeployedContract marketplaceContract,
    required PinataService pinataService,
  })  : _client = client,
        _marketplaceContract = marketplaceContract,
        _pinataService = pinataService;

  static Future<MarketItemRepository> create({
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

    return MarketItemRepository._(
      client: client,
      marketplaceContract: contract,
      pinataService: pinataService,
    );
  }

  Future<String> uploadImage(File imageFile) async {
    return _pinataService.uploadImage(imageFile);
  }

  Future<String> uploadMetadata(Map<String, dynamic> metadata) async {
    return _pinataService.uploadJson(metadata);
  }

  Future<void> purchaseMarketItem({
    required String collectionAddress,
    required BigInt tokenId,
    required BigInt price,
    required Credentials credentials,
  }) async {
    try {
      // Get contract function
      final function = _marketplaceContract.function('createMarketSale');

      // Create transaction
      final transaction = Transaction.callContract(
        contract: _marketplaceContract,
        function: function,
        parameters: [
          EthereumAddress.fromHex(collectionAddress),
          tokenId,
        ],
        value: EtherAmount.fromBigInt(EtherUnit.wei, price),
      );

      // Send transaction
      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 31337, // Your network chain ID
      );

      // Wait for transaction receipt
      final receipt = await _client.getTransactionReceipt(txHash);
      if (receipt == null) {
        throw Exception('Purchase transaction failed: No receipt received');
      }

      // Verify the transaction was successful
      if (!receipt.status!) {
        throw Exception('Purchase transaction failed');
      }
    } catch (e) {
      throw Exception('Failed to purchase market item: $e');
    }
  }

  Future<BigInt> createMarketItem({
    required String collectionAddress,
    required String tokenURI,
    required BigInt price,
    required Credentials credentials,
  }) async {
    try {
      // First mint the NFT in the collection
      final nftAbiString =
          await rootBundle.loadString('assets/contracts/NFTCollection.json');
      final nftAbiJson = jsonDecode(nftAbiString);
      final nftAbi = nftAbiJson['abi'] as List<dynamic>;

      final nftContract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(nftAbi), 'NFTCollection'),
        EthereumAddress.fromHex(collectionAddress),
      );

      // Mint NFT
      final mintFunction = nftContract.function('mint');

      final mintData = mintFunction.encodeCall([
        EthereumAddress.fromHex(credentials.address.hex),
        tokenURI,
      ]);

      final mintTx = await _client.sendTransaction(
        credentials,
        Transaction(
          to: nftContract.address,
          data: mintData,
          maxGas: 500000,
        ),
        chainId: 31337,
      );

      // Wait for mint transaction
      final mintReceipt = await _client.getTransactionReceipt(mintTx);
      if (mintReceipt == null) {
        throw Exception('Mint transaction failed');
      }

      // Get tokenId from mint event
      final mintEvent = mintReceipt.logs
          .map((log) => nftContract
              .event('Transfer')
              .decodeResults(log.topics ?? [], log.data ?? ''))
          .where((decoded) => decoded.isNotEmpty)
          .first;

      final tokenId = mintEvent[2] as BigInt; // TokenId is the third parameter

      // Approve marketplace
      final approveFunction = nftContract.function('approve');
      final approveData = approveFunction.encodeCall([
        _marketplaceContract.address,
        tokenId,
      ]);

      final approveTx = await _client.sendTransaction(
        credentials,
        Transaction(
          to: nftContract.address,
          data: approveData,
          maxGas: 100000,
        ),
        chainId: 31337,
      );

      // Wait for approval
      final approveReceipt = await _client.getTransactionReceipt(approveTx);
      if (approveReceipt == null) {
        throw Exception('Approve transaction failed');
      }

      // Get listing fee
      final listingFeeFunction = _marketplaceContract.function('listingFee');
      final listingFeeResult = await _client.call(
        contract: _marketplaceContract,
        function: listingFeeFunction,
        params: [],
      );
      final listingFee = listingFeeResult[0] as BigInt;

      // Create market item
      final createMarketItemFunction =
          _marketplaceContract.function('createMarketItem');
      final createMarketItemData = createMarketItemFunction.encodeCall([
        EthereumAddress.fromHex(collectionAddress),
        tokenId,
        price,
      ]);

      final createItemTx = await _client.sendTransaction(
        credentials,
        Transaction(
          to: _marketplaceContract.address,
          value: EtherAmount.fromBigInt(EtherUnit.wei, listingFee),
          data: createMarketItemData,
          maxGas: 500000,
        ),
        chainId: 31337,
      );

      // Wait for market item creation
      final createItemReceipt =
          await _client.getTransactionReceipt(createItemTx);
      if (createItemReceipt == null) {
        throw Exception('Create market item transaction failed');
      }

      return tokenId;
    } catch (e) {
      throw Exception('Failed to create market item: $e');
    }
  }
}
