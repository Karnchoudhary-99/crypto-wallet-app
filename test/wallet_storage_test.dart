import 'dart:io';

import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';

void main() {
  group('WalletStorage', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('wallet-storage-test');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('saves and reloads holdings and history, no temp file left', () {
      final data = WalletData();
      data.portfolio.addAmount(Asset.native, BigInt.from(700));
      data.history.add(
        WalletTransaction(
          id: 't1',
          from: _alice,
          to: _bob,
          asset: Asset.native,
          amount: BigInt.from(100),
          type: TxType.send,
          status: TxStatus.confirmed,
          timestamp: DateTime.utc(2026, 10, 25),
        ),
      );
      final path = '${tempDir.path}/wallet.json';
      const storage = WalletStorage();
      storage.save(data, path);
      expect(File('$path.tmp').existsSync(), isFalse);
      final restored = storage.load(path);
      expect(restored.portfolio.balanceOf(Asset.native), BigInt.from(700));
      expect(restored.history.all.map((tx) => tx.id).toList(), ['t1']);
    });

    test('rejects missing files and malformed contents', () {
      const storage = WalletStorage();
      expect(
        () => storage.load('${tempDir.path}/missing.json'),
        throwsArgumentError,
      );
      final bad = File('${tempDir.path}/bad.json');
      bad.writeAsStringSync('{"portfolio": "nope"}');
      expect(() => storage.load(bad.path), throwsArgumentError);
      final notJson = File('${tempDir.path}/notjson.json');
      notJson.writeAsStringSync('not json at all');
      expect(() => storage.load(notJson.path), throwsA(isA<FormatException>()));
    });
  });
}
