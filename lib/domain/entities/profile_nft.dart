import 'package:equatable/equatable.dart';

class ProfileNFT extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String collectionName;
  final String ownerAddress;
  final bool isListed;
  final double price;
  final String tokenId;
  final String contractAddress;

  const ProfileNFT({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.collectionName,
    required this.ownerAddress,
    required this.isListed,
    required this.price,
    required this.tokenId,
    required this.contractAddress,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        collectionName,
        ownerAddress,
        isListed,
        price,
        tokenId,
        contractAddress,
      ];

  ProfileNFT copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? collectionName,
    String? ownerAddress,
    bool? isListed,
    double? price,
    String? tokenId,
    String? contractAddress,
  }) {
    return ProfileNFT(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      collectionName: collectionName ?? this.collectionName,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      isListed: isListed ?? this.isListed,
      price: price ?? this.price,
      tokenId: tokenId ?? this.tokenId,
      contractAddress: contractAddress ?? this.contractAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'collectionName': collectionName,
      'ownerAddress': ownerAddress,
      'isListed': isListed,
      'price': price,
      'tokenId': tokenId,
      'contractAddress': contractAddress,
    };
  }

  factory ProfileNFT.fromJson(Map<String, dynamic> json) {
    return ProfileNFT(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      collectionName: json['collectionName'] as String,
      ownerAddress: json['ownerAddress'] as String,
      isListed: json['isListed'] as bool,
      price: (json['price'] as num).toDouble(),
      tokenId: json['tokenId'] as String,
      contractAddress: json['contractAddress'] as String,
    );
  }

  static List<ProfileNFT> getDummyData() {
    return [
      ProfileNFT(
        id: '1',
        name: 'Memories of Digital D...',
        imageUrl: 'assets/images/memories.jpg',
        collectionName: 'Digital Dreams',
        ownerAddress: '0x1234...5678',
        isListed: true,
        price: 0.0055,
        tokenId: '1',
        contractAddress: '0x1234...5678',
      ),
      ProfileNFT(
        id: '2',
        name: 'Memories of Digital D...',
        imageUrl: 'assets/images/memories.jpg',
        collectionName: 'Digital Dreams',
        ownerAddress: '0x1234...5678',
        isListed: true,
        price: 0.0055,
        tokenId: '2',
        contractAddress: '0x1234...5678',
      ),
      // Add more dummy data as needed
    ];
  }
}
