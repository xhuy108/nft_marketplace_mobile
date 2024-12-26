import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/repositories/market_item_repository.dart';
import 'package:web3dart/web3dart.dart';

part 'create_market_item_event.dart';
part 'create_market_item_state.dart';

class CreateMarketItemBloc
    extends Bloc<CreateMarketItemEvent, CreateMarketItemState> {
  final MarketItemRepository repository;

  CreateMarketItemBloc({
    required this.repository,
  }) : super(CreateMarketItemInitial()) {
    on<CreateMarketItemSubmitted>(_onCreateMarketItemSubmitted);
    on<PurchaseMarketItem>(_onPurchaseMarketItem);
  }

  Future<void> _onCreateMarketItemSubmitted(
    CreateMarketItemSubmitted event,
    Emitter<CreateMarketItemState> emit,
  ) async {
    try {
      emit(CreateMarketItemLoading(message: 'Uploading media to IPFS...'));

      // Upload image to IPFS
      final imageUri = await repository.uploadImage(event.imageFile);

      emit(CreateMarketItemLoading(message: 'Creating metadata...'));

      // Create and upload metadata
      final metadata = {
        'name': event.name,
        'description': event.description,
        'image': imageUri,
      };
      final metadataUri = await repository.uploadMetadata(metadata);

      emit(CreateMarketItemLoading(message: 'Creating market item...'));

      print('credentials: ${event.credentials.address}');

      // Create market item
      final tokenId = await repository.createMarketItem(
        collectionAddress: event.collection.address,
        tokenURI: metadataUri,
        price: event.price,
        credentials: event.credentials,
      );

      emit(CreateMarketItemSuccess(tokenId: tokenId));
    } catch (e) {
      emit(CreateMarketItemFailure(message: e.toString()));
    }
  }

  Future<void> _onPurchaseMarketItem(
    PurchaseMarketItem event,
    Emitter<CreateMarketItemState> emit,
  ) async {
    try {
      emit(const PurchaseMarketItemLoading());

      await repository.purchaseMarketItem(
        collectionAddress: event.collectionAddress,
        tokenId: event.tokenId,
        price: event.price,
        credentials: event.credentials,
      );

      emit(const PurchaseMarketItemSuccess());
    } catch (e) {
      emit(PurchaseMarketItemFailure(e.toString()));
    }
  }
}
