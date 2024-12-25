import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nft_marketplace_mobile/domain/entities/market_item.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';

part 'collection_items_event.dart';
part 'collection_items_state.dart';

class CollectionItemsBloc
    extends Bloc<CollectionItemsEvent, CollectionItemsState> {
  final CollectionRepository repository;

  CollectionItemsBloc({required this.repository})
      : super(CollectionItemsInitial()) {
    on<LoadCollectionItems>(_onLoadCollectionItems);
  }

  Future<void> _onLoadCollectionItems(
    LoadCollectionItems event,
    Emitter<CollectionItemsState> emit,
  ) async {
    try {
      emit(CollectionItemsLoading());

      // Fetch items from the contract
      final items =
          await repository.fetchCollectionItems(event.collectionAddress);

      // Load metadata for each item
      final itemsWithMetadata = await Future.wait(
        items.map((item) async {
          await item.loadMetadata();
          return item;
        }),
      );

      emit(CollectionItemsLoaded(items: itemsWithMetadata));
    } catch (e) {
      emit(CollectionItemsError(message: e.toString()));
    }
  }
}
