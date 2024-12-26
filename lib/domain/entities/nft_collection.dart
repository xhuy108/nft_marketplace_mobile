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
  final BigInt floorPrice;
  final BigInt totalVolume;
  final int ownerCount;

  String? get image {
    if (baseURI.isEmpty) return null;

    if (baseURI.startsWith('ipfs://')) {
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

  double get changePercentage => 0;

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
      if (data.length < 2) {
        throw FormatException('Invalid data structure: insufficient elements');
      }

      final basic = data[0] as List<dynamic>;
      if (basic.length < 9) {
        throw FormatException('Invalid basic data structure');
      }

      return Collection(
        address: (basic[0] as EthereumAddress).hex,
        name: basic[1] as String? ?? '',
        symbol: basic[2] as String? ?? '',
        category: basic[3] as String? ?? '',
        owner: (basic[4] as EthereumAddress).hex,
        isActive: basic[5] as bool? ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          ((basic[6] as BigInt?) ?? BigInt.zero).toInt() * 1000,
        ),
        baseURI: basic[7] as String? ?? '',
        totalSupply: ((basic[8] as BigInt?) ?? BigInt.zero).toInt(),
        floorPrice: (data[1] as BigInt?) ?? BigInt.zero,
        totalVolume: (data[2] as BigInt?) ?? BigInt.zero,
        ownerCount: ((data[3] as BigInt?) ?? BigInt.zero).toInt(),
      );
    } catch (e) {
      print('Error parsing collection: $e');
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
