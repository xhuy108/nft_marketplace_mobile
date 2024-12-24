part of 'collection_bloc.dart';

sealed class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object> get props => [];
}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionLoaded extends CollectionState {
  final List<Collection> collections;
  final String selectedTimeFilter;
  final String selectedChainFilter;
  final String selectedCategoryFilter;

  const CollectionLoaded({
    required this.collections,
    this.selectedTimeFilter = '24h',
    this.selectedChainFilter = 'All chains',
    this.selectedCategoryFilter = 'All categories',
  });

  @override
  List<Object> get props => [
        collections,
        selectedTimeFilter,
        selectedChainFilter,
        selectedCategoryFilter,
      ];

  CollectionLoaded copyWith({
    List<Collection>? collections,
    String? selectedTimeFilter,
    String? selectedChainFilter,
    String? selectedCategoryFilter,
  }) {
    return CollectionLoaded(
      collections: collections ?? this.collections,
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
