part of 'collection_items_bloc.dart';

sealed class CollectionItemsState extends Equatable {
  const CollectionItemsState();

  @override
  List<Object> get props => [];
}

class CollectionItemsInitial extends CollectionItemsState {}

class CollectionItemsLoading extends CollectionItemsState {}

class CollectionItemsLoaded extends CollectionItemsState {
  final List<MarketItem> items;

  const CollectionItemsLoaded({required this.items});

  @override
  List<Object> get props => [items];
}

class CollectionItemsError extends CollectionItemsState {
  final String message;

  const CollectionItemsError({required this.message});

  @override
  List<Object> get props => [message];
}
