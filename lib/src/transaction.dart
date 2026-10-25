import 'asset.dart';
import 'wallet.dart';

/// Direction of a transaction relative to the wallet that records it.
enum TxType { send, receive }

/// Lifecycle state of a transaction.
enum TxStatus { pending, confirmed, failed }

/// One recorded transaction: who paid whom, in what asset, how much.
///
/// Amounts are in the asset's smallest unit and must be positive; the
/// fee (same asset, zero by default) is tracked separately so a send's
/// total debit is amount + fee. [timestamp] is the time the transaction
/// was first seen, not a chain confirmation time — this is a local
/// history record, not a block explorer entry.
class WalletTransaction {
  WalletTransaction({
    required this.id,
    required this.from,
    required this.to,
    required this.asset,
    required this.amount,
    BigInt? fee,
    required this.type,
    required this.status,
    required this.timestamp,
    this.memo,
  }) : fee = fee ?? BigInt.zero {
    if (id.isEmpty) {
      throw ArgumentError('Transaction id cannot be empty');
    }
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
  }

  final String id;
  final String from;
  final String to;
  final Asset asset;
  final BigInt amount;
  final BigInt fee;
  final TxType type;
  final TxStatus status;
  final DateTime timestamp;
  final String? memo;

  /// Total debit for a send: amount plus fee. For a receive it is
  /// just the amount (the sender paid the fee).
  BigInt get totalDebit => type == TxType.send ? amount + fee : amount;

  Map<String, Object?> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'asset': asset.toJson(),
        'amount': amount.toString(),
        'fee': fee.toString(),
        'type': type.name,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        if (memo != null) 'memo': memo,
      };

  factory WalletTransaction.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final from = json['from'];
    final to = json['to'];
    final assetJson = json['asset'];
    final amount = json['amount'];
    final fee = json['fee'];
    final type = json['type'];
    final status = json['status'];
    final timestamp = json['timestamp'];
    final memo = json['memo'];
    if (id is! String ||
        from is! String ||
        to is! String ||
        assetJson is! Map<String, Object?> ||
        amount is! String ||
        fee is! String ||
        type is! String ||
        status is! String ||
        timestamp is! String ||
        (memo != null && memo is! String)) {
      throw ArgumentError('Invalid transaction JSON: $json');
    }
    return WalletTransaction(
      id: id,
      from: from,
      to: to,
      asset: Asset.fromJson(assetJson),
      amount: BigInt.parse(amount),
      fee: BigInt.parse(fee),
      type: TxType.values.byName(type),
      status: TxStatus.values.byName(status),
      timestamp: DateTime.parse(timestamp),
      memo: memo as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WalletTransaction &&
      other.id == id &&
      other.from == from &&
      other.to == to &&
      other.asset == asset &&
      other.amount == amount &&
      other.fee == fee &&
      other.type == type &&
      other.status == status &&
      other.timestamp == timestamp &&
      other.memo == memo;

  @override
  int get hashCode => Object.hash(
        id,
        from,
        to,
        asset,
        amount,
        fee,
        type,
        status,
        timestamp,
        memo,
      );
}
