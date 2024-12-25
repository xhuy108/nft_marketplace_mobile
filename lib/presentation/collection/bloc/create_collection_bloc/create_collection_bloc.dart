import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';
import 'package:web3dart/web3dart.dart';

part 'create_collection_event.dart';
part 'create_collection_state.dart';

class CreateCollectionBloc
    extends Bloc<CreateCollectionEvent, CreateCollectionState> {
  final CollectionRepository repository;

  CreateCollectionBloc({
    required this.repository,
  }) : super(CreateCollectionInitial()) {
    on<CreateCollectionSubmitted>(_onCreateCollectionSubmitted);
  }

  Future<void> _onCreateCollectionSubmitted(
    CreateCollectionSubmitted event,
    Emitter<CreateCollectionState> emit,
  ) async {
    try {
      emit(
          const CreateCollectionLoading(message: 'Uploading image to IPFS...'));

      final collectionAddress = await repository.createCollection(
        name: event.name,
        symbol: event.symbol,
        imageFile: event.imageFile,
        category: event.category,
        credentials: event.credentials,
      );

      print(collectionAddress);

      emit(const CreateCollectionLoading(
          message: 'Fetching collection details...'));

      final collection =
          await repository.getCollectionDetails(collectionAddress);
      emit(CreateCollectionSuccess(collection));
    } catch (e) {
      String errorMessage = 'Failed to create collection';

      if (e.toString().contains('insufficient funds')) {
        errorMessage = 'Insufficient funds to create collection';
      } else if (e.toString().contains('user rejected')) {
        errorMessage = 'Transaction was rejected';
      } else if (e.toString().contains('network error')) {
        errorMessage = 'Network error occurred. Please try again';
      }

      emit(CreateCollectionFailure(errorMessage));
    }
  }
}
