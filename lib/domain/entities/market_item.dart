// lib/domain/entities/market_item.dart
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'token_metadata.dart';

class MarketItem extends Equatable {
  static const String IPFS_GATEWAY = "https://ipfs.io/ipfs/";

  final BigInt tokenId;
  final String nftContract;
  final String seller;
  final String owner;
  final BigInt price;
  final bool isOnSale;
  final BigInt auctionEndTime;
  final String highestBidder;
  final BigInt highestBid;
  final bool isAuction;
  final String tokenURI;
  TokenMetadata? metadata;

  MarketItem({
    required this.tokenId,
    required this.nftContract,
    required this.seller,
    required this.owner,
    required this.price,
    required this.isOnSale,
    required this.auctionEndTime,
    required this.highestBidder,
    required this.highestBid,
    required this.isAuction,
    required this.tokenURI,
    this.metadata,
  });

  // Getter for formatted price
  String get formattedPrice => EtherAmount.fromBigInt(EtherUnit.wei, price)
      .getValueInUnit(EtherUnit.ether)
      .toStringAsFixed(4);

  String get metadataUrl {
    if (tokenURI.startsWith('ipfs://')) {
      final ipfsHash = tokenURI.replaceFirst('ipfs://', '');
      return '$IPFS_GATEWAY$ipfsHash';
    }
    return tokenURI;
  }

  Future<void> loadMetadata() async {
    if (metadata != null) return;

    try {
      final response = await http.get(Uri.parse(metadataUrl));
      if (response.statusCode == 200) {
        metadata = TokenMetadata.fromJsonString(response.body);
      }
    } catch (e) {
      print('Error loading metadata: $e');
    }
  }

  factory MarketItem.fromContract(List<dynamic> data) {
    return MarketItem(
      tokenId: data[0] as BigInt,
      nftContract: (data[1] as EthereumAddress).hex,
      seller: (data[2] as EthereumAddress).hex,
      owner: (data[3] as EthereumAddress).hex,
      price: data[4] as BigInt,
      isOnSale: data[5] as bool,
      auctionEndTime: data[6] as BigInt,
      highestBidder: (data[7] as EthereumAddress).hex,
      highestBid: data[8] as BigInt,
      isAuction: data[9] as bool,
      tokenURI: data[10] as String, // Added tokenURI from contract
    );
  }

  MarketItem copyWith({TokenMetadata? metadata}) {
    return MarketItem(
      tokenId: tokenId,
      nftContract: nftContract,
      seller: seller,
      owner: owner,
      price: price,
      isOnSale: isOnSale,
      auctionEndTime: auctionEndTime,
      highestBidder: highestBidder,
      highestBid: highestBid,
      isAuction: isAuction,
      tokenURI: tokenURI,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        tokenId,
        nftContract,
        seller,
        owner,
        price,
        isOnSale,
        auctionEndTime,
        highestBidder,
        highestBid,
        isAuction,
        tokenURI,
        metadata,
      ];
}
