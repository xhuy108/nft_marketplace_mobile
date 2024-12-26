import 'package:equatable/equatable.dart';

class ProfileStats extends Equatable {
  final int collected; // Number of NFTs collected
  final int created; // Number of collections created
  final double totalValue; // Total value of NFTs in ETH

  const ProfileStats({
    required this.collected,
    required this.created,
    required this.totalValue,
  });

  factory ProfileStats.empty() {
    return const ProfileStats(
      collected: 0,
      created: 0,
      totalValue: 0.0,
    );
  }

  @override
  List<Object?> get props => [collected, created, totalValue];

  ProfileStats copyWith({
    int? collected,
    int? created,
    double? totalValue,
  }) {
    return ProfileStats(
      collected: collected ?? this.collected,
      created: created ?? this.created,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}
