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
}) {
  return WalletTransaction(
    id: id,
    from: type == TxType.send ? _alice : _bob,
    to: type == TxType.send ? _bob : _alice,
    asset: Asset.native,
    amount: amount ?? BigInt.from(100),
    fee: fee ?? BigInt.zero,
    type: type,
    status: status,
    timestamp: DateTime.utc(2026, 10, 25),
  );
}

void main() {
  group('Portfolio.applyTransaction', () {
    test('debits amount plus fee on a confirmed send', () {
      final portfolio = Portfolio();
      portfolio.addAmount(Asset.native, BigInt.from(1000));
      portfolio.applyTransaction(
        _tx(id: 's1', amount: BigInt.from(100), fee: BigInt.from(5)),
        _alice,
      );
      expect(portfolio.balanceOf(Asset.native), BigInt.from(895));
    });

    test('credits the amount on a confirmed receive', () {
      final portfolio = Portfolio();
      portfolio.applyTransaction(_tx(id: 'r1', type: TxType.receive), _alice);
      expect(portfolio.balanceOf(Asset.native), BigInt.from(100));
    });

    test('ignores pending, rejects failed, unrelated and unaffordable', () {
      final portfolio = Portfolio();
      portfolio.addAmount(Asset.native, BigInt.from(50));
      portfolio.applyTransaction(
        _tx(id: 'p1', status: TxStatus.pending),
        _alice,
      );
      expect(portfolio.balanceOf(Asset.native), BigInt.from(50));
      expect(
        () => portfolio.applyTransaction(
          _tx(id: 'f1', status: TxStatus.failed),
          _alice,
        ),
        throwsArgumentError,
      );
      expect(
        () => portfolio.applyTransaction(_tx(id: 'u1'), _bob),
        throwsArgumentError,
      );
      expect(
        () => portfolio.applyTransaction(_tx(id: 's2'), _alice),
        throwsArgumentError,
      );
    });
  });
}
