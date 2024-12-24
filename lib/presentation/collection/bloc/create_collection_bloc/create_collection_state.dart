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
  final String collectionAddress;
  final String imageUrl;
  final String metadataUrl;

  const CreateCollectionSuccess({
    required this.collectionAddress,
    required this.imageUrl,
    required this.metadataUrl,
  });

  @override
  List<Object> get props => [collectionAddress, imageUrl, metadataUrl];
}

class CreateCollectionFailure extends CreateCollectionState {
  final String error;
  final String? technicalDetails;

  const CreateCollectionFailure(
    this.error, {
    this.technicalDetails,
  });

  @override
  List<Object> get props => [error, technicalDetails ?? ''];
}
