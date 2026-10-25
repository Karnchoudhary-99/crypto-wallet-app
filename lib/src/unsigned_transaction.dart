import 'asset.dart';
import 'wallet.dart';

/// A transaction ready to sign, but not yet signed.
///
/// [nonce] is the sender's per-account sequence number: it must rise
/// by one per transaction or a later transaction replays an earlier
/// one. [totalCost] is what a send debits — amount plus fee, both in
/// the asset's smallest unit.
class UnsignedTransaction {
  UnsignedTransaction({
    required this.from,
    required this.to,
    required this.asset,
    required this.amount,
    BigInt? fee,
    required this.nonce,
  }) : fee = fee ?? BigInt.zero {
    if (!Wallet.isValidAddress(from)) {
      throw ArgumentError('Invalid sender address: $from');
    }
    if (!Wallet.isValidAddress(to)) {
      throw ArgumentError('Invalid recipient address: $to');
    }
    if (amount <= BigInt.zero) {
      throw ArgumentError('Transaction amount must be positive: $amount');
    }
    if (this.fee < BigInt.zero) {
      throw ArgumentError('Transaction fee cannot be negative: ${this.fee}');
    }
    if (nonce < 0) {
      throw ArgumentError('Transaction nonce cannot be negative: $nonce');
    }
  }

  final String from;
  final String to;
  final Asset asset;
  final BigInt amount;
  final BigInt fee;
  final int nonce;

  BigInt get totalCost => amount + fee;

  /// Canonical payload that signing covers, field by field.
  String get signingPayload =>
      '$from|$to|${asset.symbol}|${asset.decimals}|'
      '${amount.toString()}|${fee.toString()}|$nonce';

  Map<String, Object?> toJson() => {
        'from': from,
        'to': to,
        'asset': asset.toJson(),
        'amount': amount.toString(),
        'fee': fee.toString(),
        'nonce': nonce,
      };

  factory UnsignedTransaction.fromJson(Map<String, Object?> json) {
    final from = json['from'];
    final to = json['to'];
    final assetJson = json['asset'];
    final amount = json['amount'];
    final fee = json['fee'];
    final nonce = json['nonce'];
    if (from is! String ||
        to is! String ||
        assetJson is! Map<String, Object?> ||
        amount is! String ||
        fee is! String ||
        nonce is! int) {
      throw ArgumentError('Invalid unsigned transaction JSON: $json');
    }
    return UnsignedTransaction(
      from: from,
      to: to,
      asset: Asset.fromJson(assetJson),
      amount: BigInt.parse(amount),
      fee: BigInt.parse(fee),
      nonce: nonce,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UnsignedTransaction &&
      other.from == from &&
      other.to == to &&
      other.asset == asset &&
      other.amount == amount &&
      other.fee == fee &&
      other.nonce == nonce;

  @override
  int get hashCode => Object.hash(from, to, asset, amount, fee, nonce);
}
