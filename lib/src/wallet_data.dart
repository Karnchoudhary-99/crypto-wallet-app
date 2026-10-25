import 'portfolio.dart';
import 'transaction.dart';
import 'transaction_history.dart';

/// Everything a wallet needs to persist: holdings plus history.
///
/// Serialized as one JSON object so a whole wallet can be saved to a
/// single file and restored later (restore = [WalletData.fromJson],
/// which replaces). [merge] instead combines two *distinct* wallets:
/// holdings are summed and only transactions not already known (by id)
/// are added — so merging the same export twice would double-count
/// holdings, and must not be used as a restore path.
class WalletData {
  WalletData({Portfolio? portfolio, TransactionHistory? history})
      : portfolio = portfolio ?? Portfolio(),
        history = history ?? TransactionHistory();

  final Portfolio portfolio;
  final TransactionHistory history;

  void merge(WalletData other) {
    for (final balance in other.portfolio.balances) {
      portfolio.add(balance);
    }
    for (final tx in other.history.all) {
      try {
        history.add(tx);
      } on ArgumentError {
        // Already known by id: skip, keep the existing record.
      }
    }
  }

  Map<String, Object?> toJson() => {
        'portfolio': portfolio.toJson(),
        'history': history.toJson(),
      };

  factory WalletData.fromJson(Map<String, Object?> json) {
    final portfolioJson = json['portfolio'];
    final historyJson = json['history'];
    if (portfolioJson is! Map<String, Object?> ||
        historyJson is! Map<String, Object?>) {
      throw ArgumentError('Invalid wallet data JSON: $json');
    }
    return WalletData(
      portfolio: Portfolio.fromJson(portfolioJson),
      history: TransactionHistory.fromJson(historyJson),
    );
  }
}
