part of 'collection_bloc.dart';

sealed class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object> get props => [];
}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CategoriesLoaded extends CollectionState {
  final List<String> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

class CollectionLoaded extends CollectionState {
  final List<Collection> collections;
  final List<Collection> filteredCollections;
  final String selectedTimeFilter;
  final String selectedChainFilter;
  final String selectedCategoryFilter;

  const CollectionLoaded({
    required this.collections,
    List<Collection>? filteredCollections,
    this.selectedTimeFilter = '24h',
    this.selectedChainFilter = 'All chains',
    this.selectedCategoryFilter = 'All categories',
  }) : filteredCollections = filteredCollections ?? collections;

  @override
  List<Object> get props => [
        collections,
        filteredCollections,
        selectedTimeFilter,
        selectedChainFilter,
        selectedCategoryFilter,
      ];

  CollectionLoaded copyWith({
    List<Collection>? collections,
    List<Collection>? filteredCollections,
    String? selectedTimeFilter,
    String? selectedChainFilter,
    String? selectedCategoryFilter,
  }) {
    return CollectionLoaded(
      collections: collections ?? this.collections,
      filteredCollections: filteredCollections ?? this.filteredCollections,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
      selectedChainFilter: selectedChainFilter ?? this.selectedChainFilter,
      selectedCategoryFilter:
          selectedCategoryFilter ?? this.selectedCategoryFilter,
    );
  }
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object> get props => [message];
}

class UserCollectionsLoaded extends CollectionState {
  final List<Collection> collections;

  const UserCollectionsLoaded({required this.collections});

  @override
  List<Object> get props => [collections];
}

class CollectionSearchLoading extends CollectionState {}

class CollectionSearchLoaded extends CollectionState {
  final List<Collection> searchResults;
  final String searchTerm;

  const CollectionSearchLoaded({
    required this.searchResults,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [searchResults, searchTerm];
}

class CollectionSearchError extends CollectionState {
  final String message;

  const CollectionSearchError(this.message);

  @override
  List<Object> get props => [message];
}
