import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'derivation.dart';
import 'hex.dart';
import 'unsigned_transaction.dart';

/// Demo signing for unsigned transactions.
///
/// This is NOT ECDSA and NOT a real Ethereum signature: the signature
/// is HMAC-SHA256 of the signing payload keyed by the private key, so
/// verifying needs the same key — it proves possession of the key in
/// this demo, but it is not publicly verifiable and must never be used
/// for real funds. A signature also only matches when the signer's
/// derived address equals the transaction's sender; signing someone
/// else's transaction is rejected outright.
class SignedTransaction {
  SignedTransaction({required this.unsigned, required this.signature});

  final UnsignedTransaction unsigned;
  final String signature;

  static SignedTransaction sign(UnsignedTransaction tx, DerivedKey key) {
    if (key.address != tx.from) {
      throw ArgumentError(
        'Signer ${key.address} does not match sender ${tx.from}',
      );
    }
    final mac = Hmac(sha256, key.privateKeyBytes)
        .convert(utf8.encode(tx.signingPayload))
        .bytes;
    return SignedTransaction(unsigned: tx, signature: bytesToHex(mac));
  }

  /// True when [key] re-creates this signature for the payload and
  /// belongs to the transaction's sender.
  bool verify(DerivedKey key) {
    if (key.address != unsigned.from) return false;
    final expected = sign(unsigned, key);
    return expected.signature == signature;
  }

  Map<String, Object?> toJson() => {
        'unsigned': unsigned.toJson(),
        'signature': signature,
      };

  factory SignedTransaction.fromJson(Map<String, Object?> json) {
    final unsignedJson = json['unsigned'];
    final signature = json['signature'];
    if (unsignedJson is! Map<String, Object?> || signature is! String) {
      throw ArgumentError('Invalid signed transaction JSON: $json');
    }
    return SignedTransaction(
      unsigned: UnsignedTransaction.fromJson(unsignedJson),
      signature: signature,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SignedTransaction &&
      other.unsigned == unsigned &&
      other.signature == signature;

  @override
  int get hashCode => Object.hash(unsigned, signature);
}
