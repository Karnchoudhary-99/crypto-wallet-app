import 'package:crypto_wallet_app/crypto_wallet_app.dart';

void _printUsage() {
  print('Usage:');
  print('  dart run crypto_wallet_app <0x-address> [balance-in-wei]');
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
