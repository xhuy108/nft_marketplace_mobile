part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

class ConnectWallet extends ProfileEvent {
  final String privateKey;

  const ConnectWallet({required this.privateKey});

  @override
  List<Object> get props => [privateKey];
}

class DisconnectWallet extends ProfileEvent {}

class CopyWalletAddress extends ProfileEvent {
  final String address;

  const CopyWalletAddress(this.address);

  @override
  List<Object> get props => [address];
}

class RefreshProfile extends ProfileEvent {}
