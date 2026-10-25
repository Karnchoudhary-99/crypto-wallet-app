import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';

WalletTransaction sampleTx({String id = 'tx-1', TxType type = TxType.send}) {
  return WalletTransaction(
    id: id,
    from: _alice,
    to: _bob,
    asset: Asset.native,
    amount: BigInt.parse('1000000000000000000'),
    fee: BigInt.parse('10000000000000000'),
    type: type,
    status: TxStatus.confirmed,
    timestamp: DateTime.utc(2026, 10, 25, 12),
    memo: 'invoice 42',
  );
}

void main() {
  group('WalletTransaction', () {
    test('total debit adds the fee only for sends', () {
      final send = sampleTx();
      expect(
        send.totalDebit,
        BigInt.parse('1010000000000000000'),
      );
      final receive = sampleTx(id: 'tx-2', type: TxType.receive);
      expect(receive.totalDebit, BigInt.parse('1000000000000000000'));
    });

    test('rejects bad addresses, non-positive amounts and negative fees', () {
      expect(
        () => WalletTransaction(
          id: 'x',
          from: 'nope',
          to: _bob,
          asset: Asset.native,
          amount: BigInt.one,
          type: TxType.send,
          status: TxStatus.pending,
          timestamp: DateTime.now(),
        ),
        throwsArgumentError,
      );
      expect(
        () => WalletTransaction(
          id: 'x',
          from: _alice,
          to: _bob,
          asset: Asset.native,
          amount: BigInt.zero,
          type: TxType.send,
          status: TxStatus.pending,
          timestamp: DateTime.now(),
        ),
        throwsArgumentError,
      );
      expect(
        () => WalletTransaction(
          id: 'x',
          from: _alice,
          to: _bob,
          asset: Asset.native,
          amount: BigInt.one,
          fee: BigInt.from(-1),
          type: TxType.send,
          status: TxStatus.pending,
          timestamp: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON, including a missing memo', () {
      final tx = sampleTx();
      expect(WalletTransaction.fromJson(tx.toJson()), tx);
      final noMemo = WalletTransaction(
        id: 'tx-3',
        from: _alice,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.one,
        type: TxType.receive,
        status: TxStatus.pending,
        timestamp: DateTime.utc(2026, 10, 25),
      );
      expect(WalletTransaction.fromJson(noMemo.toJson()), noMemo);
      expect(
        () => WalletTransaction.fromJson({'id': 'x'}),
        throwsArgumentError,
      );
    });
  });
}
