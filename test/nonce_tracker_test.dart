import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

void main() {
  group('NonceTracker', () {
    test('starts at zero, advances only on consume, tracks per address', () {
      final tracker = NonceTracker();
      const alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
      const bob = '0x1111111111111111111111111111111111111111';
      expect(tracker.peek(alice), 0);
      expect(tracker.consume(alice), 0);
      expect(tracker.peek(alice), 1);
      expect(tracker.consume(alice), 1);
      expect(tracker.peek(bob), 0);
      tracker.reset(alice);
      expect(tracker.peek(alice), 0);
    });
  });
}
