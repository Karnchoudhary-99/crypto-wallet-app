import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';

WalletTransaction _tx({
  required String id,
  TxType type = TxType.send,
  TxStatus status = TxStatus.confirmed,
  BigInt? amount,
  BigInt? fee,
  String? memo,
}) {
  return WalletTransaction(
    id: id,
    from: _alice,
    to: _bob,
    asset: Asset.native,
    amount: amount ?? BigInt.from(100),
    fee: fee ?? BigInt.zero,
    type: type,
    status: status,
    timestamp: DateTime.utc(2026, 10, 25),
    memo: memo,
  );
}

void main() {
  group('HistorySummary', () {
    test('counts every status but totals only confirmed transactions', () {
      final history = TransactionHistory();
      history.add(_tx(id: 's1', amount: BigInt.from(100), fee: BigInt.from(5)));
      history.add(_tx(id: 's2', status: TxStatus.pending));
      history.add(_tx(id: 's3', status: TxStatus.failed));
      history.add(_tx(id: 'r1', type: TxType.receive, amount: BigInt.from(40)));
      final summary = HistorySummary(history);
      expect(summary.totalCount, 4);
      expect(summary.confirmedCount, 2);
      expect(summary.pendingCount, 1);
      expect(summary.failedCount, 1);
      // Send total includes the fee: 100 + 5.
      expect(summary.sentByAsset, {'ETH': BigInt.from(105)});
      expect(summary.receivedByAsset, {'ETH': BigInt.from(40)});
    });
  });

  group('TransactionHistory JSON and CSV', () {
    test('round-trips through JSON', () {
      final history = TransactionHistory();
      history.add(_tx(id: 'a', memo: 'first'));
      history.add(_tx(id: 'b', type: TxType.receive));
      final restored = TransactionHistory.fromJson(history.toJson());
      expect(restored.all.map((tx) => tx.id).toList(), ['a', 'b']);
      expect(restored.all.first.memo, 'first');
      expect(
        () => TransactionHistory.fromJson({'transactions': 'nope'}),
        throwsArgumentError,
      );
    });

    test('exports CSV with a header and RFC 4180 quoting', () {
      final history = TransactionHistory();
      history.add(_tx(id: 'a', memo: 'hello, "world"'));
      final lines = history.toCsv().split('\n');
      expect(
        lines.first,
        'id,timestamp,type,status,from,to,asset,amount,fee,memo',
      );
      expect(lines[1], contains('"hello, ""world"""'));
      expect(lines[1], startsWith('a,'));
    });
  });
}
