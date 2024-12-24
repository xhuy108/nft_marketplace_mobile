part of 'create_collection_bloc.dart';

sealed class CreateCollectionEvent extends Equatable {
  const CreateCollectionEvent();

  @override
  List<Object> get props => [];
}

class CreateCollectionSubmitted extends CreateCollectionEvent {
  final String name;
  final String symbol;
  final String category;
  final File imageFile;
  final Credentials credentials;

  const CreateCollectionSubmitted({
    required this.name,
    required this.symbol,
    required this.category,
    required this.imageFile,
    required this.credentials,
  });

  @override
  List<Object> get props => [name, symbol, category, imageFile];
}
