import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nft_marketplace_mobile/domain/entities/nft_collection.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';

part 'search_collection_event.dart';
part 'search_collection_state.dart';

class SearchCollectionBloc
    extends Bloc<SearchCollectionEvent, SearchCollectionState> {
  final CollectionRepository repository;

  SearchCollectionBloc({required this.repository})
      : super(SearchCollectionInitial()) {
    on<SearchCollections>(_onSearchCollections);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchCollections(
    SearchCollections event,
    Emitter<SearchCollectionState> emit,
  ) async {
    try {
      emit(SearchCollectionLoading());

      final results = await repository.searchCollections(
        searchTerm: event.searchTerm,
        category: event.category,
        minFloorPrice: event.minFloorPrice,
        maxFloorPrice: event.maxFloorPrice,
      );

      emit(SearchCollectionSuccess(
        collections: results,
        searchTerm: event.searchTerm,
      ));
    } catch (e) {
      emit(SearchCollectionError(e.toString()));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchCollectionState> emit,
  ) {
    emit(SearchCollectionInitial());
  }
}
