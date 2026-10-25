import 'package:crypto_wallet_app/crypto_wallet_app.dart';

void _printUsage() {
  print('Usage:');
  print('  dart run crypto_wallet_app <0x-address> [balance-in-wei]');
  print('  dart run crypto_wallet_app balances');
  print('  dart run crypto_wallet_app history');
  print('  dart run crypto_wallet_app build "<seed phrase>" <index> <to> <amount>');
  print('  dart run crypto_wallet_app store <file-path>');
  print('  dart run crypto_wallet_app new');
  print('  dart run crypto_wallet_app derive "<seed phrase>" <index>');
  print('');
  print('Demo only: seed phrases and keys here are NOT real-wallet');
  print('compatible (custom wordlist, hash-based derivation).');
  print('Never use them to hold real funds.');
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    _printUsage();
    return;
  }
  if (arguments[0] == 'balances') {
    final portfolio = Portfolio();
    portfolio.addAmount(Asset.native, BigInt.parse('1500000000000000000'));
    portfolio.addAmount(
      Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6),
      BigInt.from(250000000),
    );
    print('Sample portfolio:');
    for (final balance in portfolio.balances) {
      print('  ${balance.formattedAmount} ${balance.asset.symbol}');
    }
    return;
  }
  if (arguments[0] == 'history') {
    final history = TransactionHistory();
    const alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
    const bob = '0x1111111111111111111111111111111111111111';
    history.add(
      WalletTransaction(
        id: 'demo-1',
        from: alice,
        to: bob,
        asset: Asset.native,
        amount: BigInt.parse('1000000000000000000'),
        fee: BigInt.parse('10000000000000000'),
        type: TxType.send,
        status: TxStatus.confirmed,
        timestamp: DateTime.utc(2026, 10, 25, 12),
        memo: 'invoice 42',
      ),
    );
    history.add(
      WalletTransaction(
        id: 'demo-2',
        from: bob,
        to: alice,
        asset: Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6),
        amount: BigInt.from(250000000),
        type: TxType.receive,
        status: TxStatus.confirmed,
        timestamp: DateTime.utc(2026, 10, 25, 14),
        memo: 'refund',
      ),
    );
    print('Sample history (newest first):');
    for (final tx in history.all) {
      print(
        '  ${tx.id} ${tx.type.name} '
        '${AssetBalance(asset: tx.asset, amount: tx.amount).formattedAmount} '
        '${tx.asset.symbol} ${tx.status.name}',
      );
    }
    final summary = HistorySummary(history);
    print(
      'Summary: ${summary.confirmedCount} confirmed, '
      'sent ${summary.sentByAsset}, received ${summary.receivedByAsset}',
    );
    return;
  }
  if (arguments[0] == 'build') {
    if (arguments.length < 5) {
      print(
        'Usage: dart run crypto_wallet_app build "<seed phrase>" <index> <to> <amount>',
      );
      return;
    }
    final phrase = SeedPhrase.fromPhrase(
      arguments.sublist(1, arguments.length - 3).join(' '),
    );
    final index = int.parse(arguments[arguments.length - 3]);
    final to = arguments[arguments.length - 2];
    final amount = BigInt.parse(arguments.last);
    final key = DerivedKey.fromPhrase(phrase, index);
    final tx = TransactionBuilder()
        .from(key.address)
        .to(to)
        .asset(Asset.native)
        .amount(amount)
        .nonce(0)
        .build();
    final signed = SignedTransaction.sign(tx, key);
    print('From: ${tx.from}');
    print('To: ${tx.to}');
    print('Amount: ${tx.amount} (fee ${tx.fee}, nonce ${tx.nonce})');
    print('Signature: ${signed.signature}');
    print('Verifies: ${signed.verify(key)}');
    return;
  }
  if (arguments[0] == 'store') {
    if (arguments.length < 2) {
      print('Usage: dart run crypto_wallet_app store <file-path>');
      return;
    }
    final data = WalletData();
    data.portfolio.addAmount(Asset.native, BigInt.parse('1500000000000000000'));
    const storage = WalletStorage();
    storage.save(data, arguments[1]);
    final restored = storage.load(arguments[1]);
    print('Saved and reloaded ${arguments[1]}:');
    print('  ETH: ${restored.portfolio.balanceOf(Asset.native)}');
    print('  Transactions: ${restored.history.length}');
    return;
  }
  if (arguments[0] == 'new') {
    final phrase = SeedPhrase.generate();
    final account = WalletAccount.fromSeed(phrase, 0);
    print('Seed phrase: ${phrase.phrase}');
    print('Account 0 address: ${account.address}');
    return;
  }
  if (arguments[0] == 'derive') {
    if (arguments.length < 3) {
      print('Usage: dart run crypto_wallet_app derive "<seed phrase>" <index>');
      return;
    }
    final phrase = SeedPhrase.fromPhrase(
      arguments.sublist(1, arguments.length - 1).join(' '),
    );
    final index = int.parse(arguments.last);
    final account = WalletAccount.fromSeed(phrase, index);
    print('Account $index address: ${account.address}');
    print('Private key: ${account.key.privateKeyHex}');
    return;
  }
  final wallet = Wallet(
    address: arguments[0],
    balance: arguments.length > 1 ? BigInt.parse(arguments[1]) : BigInt.zero,
  );
  print('Address: ${wallet.address}');
  print('Balance: ${wallet.formattedBalance}');
}
