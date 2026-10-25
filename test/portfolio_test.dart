import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

void main() {
  final usdc = Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6);
  final dai = Asset(symbol: 'DAI', name: 'Dai', decimals: 18);

  group('Portfolio', () {
    test('merges repeated adds and reads unknown assets as zero', () {
      final portfolio = Portfolio();
      expect(portfolio.isEmpty, isTrue);
      expect(portfolio.balanceOf(usdc), BigInt.zero);
      portfolio.addAmount(usdc, BigInt.from(100));
      portfolio.addAmount(usdc, BigInt.from(50));
      expect(portfolio.balanceOf(usdc), BigInt.from(150));
      expect(portfolio.assetCount, 1);
    });

    test('subtracts and drops assets that reach zero', () {
      final portfolio = Portfolio();
      portfolio.addAmount(usdc, BigInt.from(100));
      portfolio.addAmount(dai, BigInt.from(10));
      portfolio.subtractAmount(usdc, BigInt.from(40));
      expect(portfolio.balanceOf(usdc), BigInt.from(60));
      portfolio.subtractAmount(usdc, BigInt.from(60));
      expect(portfolio.balanceOf(usdc), BigInt.zero);
      expect(portfolio.assets, [dai]);
      expect(
        () => portfolio.subtractAmount(usdc, BigInt.one),
        throwsArgumentError,
      );
      expect(
        () => portfolio.subtractAmount(dai, BigInt.from(11)),
        throwsArgumentError,
      );
    });

    test('lists balances sorted by symbol and round-trips through JSON', () {
      final portfolio = Portfolio();
      portfolio.addAmount(usdc, BigInt.from(2500000));
      portfolio.addAmount(dai, BigInt.parse('2000000000000000000'));
      expect(
        portfolio.balances.map((b) => b.asset.symbol).toList(),
        ['DAI', 'USDC'],
      );
      final restored = Portfolio.fromJson(portfolio.toJson());
      expect(restored.balanceOf(usdc), BigInt.from(2500000));
      expect(
        restored.balanceOf(dai),
        BigInt.parse('2000000000000000000'),
      );
      expect(
        () => Portfolio.fromJson({'balances': 'nope'}),
        throwsArgumentError,
      );
    });
  });
}
