part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileDisconnected extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String walletAddress;
  final double balance;
  final ProfileStats stats;
  final List<MarketItem> collectedNfts;
  final List<Collection> createdCollections;

  const ProfileLoaded({
    required this.walletAddress,
    required this.balance,
    required this.stats,
    required this.collectedNfts,
    required this.createdCollections,
  });

  @override
  List<Object> get props => [
        walletAddress,
        balance,
        stats,
        collectedNfts,
        createdCollections,
      ];

  ProfileLoaded copyWith({
    String? walletAddress,
    double? balance,
    ProfileStats? stats,
    List<MarketItem>? collectedNfts,
    List<Collection>? createdCollections,
  }) {
    return ProfileLoaded(
      walletAddress: walletAddress ?? this.walletAddress,
      balance: balance ?? this.balance,
      stats: stats ?? this.stats,
      collectedNfts: collectedNfts ?? this.collectedNfts,
      createdCollections: createdCollections ?? this.createdCollections,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class AddressCopied extends ProfileState {
  final ProfileLoaded currentState;

  const AddressCopied(this.currentState);

  @override
  List<Object> get props => [currentState];
}
