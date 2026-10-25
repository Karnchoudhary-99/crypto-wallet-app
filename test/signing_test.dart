import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _bob = '0x1111111111111111111111111111111111111111';
const _phrase =
    'apple banana cherry mango lemon grape peach pear plum melon kiwi golden';

void main() {
  group('SignedTransaction', () {
    test('signs deterministically and verifies with the sender key', () {
      final phrase = SeedPhrase.fromPhrase(_phrase);
      final key = DerivedKey.fromPhrase(phrase, 0);
      final tx = UnsignedTransaction(
        from: key.address,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.from(100),
        fee: BigInt.from(5),
        nonce: 2,
      );
      final signed = SignedTransaction.sign(tx, key);
      expect(SignedTransaction.sign(tx, key), signed);
      expect(signed.verify(key), isTrue);
      // A different nonce changes the payload, so the old signature
      // must not verify for the new transaction.
      final moved = UnsignedTransaction(
        from: key.address,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.from(100),
        fee: BigInt.from(5),
        nonce: 3,
      );
      expect(
        SignedTransaction(unsigned: moved, signature: signed.signature)
            .verify(key),
        isFalse,
      );
    });

    test('rejects signing for another sender and wrong-key verification', () {
      final phrase = SeedPhrase.fromPhrase(_phrase);
      final key0 = DerivedKey.fromPhrase(phrase, 0);
      final key1 = DerivedKey.fromPhrase(phrase, 1);
      final tx = UnsignedTransaction(
        from: key0.address,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.from(100),
        nonce: 0,
      );
      expect(() => SignedTransaction.sign(tx, key1), throwsArgumentError);
      final signed = SignedTransaction.sign(tx, key0);
      expect(signed.verify(key1), isFalse);
    });

    test('round-trips through JSON', () {
      final phrase = SeedPhrase.fromPhrase(_phrase);
      final key = DerivedKey.fromPhrase(phrase, 0);
      final tx = UnsignedTransaction(
        from: key.address,
        to: _bob,
        asset: Asset.native,
        amount: BigInt.from(100),
        nonce: 0,
      );
      final signed = SignedTransaction.sign(tx, key);
      expect(SignedTransaction.fromJson(signed.toJson()), signed);
      expect(
        () => SignedTransaction.fromJson({'signature': '00'}),
        throwsArgumentError,
      );
    });
  });
}
