// models/collection.dart
import 'package:equatable/equatable.dart';
import 'package:web3dart/web3dart.dart';

class Collection extends Equatable {
  static const String IPFS_GATEWAY = "https://ipfs.io/ipfs/";

  final String address;
  final String name;
  final String symbol;
  final String category;
  final String owner;
  final bool isActive;
  final DateTime createdAt;
  final String baseURI;
  final int totalSupply;

  // Statistics
  final BigInt floorPrice;
  final BigInt totalVolume;
  final int ownerCount;

  // Computed properties for UI
  String? get image {
    if (baseURI.isEmpty) return null;

    if (baseURI.startsWith('ipfs://')) {
      // Convert IPFS URI to HTTP URL
      final ipfsHash = baseURI.replaceFirst('ipfs://', '');
      return '$IPFS_GATEWAY$ipfsHash';
    }

    return baseURI;
  }

  String get floor => floorPrice != BigInt.zero
      ? '${EtherAmount.fromBigInt(EtherUnit.wei, floorPrice).getValueInUnit(EtherUnit.ether)}'
      : '0';

  String get volume => totalVolume != BigInt.zero
      ? EtherAmount.fromBigInt(EtherUnit.wei, totalVolume)
          .getValueInUnit(EtherUnit.ether)
          .toStringAsFixed(2)
      : '0';

  double get changePercentage => 0; // You can add this data later if needed

  const Collection({
    required this.address,
    required this.name,
    required this.symbol,
    required this.category,
    required this.owner,
    required this.isActive,
    required this.createdAt,
    required this.baseURI,
    required this.totalSupply,
    required this.floorPrice,
    required this.totalVolume,
    required this.ownerCount,
  });

  factory Collection.fromContract(List<dynamic> data) {
    try {
      if (data is! List) {
        throw FormatException('Data must be a List');
      }

      // Extract basic collection data
      final basic = data[0] as List<dynamic>;

      return Collection(
        address: (basic[0] as EthereumAddress).hex,
        name: basic[1] as String,
        symbol: basic[2] as String,
        category: basic[3] as String,
        owner: (basic[4] as EthereumAddress).hex,
        isActive: basic[5] as bool,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (basic[6] as BigInt).toInt() * 1000,
        ),
        baseURI: basic[7] as String,
        totalSupply: (basic[8] as BigInt).toInt(),

        // Extract statistics from CollectionDetails
        floorPrice: data[1] as BigInt,
        totalVolume: data[2] as BigInt,
        ownerCount: (data[3] as BigInt).toInt(),
      );
    } catch (e, stackTrace) {
      print('Error parsing collection: $e');
      print('Stack trace: $stackTrace');
      print('Data structure: ${data.runtimeType}');
      print('Data content: $data');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [
        address,
        name,
        symbol,
        category,
        owner,
        isActive,
        createdAt,
        baseURI,
        totalSupply,
        floorPrice,
        totalVolume,
        ownerCount,
      ];
}
