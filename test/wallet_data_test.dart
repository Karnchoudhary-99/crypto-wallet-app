import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';

WalletTransaction _tx(String id, BigInt amount) {
  return WalletTransaction(
    id: id,
    from: _alice,
    to: _bob,
    asset: Asset.native,
    amount: amount,
    type: TxType.send,
    status: TxStatus.confirmed,
    timestamp: DateTime.utc(2026, 10, 25),
  );
}

void main() {
  group('WalletData', () {
    test('round-trips holdings and history through JSON', () {
      final data = WalletData();
      data.portfolio.addAmount(Asset.native, BigInt.from(500));
      data.history.add(_tx('t1', BigInt.from(100)));
      final restored = WalletData.fromJson(data.toJson());
      expect(restored.portfolio.balanceOf(Asset.native), BigInt.from(500));
      expect(restored.history.all.map((tx) => tx.id).toList(), ['t1']);
      expect(
        () => WalletData.fromJson({'portfolio': 'nope'}),
        throwsArgumentError,
      );
    });

    test('merge adds holdings and new transactions, skips duplicates', () {
      final mine = WalletData();
      mine.portfolio.addAmount(Asset.native, BigInt.from(100));
      mine.history.add(_tx('t1', BigInt.from(100)));
      final other = WalletData();
      other.portfolio.addAmount(Asset.native, BigInt.from(50));
      other.history.add(_tx('t1', BigInt.from(100)));
      other.history.add(_tx('t2', BigInt.from(25)));
      mine.merge(other);
      expect(mine.portfolio.balanceOf(Asset.native), BigInt.from(150));
      expect(
        mine.history.all.map((tx) => tx.id).toList(),
        ['t1', 't2'],
      );
      // Merging again sums holdings once more but never duplicates
      // transactions: history stays at 2.
      mine.merge(other);
      expect(mine.portfolio.balanceOf(Asset.native), BigInt.from(200));
      expect(mine.history.length, 2);
    });
  });
}
