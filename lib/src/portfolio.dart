import 'asset.dart';
import 'asset_balance.dart';
import 'transaction.dart';

/// The set of assets one wallet holds, keyed by asset symbol.
///
/// Adding the same asset twice merges the amounts; subtracting down to
/// zero drops the asset from the holdings entirely, so [assets] never
/// lists a zero balance. Balances for assets never added read as zero
/// rather than throwing, which keeps callers simple.
class Portfolio {
  Portfolio();

  final Map<String, AssetBalance> _holdings = {};

  /// Assets currently held, sorted by symbol for deterministic output.
  List<Asset> get assets {
    final sorted = _holdings.values.map((b) => b.asset).toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));
    return sorted;
  }

  List<AssetBalance> get balances {
    final sorted = _holdings.values.toList()
      ..sort((a, b) => a.asset.symbol.compareTo(b.asset.symbol));
    return sorted;
  }

  bool get isEmpty => _holdings.isEmpty;

  int get assetCount => _holdings.length;

  /// Raw smallest-unit balance of [asset], or zero if never added.
  BigInt balanceOf(Asset asset) => _holdings[asset.symbol]?.amount ?? BigInt.zero;

  AssetBalance? balanceFor(String symbol) => _holdings[symbol];

  void add(AssetBalance balance) {
    final existing = _holdings[balance.asset.symbol];
    _holdings[balance.asset.symbol] =
        existing == null ? balance : existing.add(balance);
  }

  void addAmount(Asset asset, BigInt amount) =>
      add(AssetBalance(asset: asset, amount: amount));

  void subtract(AssetBalance balance) {
    final existing = _holdings[balance.asset.symbol];
    if (existing == null) {
      throw ArgumentError(
        'Cannot subtract ${balance.asset.symbol}: wallet holds none',
      );
    }
    final remaining = existing.subtract(balance);
    if (remaining.amount == BigInt.zero) {
      _holdings.remove(balance.asset.symbol);
    } else {
      _holdings[balance.asset.symbol] = remaining;
    }
  }

  void subtractAmount(Asset asset, BigInt amount) =>
      subtract(AssetBalance(asset: asset, amount: amount));

  /// Applies a confirmed transaction involving [ownAddress] to the
  /// holdings: a confirmed send debits amount + fee, a confirmed
  /// receive credits the amount. Pending transactions are ignored
  /// (nothing has settled yet); failed ones are rejected, since
  /// applying them would invent money or destroy it. Transactions
  /// that do not involve this wallet are also rejected.
  void applyTransaction(WalletTransaction tx, String ownAddress) {
    if (tx.status == TxStatus.pending) return;
    if (tx.status == TxStatus.failed) {
      throw ArgumentError('Cannot apply failed transaction ${tx.id}');
    }
    if (tx.type == TxType.send && tx.from == ownAddress) {
      subtractAmount(tx.asset, tx.totalDebit);
    } else if (tx.type == TxType.receive && tx.to == ownAddress) {
      addAmount(tx.asset, tx.amount);
    } else {
      throw ArgumentError(
        'Transaction ${tx.id} does not involve wallet $ownAddress',
      );
    }
  }

  Map<String, Object?> toJson() => {
        'balances': balances.map((b) => b.toJson()).toList(),
      };

  factory Portfolio.fromJson(Map<String, Object?> json) {
    final balancesJson = json['balances'];
    if (balancesJson is! List) {
      throw ArgumentError('Invalid portfolio JSON: $json');
    }
    final portfolio = Portfolio();
    for (final entry in balancesJson) {
      if (entry is! Map<String, Object?>) {
        throw ArgumentError('Invalid portfolio balance JSON: $entry');
      }
      portfolio.add(AssetBalance.fromJson(entry));
    }
    return portfolio;
  }
}
