part of 'search_collection_bloc.dart';

sealed class SearchCollectionEvent extends Equatable {
  const SearchCollectionEvent();

  @override
  List<Object> get props => [];
}

class SearchCollections extends SearchCollectionEvent {
  final String searchTerm;
  final String? category;
  final double? minFloorPrice;
  final double? maxFloorPrice;

  const SearchCollections({
    required this.searchTerm,
    this.category,
    this.minFloorPrice,
    this.maxFloorPrice,
  });

  @override
  List<Object> get props =>
      [searchTerm, category ?? '', minFloorPrice ?? 0, maxFloorPrice ?? 0];
}

class ClearSearch extends SearchCollectionEvent {}
