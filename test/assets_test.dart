import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

void main() {
  group('Asset', () {
    test('accepts a well-formed asset and its native shortcut', () {
      final asset = Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6);
      expect(asset.symbol, 'USDC');
      expect(asset.decimals, 6);
      expect(Asset.native.symbol, 'ETH');
      expect(Asset.native.decimals, 18);
    });

    test('rejects bad symbols, empty names and out-of-range decimals', () {
      expect(
        () => Asset(symbol: 'usdc', name: 'USD Coin', decimals: 6),
        throwsArgumentError,
      );
      expect(
        () => Asset(symbol: 'TOOLONGSYMBOL', name: 'X', decimals: 6),
        throwsArgumentError,
      );
      expect(
        () => Asset(symbol: 'USDC', name: '', decimals: 6),
        throwsArgumentError,
      );
      expect(
        () => Asset(symbol: 'USDC', name: 'USD Coin', decimals: 19),
        throwsArgumentError,
      );
      expect(
        () => Asset(symbol: 'USDC', name: 'USD Coin', decimals: -1),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON and compares by value', () {
      final asset = Asset(symbol: 'DAI', name: 'Dai', decimals: 18);
      final restored = Asset.fromJson(asset.toJson());
      expect(restored, asset);
      expect(restored.hashCode, asset.hashCode);
      expect(
        () => Asset.fromJson({'symbol': 'DAI', 'name': 'Dai'}),
        throwsArgumentError,
      );
    });
  });
}
