part of 'collection_bloc.dart';

sealed class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object> get props => [];
}

class LoadCollections extends CollectionEvent {}

class UpdateTimeFilter extends CollectionEvent {
  final String filter;

  const UpdateTimeFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class UpdateChainFilter extends CollectionEvent {
  final String filter;

  const UpdateChainFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class UpdateCategoryFilter extends CollectionEvent {
  final String filter;

  const UpdateCategoryFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class LoadUserCollections extends CollectionEvent {}

class LoadCategories extends CollectionEvent {}

class FilterCollectionsByCategory extends CollectionEvent {
  final String category;

  const FilterCollectionsByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class SearchCollections extends CollectionEvent {
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
