import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';

void main() {
  group('TransactionBuilder', () {
    test('builds with defaults for fee and nonce', () {
      final tx = TransactionBuilder()
          .from(_alice)
          .to(_bob)
          .asset(Asset.native)
          .amount(BigInt.from(100))
          .build();
      expect(tx.fee, BigInt.zero);
      expect(tx.nonce, 0);
      expect(tx.totalCost, BigInt.from(100));
    });

    test('honours explicit fee and nonce', () {
      final tx = TransactionBuilder()
          .from(_alice)
          .to(_bob)
          .asset(Asset.native)
          .amount(BigInt.from(100))
          .fee(BigInt.from(5))
          .nonce(9)
          .build();
      expect(tx.totalCost, BigInt.from(105));
      expect(tx.nonce, 9);
    });

    test('reports each missing required field', () {
      expect(() => TransactionBuilder().build(), throwsStateError);
      expect(
        () => TransactionBuilder().from(_alice).build(),
        throwsStateError,
      );
      expect(
        () => TransactionBuilder()
            .from(_alice)
            .to(_bob)
            .asset(Asset.native)
            .build(),
        throwsStateError,
      );
      expect(
        () => TransactionBuilder()
            .from(_alice)
            .to(_bob)
            .asset(Asset.native)
            .amount(BigInt.from(-1))
            .build(),
        throwsArgumentError,
      );
    });
  });
}
