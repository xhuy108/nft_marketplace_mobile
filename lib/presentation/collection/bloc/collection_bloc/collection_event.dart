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
