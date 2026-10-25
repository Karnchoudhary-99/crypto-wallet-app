import 'asset.dart';
import 'unsigned_transaction.dart';

/// Fluent builder for an [UnsignedTransaction], with sane defaults.
///
/// Fee defaults to zero and nonce to zero, so the minimal call is
/// `from` + `to` + `asset` + `amount`; every missing required field is
/// reported by [build] instead of failing halfway through a chain.
class TransactionBuilder {
  String? _from;
  String? _to;
  Asset? _asset;
  BigInt? _amount;
  BigInt _fee = BigInt.zero;
  int _nonce = 0;

  TransactionBuilder from(String address) {
    _from = address;
    return this;
  }

  TransactionBuilder to(String address) {
    _to = address;
    return this;
  }

  TransactionBuilder asset(Asset asset) {
    _asset = asset;
    return this;
  }

  TransactionBuilder amount(BigInt amount) {
    _amount = amount;
    return this;
  }

  TransactionBuilder fee(BigInt fee) {
    _fee = fee;
    return this;
  }

  TransactionBuilder nonce(int nonce) {
    _nonce = nonce;
    return this;
  }

  UnsignedTransaction build() {
    final from = _from;
    final to = _to;
    final asset = _asset;
    final amount = _amount;
    if (from == null) throw StateError('TransactionBuilder: from is unset');
    if (to == null) throw StateError('TransactionBuilder: to is unset');
    if (asset == null) throw StateError('TransactionBuilder: asset is unset');
    if (amount == null) {
      throw StateError('TransactionBuilder: amount is unset');
    }
    return UnsignedTransaction(
      from: from,
      to: to,
      asset: asset,
      amount: amount,
      fee: _fee,
      nonce: _nonce,
    );
  }
}
