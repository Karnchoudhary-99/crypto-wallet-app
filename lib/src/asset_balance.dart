import 'asset.dart';

/// An amount of one [Asset], held in the asset's smallest unit.
///
/// Formatting mirrors the wallet's 18-decimal formatting but honours the asset's
/// own [Asset.decimals]: 1500000 of a 6-decimal asset formats as "1.5",
/// while the same raw amount of a 0-decimal asset formats as "1500000".
class AssetBalance {
  AssetBalance({required this.asset, BigInt? amount})
      : amount = amount ?? BigInt.zero {
    if (this.amount < BigInt.zero) {
      throw ArgumentError('Asset balance cannot be negative: ${this.amount}');
    }
  }

  final Asset asset;
  final BigInt amount;

  /// Amount in whole units, trimmed of trailing zeros.
  String get formattedAmount {
    final decimals = asset.decimals;
    if (decimals == 0) return amount.toString();
    final divisor = BigInt.from(10).pow(decimals);
    final whole = amount ~/ divisor;
    final remainder = amount % divisor;
    if (remainder == BigInt.zero) return whole.toString();
    final fraction = remainder
        .toString()
        .padLeft(decimals, '0')
        .replaceAll(RegExp(r'0+$'), '');
    return '$whole.$fraction';
  }

  /// A new balance with [other] added; assets must match.
  AssetBalance add(AssetBalance other) {
    _requireSameAsset(other);
    return AssetBalance(asset: asset, amount: amount + other.amount);
  }

  /// A new balance with [other] subtracted; never goes below zero.
  AssetBalance subtract(AssetBalance other) {
    _requireSameAsset(other);
    if (other.amount > amount) {
      throw ArgumentError(
        'Insufficient ${asset.symbol} balance: '
        'have $amount, tried to subtract ${other.amount}',
      );
    }
    return AssetBalance(asset: asset, amount: amount - other.amount);
  }

  void _requireSameAsset(AssetBalance other) {
    if (other.asset != asset) {
      throw ArgumentError(
        'Cannot combine ${asset.symbol} with ${other.asset.symbol}',
      );
    }
  }

  Map<String, Object?> toJson() => {
        'asset': asset.toJson(),
        'amount': amount.toString(),
      };

  factory AssetBalance.fromJson(Map<String, Object?> json) {
    final assetJson = json['asset'];
    final amount = json['amount'];
    if (assetJson is! Map<String, Object?> || amount is! String) {
      throw ArgumentError('Invalid asset balance JSON: $json');
    }
    return AssetBalance(
      asset: Asset.fromJson(assetJson),
      amount: BigInt.parse(amount),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AssetBalance && other.asset == asset && other.amount == amount;

  @override
  int get hashCode => Object.hash(asset, amount);

  @override
  String toString() => '$formattedAmount ${asset.symbol}';
}
