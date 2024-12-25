part of 'collection_items_bloc.dart';

sealed class CollectionItemsEvent extends Equatable {
  const CollectionItemsEvent();

  @override
  List<Object> get props => [];
}

class LoadCollectionItems extends CollectionItemsEvent {
  final String collectionAddress;

  const LoadCollectionItems({required this.collectionAddress});

  @override
  List<Object> get props => [collectionAddress];
}
