import 'transaction.dart';
import 'transaction_history.dart';

/// Totals over a [TransactionHistory].
///
/// Only confirmed transactions count toward sent/received totals — a
/// pending send has not left the wallet yet and a failed one never
/// will. Counts, by contrast, cover every recorded transaction, so a
/// wallet can see how much of its history is still unsettled.
class HistorySummary {
  HistorySummary(TransactionHistory history)
      : totalCount = history.length,
        confirmedCount =
            history.filter(status: TxStatus.confirmed).length,
        pendingCount = history.filter(status: TxStatus.pending).length,
        failedCount = history.filter(status: TxStatus.failed).length,
        sentByAsset = _totals(
          history.filter(type: TxType.send, status: TxStatus.confirmed),
          (tx) => tx.totalDebit,
        ),
        receivedByAsset = _totals(
          history.filter(type: TxType.receive, status: TxStatus.confirmed),
          (tx) => tx.amount,
        );

  final int totalCount;
  final int confirmedCount;
  final int pendingCount;
  final int failedCount;

  /// Smallest-unit totals keyed by asset symbol.
  final Map<String, BigInt> sentByAsset;
  final Map<String, BigInt> receivedByAsset;

  static Map<String, BigInt> _totals(
    List<WalletTransaction> txs,
    BigInt Function(WalletTransaction) pick,
  ) {
    final totals = <String, BigInt>{};
    for (final tx in txs) {
      totals[tx.asset.symbol] = (totals[tx.asset.symbol] ?? BigInt.zero) +
          pick(tx);
    }
    return totals;
  }
}
