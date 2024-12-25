import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';

class WalletService {
  final Web3Client _web3client;
  Credentials? _credentials;
  EthereumAddress? _address;

  bool get isConnected => _credentials != null;

  WalletService({
    required Web3Client web3client,
  }) : _web3client = web3client;

  // Initialize wallet with private key
  Future<void> connectWithPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      _credentials = credentials;
      _address = credentials.address;
    } catch (e) {
      throw Exception('Failed to initialize wallet: $e');
    }
  }

  // Get the current credentials
  Credentials get credentials {
    if (_credentials == null) {
      throw Exception('Wallet not initialized');
    }
    return _credentials!;
  }

  // Get the current address
  EthereumAddress get address {
    if (_address == null) {
      throw Exception('Wallet not initialized');
    }
    return _address!;
  }

  // Get the current address as a hex string
  String get addressHex => _address?.hex ?? '';

  // Get the wallet balance
  Future<double> getBalance() async {
    try {
      if (_address == null) throw Exception('Wallet not initialized');

      final balance = await _web3client.getBalance(_address!);
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  // Get the current gas price
  Future<double> getGasPrice() async {
    try {
      final gasPrice = await _web3client.getGasPrice();
      return gasPrice.getValueInUnit(EtherUnit.gwei);
    } catch (e) {
      throw Exception('Failed to get gas price: $e');
    }
  }

  // Sign a message with the current credentials
  Future<String> signMessage(String message) async {
    try {
      if (_credentials == null) throw Exception('Wallet not initialized');

      final messageBytes = Uint8List.fromList(message.codeUnits);
      final signature =
          await _credentials!.signPersonalMessageToUint8List(messageBytes);
      return _bytesToHex(signature);
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  // Estimate gas for a transaction
  Future<BigInt> estimateGas({
    required String to,
    required String data,
    EtherAmount? value,
  }) async {
    try {
      if (_address == null) throw Exception('Wallet not initialized');

      final estimate = await _web3client.estimateGas(
        sender: _address,
        to: EthereumAddress.fromHex(to),
        data: _hexToBytes(data),
        value: value,
      );

      return estimate;
    } catch (e) {
      throw Exception('Failed to estimate gas: $e');
    }
  }

  // Disconnect wallet
  void disconnect() {
    _credentials = null;
    _address = null;
  }

  // Check if an address is valid
  bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Convert bytes to hex string
  String _bytesToHex(Uint8List bytes) {
    return hex.encode(bytes).toLowerCase();
  }

  // Convert hex string to bytes
  Uint8List _hexToBytes(String hexStr) {
    if (hexStr.startsWith('0x')) {
      hexStr = hexStr.substring(2);
    }
    return Uint8List.fromList(hex.decode(hexStr));
  }
}
