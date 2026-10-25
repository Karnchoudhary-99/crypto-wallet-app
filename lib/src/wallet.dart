/// A minimal wallet model: an address and a balance in the smallest unit.
///
/// Addresses here are the familiar `0x` + 40-hex form. Validation is
/// deliberately strict: wrong length, bad characters, or a missing prefix
/// are all rejected rather than silently normalised.
class Wallet {
  Wallet({required this.address, BigInt? balance})
      : balance = balance ?? BigInt.zero {
    if (!isValidAddress(address)) {
      throw ArgumentError('Invalid wallet address: $address');
    }
    if (this.balance < BigInt.zero) {
      throw ArgumentError('Balance cannot be negative: ${this.balance}');
    }
  }

  final String address;
  final BigInt balance;

  static final _addressPattern = RegExp(r'^0x[0-9a-fA-F]{40}$');

  static bool isValidAddress(String address) =>
      _addressPattern.hasMatch(address);

  /// Balance in whole coins, assuming 18 decimals (e.g. wei -> ether).
  /// Returns a trimmed decimal string, e.g. 1500000000000000000 -> "1.5".
  String get formattedBalance {
    const decimals = 18;
    final divisor = BigInt.from(10).pow(decimals);
    final whole = balance ~/ divisor;
    final remainder = balance % divisor;
    if (remainder == BigInt.zero) return whole.toString();
    final fraction =
        remainder.toString().padLeft(decimals, '0').replaceAll(RegExp(r'0+$'), '');
    return '$whole.$fraction';
  }
}
