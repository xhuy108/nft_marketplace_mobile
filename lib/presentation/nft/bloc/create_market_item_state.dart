part of 'create_market_item_bloc.dart';

sealed class CreateMarketItemState extends Equatable {
  const CreateMarketItemState();

  @override
  List<Object> get props => [];
}

class CreateMarketItemInitial extends CreateMarketItemState {}

class CreateMarketItemLoading extends CreateMarketItemState {
  final String message;

  const CreateMarketItemLoading({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateMarketItemSuccess extends CreateMarketItemState {
  final BigInt tokenId;

  const CreateMarketItemSuccess({required this.tokenId});

  @override
  List<Object> get props => [tokenId];
}

class CreateMarketItemFailure extends CreateMarketItemState {
  final String message;

  const CreateMarketItemFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class PurchaseMarketItemLoading extends CreateMarketItemState {
  const PurchaseMarketItemLoading();
}

class PurchaseMarketItemSuccess extends CreateMarketItemState {
  const PurchaseMarketItemSuccess();
}

class PurchaseMarketItemFailure extends CreateMarketItemState {
  final String message;

  const PurchaseMarketItemFailure(this.message);

  @override
  List<Object> get props => [message];
}
