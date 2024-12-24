import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
      // Start loading state
      emit(const CreateCollectionLoading(
        message: 'Uploading image to IPFS...',
      ));

      // Create collection with all required data
      final collectionAddress = await repository.createCollection(
        name: event.name,
        symbol: event.symbol,
        imageFile: event.imageFile,
        category: event.category,
        credentials: event.credentials,
      );

      // Get the collection details to verify creation
      final collection =
          await repository.getCollectionDetails(collectionAddress);

      emit(CreateCollectionSuccess(
        collectionAddress: collectionAddress,
        imageUrl: '',
        metadataUrl: '',
      ));
    } catch (e, stackTrace) {
      String userMessage = 'Failed to create collection';

      if (e.toString().contains('insufficient funds')) {
        userMessage = 'Insufficient funds to create collection';
      } else if (e.toString().contains('user rejected')) {
        userMessage = 'Transaction was rejected';
      } else if (e.toString().contains('network error')) {
        userMessage = 'Network error occurred. Please try again';
      }

      emit(CreateCollectionFailure(
        userMessage,
        technicalDetails: '$e\n$stackTrace',
      ));
    }
  }
}
