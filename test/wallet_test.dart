import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

void main() {
  group('Wallet.isValidAddress', () {
    test('accepts a well-formed 0x address', () {
      expect(
        Wallet.isValidAddress('0x742d35Cc6634C0532925a3b844Bc454e4438f44e'),
        isTrue,
      );
    });

    test('rejects missing prefix, short and non-hex addresses', () {
      expect(Wallet.isValidAddress('742d35Cc6634C0532925a3b844Bc454e4438f44e'), isFalse);
      expect(Wallet.isValidAddress('0x1234'), isFalse);
      expect(Wallet.isValidAddress('0xZZZZ35Cc6634C0532925a3b844Bc454e4438f44e'), isFalse);
    });
  });

  group('Wallet', () {
    test('throws on an invalid address or negative balance', () {
      expect(() => Wallet(address: 'not-an-address'), throwsArgumentError);
      expect(
        () => Wallet(
          address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
          balance: BigInt.from(-1),
        ),
        throwsArgumentError,
      );
    });

    test('formats an 18-decimal balance without trailing zeros', () {
      final wallet = Wallet(
        address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        balance: BigInt.parse('1500000000000000000'),
      );
      expect(wallet.formattedBalance, '1.5');
    });
  });
}
