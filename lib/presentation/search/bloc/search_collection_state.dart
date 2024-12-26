part of 'search_collection_bloc.dart';

sealed class SearchCollectionState extends Equatable {
  const SearchCollectionState();

  @override
  List<Object> get props => [];
}

class SearchCollectionInitial extends SearchCollectionState {}

class SearchCollectionLoading extends SearchCollectionState {}

class SearchCollectionSuccess extends SearchCollectionState {
  final List<Collection> collections;
  final String searchTerm;

  const SearchCollectionSuccess({
    required this.collections,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [collections, searchTerm];
}

class SearchCollectionError extends SearchCollectionState {
  final String message;

  const SearchCollectionError(this.message);

  @override
  List<Object> get props => [message];
}
