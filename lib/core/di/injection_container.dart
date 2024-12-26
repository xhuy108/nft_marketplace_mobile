import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nft_marketplace_mobile/config/env_config.dart';
import 'package:nft_marketplace_mobile/core/services/pinata_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_service.dart';
import 'package:nft_marketplace_mobile/core/services/wallet_storage_service.dart';
import 'package:nft_marketplace_mobile/domain/repositories/collection_repository.dart';
import 'package:nft_marketplace_mobile/domain/repositories/market_item_repository.dart';
import 'package:nft_marketplace_mobile/domain/repositories/profile_repository.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_bloc/collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/collection_items_bloc/collection_items_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/create_collection_bloc/create_collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/user_collection_bloc/user_collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/nft/bloc/create_market_item_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/search/bloc/search_collection_bloc.dart';
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
    web3client: web3Client,
  );

  final walletStorageService = await WalletStorageService.create();
  getIt.registerSingleton<WalletStorageService>(walletStorageService);

  // Optionally initialize with a default private key from .env
  final defaultPrivateKey = dotenv.env['ETHEREUM_PRIVATE_KEY'];
  if (defaultPrivateKey != null) {
    await walletService.connectWithPrivateKey(defaultPrivateKey);
  }

  getIt.registerSingleton<WalletService>(
    WalletService(web3client: getIt<Web3Client>()),
  );

  // Initialize PinataService
  getIt.registerSingleton<PinataService>(PinataService());

  // Update CollectionRepository registration
  final collectionRepository = await CollectionRepository.create(
    client: getIt<Web3Client>(),
    marketplaceAddress: EnvConfig.marketplaceAddress,
    pinataService: getIt<PinataService>(),
    walletService: getIt<WalletService>(),
    storageService: getIt<WalletStorageService>(),
  );

  getIt.registerSingleton<CollectionRepository>(collectionRepository);

  // Add other repositories here
  // getIt.registerSingleton<AnotherRepository>(AnotherRepository());

  // BLoCs
  getIt.registerFactory<CollectionBloc>(
    () => CollectionBloc(
      repository: getIt<CollectionRepository>(),
    ),
  );

  // Add to initializeDependencies()
  getIt.registerFactory<CreateCollectionBloc>(
    () => CreateCollectionBloc(repository: getIt<CollectionRepository>()),
  );

  getIt.registerFactory<CollectionItemsBloc>(
    () => CollectionItemsBloc(repository: getIt<CollectionRepository>()),
  );

  getIt.registerFactory<UserCollectionBloc>(
    () => UserCollectionBloc(repository: getIt<CollectionRepository>()),
  );

  final marketItemRepository = await MarketItemRepository.create(
    client: getIt<Web3Client>(),
    marketplaceAddress: EnvConfig.marketplaceAddress,
    pinataService: getIt<PinataService>(),
  );

  getIt.registerSingleton<MarketItemRepository>(marketItemRepository);

  getIt.registerFactory<CreateMarketItemBloc>(
    () => CreateMarketItemBloc(repository: getIt<MarketItemRepository>()),
  );

  // Update ProfileBloc registration
  final profileRepository = await ProfileRepository.create(
    walletService: getIt<WalletService>(),
    storageService: getIt<WalletStorageService>(),
    web3client: getIt<Web3Client>(),
    marketplaceAddress: EnvConfig.marketplaceAddress,
  );
  getIt.registerSingleton<ProfileRepository>(profileRepository);

  // Register ProfileBloc
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(repository: getIt<ProfileRepository>()),
  );

  getIt.registerFactory<SearchCollectionBloc>(
    () => SearchCollectionBloc(repository: getIt<CollectionRepository>()),
  );

  // Add other blocs here
  // getIt.registerFactory<AnotherBloc>(
  //   () => AnotherBloc(repository: getIt<AnotherRepository>()),
  // );
}
