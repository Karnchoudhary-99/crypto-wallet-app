import 'asset.dart';
import 'transaction.dart';

/// A wallet's local transaction history, newest first.
///
/// Transactions are stored by unique [WalletTransaction.id] — recording
/// the same id twice is a caller bug and is rejected. All views return
/// newest-first order (timestamp descending, id ascending as tie-break
/// so equal timestamps order deterministically).
class TransactionHistory {
  TransactionHistory();

  final Map<String, WalletTransaction> _byId = {};

  int get length => _byId.length;

  bool get isEmpty => _byId.isEmpty;

  void add(WalletTransaction tx) {
    if (_byId.containsKey(tx.id)) {
      throw ArgumentError('Duplicate transaction id: ${tx.id}');
    }
    _byId[tx.id] = tx;
  }

  /// All transactions, newest first.
  List<WalletTransaction> get all => _sorted(_byId.values);

  List<WalletTransaction> _sorted(Iterable<WalletTransaction> txs) {
    final sorted = txs.toList()
      ..sort((a, b) {
        final byTime = b.timestamp.compareTo(a.timestamp);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    return sorted;
  }

  /// Filtered view, still newest first. Bounds are inclusive; a
  /// counterparty filter matches either side of the transaction.
  List<WalletTransaction> filter({
    Asset? asset,
    TxType? type,
    TxStatus? status,
    String? counterparty,
    DateTime? from,
    DateTime? to,
  }) {
    return _sorted(_byId.values.where((tx) {
      if (asset != null && tx.asset != asset) return false;
      if (type != null && tx.type != type) return false;
      if (status != null && tx.status != status) return false;
      if (counterparty != null &&
          tx.from != counterparty &&
          tx.to != counterparty) {
        return false;
      }
      if (from != null && tx.timestamp.isBefore(from)) return false;
      if (to != null && tx.timestamp.isAfter(to)) return false;
      return true;
    }));
  }

  /// Transactions whose memo contains [query] (case-insensitive).
  List<WalletTransaction> searchMemo(String query) {
    final needle = query.toLowerCase();
    return _sorted(
      _byId.values.where(
        (tx) => tx.memo != null && tx.memo!.toLowerCase().contains(needle),
      ),
    );
  }

  /// One page of the newest-first history: page 0 is the newest
  /// [pageSize] transactions. Out-of-range pages are empty, never an error.
  List<WalletTransaction> page({int page = 0, int pageSize = 20}) {
    if (page < 0) throw ArgumentError('Page cannot be negative: $page');
    if (pageSize <= 0) {
      throw ArgumentError('Page size must be positive: $pageSize');
    }
    final sorted = all;
    final start = page * pageSize;
    if (start >= sorted.length) return const [];
    final end = (start + pageSize).clamp(0, sorted.length);
    return sorted.sublist(start, end);
  }

  Map<String, Object?> toJson() => {
        'transactions': all.map((tx) => tx.toJson()).toList(),
      };

  factory TransactionHistory.fromJson(Map<String, Object?> json) {
    final txsJson = json['transactions'];
    if (txsJson is! List) {
      throw ArgumentError('Invalid transaction history JSON: $json');
    }
    final history = TransactionHistory();
    for (final entry in txsJson) {
      if (entry is! Map<String, Object?>) {
        throw ArgumentError('Invalid transaction JSON: $entry');
      }
      history.add(WalletTransaction.fromJson(entry));
    }
    return history;
  }
}
