import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get ethereumRpcUrl => dotenv.env['ETHEREUM_RPC_URL'] ?? '';
  static String get marketplaceAddress =>
      dotenv.env['MARKETPLACE_ADDRESS'] ?? '';
}
