import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:nft_marketplace_mobile/config/themes/app_theme.dart';
import 'package:nft_marketplace_mobile/core/bloc/bloc_providers.dart';
import 'package:nft_marketplace_mobile/core/di/injection_container.dart';
import 'package:nft_marketplace_mobile/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Load environment variables
  await dotenv.load();

  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProviders(
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            home: child,
          );
        },
        child: MainScreen(),
      ),
    );
  }
}
