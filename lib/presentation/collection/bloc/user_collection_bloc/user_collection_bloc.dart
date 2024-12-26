import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_bloc/collection_bloc.dart';

class UserCollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CollectionRepository repository;

  UserCollectionBloc({
    required this.repository,
  }) : super(CollectionInitial()) {
    on<LoadUserCollections>(_onLoadUserCollections);
  }

  Future<void> _onLoadUserCollections(
    LoadUserCollections event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(CollectionLoading());
      final collections = await repository.fetchCreatedCollections();
      emit(UserCollectionsLoaded(collections: collections));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }
}
