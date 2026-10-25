import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

void main() {
  final usdc = Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6);
  final dai = Asset(symbol: 'DAI', name: 'Dai', decimals: 18);

  group('AssetBalance', () {
    test('formats amounts per asset decimals without trailing zeros', () {
      expect(
        AssetBalance(asset: usdc, amount: BigInt.from(1500000))
            .formattedAmount,
        '1.5',
      );
      expect(
        AssetBalance(asset: dai, amount: BigInt.parse('1500000000000000000'))
            .formattedAmount,
        '1.5',
      );
      expect(
        AssetBalance(
          asset: Asset(symbol: 'PTS', name: 'Points', decimals: 0),
          amount: BigInt.from(1500000),
        ).formattedAmount,
        '1500000',
      );
      expect(
        AssetBalance(asset: usdc).formattedAmount,
        '0',
      );
    });

    test('adds and subtracts only matching assets, never below zero', () {
      final balance = AssetBalance(asset: usdc, amount: BigInt.from(100));
      expect(
        balance.add(AssetBalance(asset: usdc, amount: BigInt.from(50))).amount,
        BigInt.from(150),
      );
      expect(
        balance.subtract(AssetBalance(asset: usdc, amount: BigInt.from(40)))
            .amount,
        BigInt.from(60),
      );
      expect(
        () => balance.add(AssetBalance(asset: dai, amount: BigInt.one)),
        throwsArgumentError,
      );
      expect(
        () => balance.subtract(
          AssetBalance(asset: usdc, amount: BigInt.from(101)),
        ),
        throwsArgumentError,
      );
      expect(
        () => AssetBalance(asset: usdc, amount: BigInt.from(-1)),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON', () {
      final balance = AssetBalance(asset: usdc, amount: BigInt.from(2500000));
      expect(AssetBalance.fromJson(balance.toJson()), balance);
      expect(
        () => AssetBalance.fromJson({'asset': 'USDC', 'amount': '1'}),
        throwsArgumentError,
      );
    });
  });
}
