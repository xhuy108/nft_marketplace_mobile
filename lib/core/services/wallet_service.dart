// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

class WalletService {
  // final FlutterSecureStorage _storage;
  final Web3Client _web3client;

  Credentials? _credentials;
  EthereumAddress? _address;

  WalletService({
    // FlutterSecureStorage? storage,
    required Web3Client web3client,
  }) : _web3client = web3client;

  Future<void> initializeFromPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      _credentials = credentials;
      _address = await credentials.extractAddress();

      // Store private key securely
      // await _storage.write(
      //   key: 'private_key',
      //   value: privateKey,
      // );
    } catch (e) {
      throw Exception('Failed to initialize wallet: $e');
    }
  }

  Future<void> initializeFromStoredKey() async {
    try {
      // final privateKey = await _storage.read(key: 'private_key');
      // if (privateKey != null) {
      //   await initializeFromPrivateKey(privateKey);
      // }
    } catch (e) {
      throw Exception('Failed to initialize wallet from stored key: $e');
    }
  }

  Future<bool> isWalletInitialized() async {
    // final privateKey = await _storage.read(key: 'private_key');
    return true;
  }

  Credentials get credentials {
    if (_credentials == null) {
      throw Exception('Wallet not initialized');
    }
    return _credentials!;
  }

  EthereumAddress get address {
    if (_address == null) {
      throw Exception('Wallet not initialized');
    }
    return _address!;
  }

  Future<double> getBalance() async {
    try {
      if (_address == null) throw Exception('Wallet not initialized');

      final balance = await _web3client.getBalance(_address!);
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  Future<void> clearWallet() async {
    // await _storage.delete(key: 'private_key');
    _credentials = null;
    _address = null;
  }
}
