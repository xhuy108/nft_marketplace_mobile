import 'package:web3dart/web3dart.dart';

extension WalletServiceExtension on EtherAmount {
  String formatEther({int decimals = 4}) {
    return getValueInUnit(EtherUnit.ether).toStringAsFixed(decimals);
  }

  String formatGwei({int decimals = 2}) {
    return getValueInUnit(EtherUnit.gwei).toStringAsFixed(decimals);
  }
}

extension AddressFormatting on String {
  String get shortAddress {
    if (length < 10) return this;
    return '${substring(0, 6)}...${substring(length - 4)}';
  }

  bool get isValidEthereumAddress {
    try {
      if (!startsWith('0x')) return false;
      EthereumAddress.fromHex(this);
      return true;
    } catch (_) {
      return false;
    }
  }
}
