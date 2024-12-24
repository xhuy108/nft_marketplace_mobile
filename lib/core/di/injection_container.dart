import 'package:nft_marketplace_mobile/config/env_config.dart';
import 'package:nft_marketplace_mobile/core/services/pinata_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_bloc/collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/create_collection_bloc/create_collection_bloc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core
  final web3Client = Web3Client(
    EnvConfig.ethereumRpcUrl,
    Client(),
  );
  getIt.registerSingleton<Web3Client>(web3Client);

  // Repositories
  // Initialize WalletService
  final walletService = WalletService(
    web3client: getIt<Web3Client>(),
  );
  await walletService.initializeFromStoredKey();
  getIt.registerSingleton<WalletService>(walletService);

  // Initialize PinataService
  getIt.registerSingleton<PinataService>(PinataService());

  // Update CollectionRepository registration
  final collectionRepository = await CollectionRepository.create(
    client: getIt<Web3Client>(),
    marketplaceAddress: EnvConfig.marketplaceAddress,
    pinataService: getIt<PinataService>(),
  );
  getIt.registerSingleton<CollectionRepository>(collectionRepository);

  // Add other repositories here
  // getIt.registerSingleton<AnotherRepository>(AnotherRepository());

  // BLoCs
  getIt.registerFactory<CollectionBloc>(
    () => CollectionBloc(repository: getIt<CollectionRepository>()),
  );

  // Add to initializeDependencies()
  getIt.registerFactory<CreateCollectionBloc>(
    () => CreateCollectionBloc(repository: getIt<CollectionRepository>()),
  );

  // Add other blocs here
  // getIt.registerFactory<AnotherBloc>(
  //   () => AnotherBloc(repository: getIt<AnotherRepository>()),
  // );
}
