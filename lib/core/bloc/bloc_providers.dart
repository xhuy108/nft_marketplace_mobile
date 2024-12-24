import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nft_marketplace_mobile/presentation/collection/bloc/create_collection_bloc/create_collection_bloc.dart';
import 'package:nft_marketplace_mobile/presentation/collection/pages/create_collection_page.dart';

import '../../presentation/collection/bloc/collection_bloc/collection_bloc.dart';

class BlocProviders extends StatelessWidget {
  final Widget child;

  const BlocProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CollectionBloc>(
          create: (context) => GetIt.instance<CollectionBloc>(),
        ),
        BlocProvider(
          create: (context) => GetIt.instance<CreateCollectionBloc>(),
        ),
        // Add other BlocProviders here
        // BlocProvider<AnotherBloc>(
        //   create: (context) => GetIt.instance<AnotherBloc>(),
        // ),
      ],
      child: child,
    );
  }
}
