import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';
import 'package:nft_marketplace_mobile/domain/repositories/profile_repository.dart';

part 'collection_event.dart';
part 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CollectionRepository repository;

  CollectionBloc({
    required this.repository,
  }) : super(CollectionInitial()) {
    on<LoadCollections>(_onLoadCollections);
    on<UpdateTimeFilter>(_onUpdateTimeFilter);
    on<UpdateChainFilter>(_onUpdateChainFilter);
    on<UpdateCategoryFilter>(_onUpdateCategoryFilter);
    on<LoadUserCollections>(_onLoadUserCollections);
    on<FilterCollectionsByCategory>(_onFilterCollectionsByCategory);
  }

  void _onFilterCollectionsByCategory(
    FilterCollectionsByCategory event,
    Emitter<CollectionState> emit,
  ) {
    if (state is CollectionLoaded) {
      final currentState = state as CollectionLoaded;

      try {
        if (event.category == 'All categories') {
          emit(currentState.copyWith(
            filteredCollections: currentState.collections,
            selectedCategoryFilter: event.category,
          ));
        } else {
          final filteredCollections = currentState.collections
              .where((collection) => collection.category == event.category)
              .toList();

          emit(currentState.copyWith(
            filteredCollections: filteredCollections,
            selectedCategoryFilter: event.category,
          ));
        }
      } catch (e) {
        emit(CollectionError(e.toString()));
      }
    }
  }

  Future<void> _onLoadUserCollections(
    LoadUserCollections event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(CollectionLoading());

      // Get user created collections from the profile repository
      final collections = await repository.fetchCreatedCollections();
      emit(UserCollectionsLoaded(collections: collections));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }

  Future<void> _onLoadCollections(
    LoadCollections event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      emit(CollectionLoading());
      final collections = await repository.fetchCollections();
      emit(CollectionLoaded(
        collections: collections,
        filteredCollections: collections,
      ));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }

  void _onUpdateTimeFilter(
    UpdateTimeFilter event,
    Emitter<CollectionState> emit,
  ) {
    if (state is CollectionLoaded) {
      final currentState = state as CollectionLoaded;
      emit(currentState.copyWith(selectedTimeFilter: event.filter));
    }
  }

  void _onUpdateChainFilter(
    UpdateChainFilter event,
    Emitter<CollectionState> emit,
  ) {
    if (state is CollectionLoaded) {
      final currentState = state as CollectionLoaded;
      emit(currentState.copyWith(selectedChainFilter: event.filter));
    }
  }

  void _onUpdateCategoryFilter(
    UpdateCategoryFilter event,
    Emitter<CollectionState> emit,
  ) {
    if (state is CollectionLoaded) {
      final currentState = state as CollectionLoaded;
      emit(currentState.copyWith(selectedCategoryFilter: event.filter));
    }
  }
}
