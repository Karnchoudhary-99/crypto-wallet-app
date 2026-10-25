import 'package:crypto_wallet_app/crypto_wallet_app.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart run crypto_wallet_app <0x-address> [balance-in-wei]');
    print('Demo: dart run crypto_wallet_app 0x742d35Cc6634C0532925a3b844Bc454e4438f44e 1500000000000000000');
    return;
  }
  final wallet = Wallet(
    address: arguments[0],
    balance: arguments.length > 1 ? BigInt.parse(arguments[1]) : BigInt.zero,
  );
  print('Address: ${wallet.address}');
  print('Balance: ${wallet.formattedBalance}');
}
