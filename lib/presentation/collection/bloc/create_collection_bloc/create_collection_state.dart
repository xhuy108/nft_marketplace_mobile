part of 'create_collection_bloc.dart';

sealed class CreateCollectionState extends Equatable {
  const CreateCollectionState();

  @override
  List<Object> get props => [];
}

class CreateCollectionInitial extends CreateCollectionState {}

class CreateCollectionLoading extends CreateCollectionState {
  final String message;

  const CreateCollectionLoading({
    this.message = 'Creating collection...',
  });

  @override
  List<Object> get props => [message];
}

class CreateCollectionSuccess extends CreateCollectionState {
  final Collection collection;

  const CreateCollectionSuccess(this.collection);

  @override
  List<Object> get props => [collection];
}

class CreateCollectionFailure extends CreateCollectionState {
  final String message;

  const CreateCollectionFailure(this.message);

  @override
  List<Object> get props => [message];
}
