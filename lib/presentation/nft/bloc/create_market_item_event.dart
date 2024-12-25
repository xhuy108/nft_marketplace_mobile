part of 'create_market_item_bloc.dart';

sealed class CreateMarketItemEvent extends Equatable {
  const CreateMarketItemEvent();

  @override
  List<Object> get props => [];
}

class CreateMarketItemSubmitted extends CreateMarketItemEvent {
  final String name;
  final String description;
  final Collection collection;
  final File imageFile;
  final BigInt price;
  final Credentials credentials;

  const CreateMarketItemSubmitted({
    required this.name,
    required this.description,
    required this.collection,
    required this.imageFile,
    required this.price,
    required this.credentials,
  });

  @override
  List<Object> get props => [name, description, collection, imageFile, price];
}
