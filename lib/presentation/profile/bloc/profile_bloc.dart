import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_storage_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/entities/profile_stats.dart';
import 'package:nft_marketplace_mobile/domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ConnectWallet>(_onConnectWallet);
    on<DisconnectWallet>(_onDisconnectWallet);
    on<CopyWalletAddress>(_onCopyWalletAddress);
    on<RefreshProfile>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      // Check for stored private key
      final privateKey = await _repository.getStoredPrivateKey();
      if (privateKey == null) {
        emit(ProfileDisconnected());
        return;
      }

      // Connect wallet with stored private key
      await _repository.connectWallet(privateKey);
      await _loadProfileData(emit);
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onConnectWallet(
    ConnectWallet event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      await _repository.connectWallet(event.privateKey);
      await _loadProfileData(emit);
    } catch (e) {
      emit(const ProfileError(
          'Failed to connect wallet. Please check your private key and try again.'));
    }
  }

  Future<void> _onDisconnectWallet(
    DisconnectWallet event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      await _repository.disconnectWallet();
      emit(ProfileDisconnected());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      await _loadProfileData(emit);
    }
  }

  Future<void> _loadProfileData(Emitter<ProfileState> emit) async {
    try {
      if (!_repository.isConnected()) {
        emit(ProfileDisconnected());
        return;
      }

      final address = _repository.getConnectedAddress()!;
      final profileData = await _repository.fetchProfileData();

      emit(ProfileLoaded(
        walletAddress: address,
        balance: profileData['balance'] as double,
        stats: profileData['stats'] as ProfileStats,
        collectedNfts: profileData['collectedNfts'] as List<MarketItem>,
        createdCollections:
            profileData['createdCollections'] as List<Collection>,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onCopyWalletAddress(
    CopyWalletAddress event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      try {
        await _repository.copyAddressToClipboard(event.address);

        // Emit AddressCopied state with current ProfileLoaded state
        final currentState = state as ProfileLoaded;
        emit(AddressCopied(currentState));

        // Re-emit the current state to maintain UI
        emit(currentState);
      } catch (e) {
        emit(ProfileError('Failed to copy address'));
        // Re-emit the previous state to maintain UI
        if (state is ProfileLoaded) {
          emit(state);
        }
      }
    }
  }
}
