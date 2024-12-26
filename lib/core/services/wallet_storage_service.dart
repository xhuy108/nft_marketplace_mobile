// lib/core/services/wallet_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class WalletStorageService {
  static const String _privateKeyKey = 'private_key';
  final SharedPreferences _prefs;

  WalletStorageService({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  static Future<WalletStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WalletStorageService(prefs: prefs);
  }

  Future<void> savePrivateKey(String privateKey) async {
    await _prefs.setString(_privateKeyKey, privateKey);
  }

  String? getPrivateKey() {
    return _prefs.getString(_privateKeyKey);
  }

  Future<void> clearPrivateKey() async {
    await _prefs.remove(_privateKeyKey);
  }

  bool hasPrivateKey() {
    final key = getPrivateKey();
    return key != null && key.isNotEmpty;
  }
}
