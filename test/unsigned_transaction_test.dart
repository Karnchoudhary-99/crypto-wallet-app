import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';

void main() {
  group('UnsignedTransaction', () {
    test('total cost adds amount and fee, payload covers every field', () {
      final tx = UnsignedTransaction(
        from: _alice,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.from(100),
        fee: BigInt.from(5),
        nonce: 3,
      );
      expect(tx.totalCost, BigInt.from(105));
      expect(
        tx.signingPayload,
        '$_alice|$_bob|ETH|18|100|5|3',
      );
      final changed = UnsignedTransaction(
        from: _alice,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.from(100),
        fee: BigInt.from(5),
        nonce: 4,
      );
      expect(changed.signingPayload, isNot(tx.signingPayload));
    });

    test('rejects bad addresses, non-positive amounts and bad nonces', () {
      expect(
        () => UnsignedTransaction(
          from: 'nope',
          to: _bob,
          asset: Asset.native,
          amount: BigInt.one,
          nonce: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => UnsignedTransaction(
          from: _alice,
          to: _bob,
          asset: Asset.native,
          amount: BigInt.zero,
          nonce: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => UnsignedTransaction(
          from: _alice,
          to: _bob,
          asset: Asset.native,
          amount: BigInt.one,
          fee: BigInt.from(-1),
          nonce: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => UnsignedTransaction(
          from: _alice,
          to: _bob,
          asset: Asset.native,
          amount: BigInt.one,
          nonce: -1,
        ),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON', () {
      final tx = UnsignedTransaction(
        from: _alice,
        to: _bob,
        asset: Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6),
        amount: BigInt.from(2500000),
        fee: BigInt.from(100),
        nonce: 7,
      );
      expect(UnsignedTransaction.fromJson(tx.toJson()), tx);
      expect(
        () => UnsignedTransaction.fromJson({'from': _alice}),
        throwsArgumentError,
      );
    });
  });
}
