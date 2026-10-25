// End-to-end demo: derive an account, build a transaction with the
// next nonce, sign it, verify it, apply it to a portfolio and record
// it in a history. Run with: dart run examples/build_tx.dart
//
// Demo only: signing here is HMAC-based, not ECDSA, and nothing here
// can hold real funds.
import 'package:crypto_wallet_app/crypto_wallet_app.dart';

void main() {
  const phraseText =
      'apple banana cherry mango lemon grape peach pear plum melon kiwi golden';
  const bob = '0x1111111111111111111111111111111111111111';
  final phrase = SeedPhrase.fromPhrase(phraseText);
  final key = DerivedKey.fromPhrase(phrase, 0);

  final portfolio = Portfolio();
  portfolio.addAmount(Asset.native, BigInt.parse('2000000000000000000'));

  final nonces = NonceTracker();
  final tx = TransactionBuilder()
      .from(key.address)
      .to(bob)
      .asset(Asset.native)
      .amount(BigInt.parse('1000000000000000000'))
      .fee(BigInt.parse('10000000000000000'))
      .nonce(nonces.consume(key.address))
      .build();
  final signed = SignedTransaction.sign(tx, key);
  print('Signed: ${signed.signature}');
  print('Verifies: ${signed.verify(key)}');

  final record = WalletTransaction(
    id: 'example-1',
    from: tx.from,
    to: tx.to,
    asset: tx.asset,
    amount: tx.amount,
    fee: tx.fee,
    type: TxType.send,
    status: TxStatus.confirmed,
    timestamp: DateTime.now(),
    memo: 'example payment',
  );
  portfolio.applyTransaction(record, key.address);
  final history = TransactionHistory();
  history.add(record);
  print('Portfolio ETH: ${portfolio.balanceOf(Asset.native)}');
  print('History: ${history.all.length} transaction(s)');
  print('Summary sent: ${HistorySummary(history).sentByAsset}');
}
