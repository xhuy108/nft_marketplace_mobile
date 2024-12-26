import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:web3dart/web3dart.dart';

class NFTItem {
  final String name;
  final String image;
  final BigInt price;
  final String collectionName;
  final String tokenId;
  final String collectionAddress;
  final String seller;
  final String owner;
  final bool isOnSale;
  final String? description;

  NFTItem({
    required this.name,
    required this.image,
    required this.price,
    required this.collectionName,
    required this.tokenId,
    required this.collectionAddress,
    required this.seller,
    required this.owner,
    required this.isOnSale,
    this.description,
  });

  factory NFTItem.fromMarketItem(MarketItem item, String collectionName) {
    return NFTItem(
      name: item.metadata?.name ?? '#${item.tokenId}',
      image: item.metadata?.imageUrl ?? 'assets/images/placeholder.png',
      price: item.price,
      collectionName: collectionName,
      tokenId: item.tokenId.toString(),
      collectionAddress: item.nftContract,
      seller: item.seller,
      owner: item.owner,
      isOnSale: item.isOnSale,
      description: item.metadata?.description,
    );
  }

  // Format price in ETH
  String get formattedPrice =>
      '${EtherAmount.fromBigInt(EtherUnit.wei, price).getValueInUnit(EtherUnit.ether)} ETH';

  // Check if the item is owned by an address
  bool isOwnedBy(String address) {
    return owner.toLowerCase() == address.toLowerCase();
  }

  // Check if the item is being sold by an address
  bool isBeingSoldBy(String address) {
    return seller.toLowerCase() == address.toLowerCase();
  }

  // Creates a copy of the item with updated fields
  NFTItem copyWith({
    String? name,
    String? image,
    BigInt? price,
    String? collectionName,
    String? tokenId,
    String? collectionAddress,
    String? seller,
    String? owner,
    bool? isOnSale,
    String? description,
  }) {
    return NFTItem(
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      collectionName: collectionName ?? this.collectionName,
      tokenId: tokenId ?? this.tokenId,
      collectionAddress: collectionAddress ?? this.collectionAddress,
      seller: seller ?? this.seller,
      owner: owner ?? this.owner,
      isOnSale: isOnSale ?? this.isOnSale,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NFTItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          image == other.image &&
          price == other.price &&
          collectionName == other.collectionName &&
          tokenId == other.tokenId &&
          collectionAddress == other.collectionAddress &&
          seller == other.seller &&
          owner == other.owner &&
          isOnSale == other.isOnSale &&
          description == other.description;

  @override
  int get hashCode =>
      name.hashCode ^
      image.hashCode ^
      price.hashCode ^
      collectionName.hashCode ^
      tokenId.hashCode ^
      collectionAddress.hashCode ^
      seller.hashCode ^
      owner.hashCode ^
      isOnSale.hashCode ^
      description.hashCode;

  @override
  String toString() {
    return 'NFTItem(name: $name, image: $image, price: $price, collectionName: $collectionName, '
        'tokenId: $tokenId, collectionAddress: $collectionAddress, seller: $seller, '
        'owner: $owner, isOnSale: $isOnSale, description: $description)';
  }
}
