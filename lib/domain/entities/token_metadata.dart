// lib/domain/entities/token_metadata.dart
import 'dart:convert';
import 'package:equatable/equatable.dart';

class TokenMetadata extends Equatable {
  final String name;
  final String symbol;
  final String image;
  final String description;

  static const String IPFS_GATEWAY = "https://ipfs.io/ipfs/";

  const TokenMetadata({
    required this.name,
    required this.symbol,
    required this.image,
    required this.description,
  });

  String get imageUrl {
    print("image: $image");
    if (image.startsWith('ipfs://')) {
      final ipfsHash = image.replaceFirst('ipfs://', '');
      return '$IPFS_GATEWAY$ipfsHash';
    }
    return image;
  }

  factory TokenMetadata.fromJson(Map<String, dynamic> json) {
    return TokenMetadata(
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  factory TokenMetadata.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return TokenMetadata.fromJson(json);
  }

  @override
  List<Object?> get props => [name, symbol, image, description];
}
