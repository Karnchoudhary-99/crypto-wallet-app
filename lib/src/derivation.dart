import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'hex.dart';
import 'seed_phrase.dart';
import 'wallet.dart';

/// Deterministic, hash-based key derivation for demo wallets.
///
/// This is NOT BIP-32/BIP-44: there is no secp256k1 elliptic-curve math
/// here, and derived keys cannot be imported into a real wallet. The
/// scheme is deterministic (same phrase + index always yields the same
/// key), distinct per index, and easy to test — which is all a demo
/// wallet needs. Never use it for real funds.
///
/// Scheme: master = HMAC-SHA512("crypto-wallet-app seed", seedBytes);
/// the master private key is the first 32 bytes reduced modulo the
/// secp256k1 curve order (kept in range only — no curve point is ever
/// computed). Account i > 0 is SHA-256(master key bytes || i as
/// big-endian uint32), reduced the same way.
class DerivedKey {
  const DerivedKey({required this.privateKey, required this.index});

  static final _curveOrder = BigInt.parse(
    'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
    radix: 16,
  );

  static DerivedKey derive(List<int> seedBytes, int index) {
    if (index < 0) {
      throw ArgumentError('Account index cannot be negative: $index');
    }
    final master = Hmac(sha512, utf8.encode('crypto-wallet-app seed'))
        .convert(seedBytes)
        .bytes;
    var key = bytesToBigInt(master.sublist(0, 32)) % _curveOrder;
    if (key == BigInt.zero) key = BigInt.one;
    if (index == 0) return DerivedKey(privateKey: key, index: 0);
    final indexBytes = [
      (index >> 24) & 0xff,
      (index >> 16) & 0xff,
      (index >> 8) & 0xff,
      index & 0xff,
    ];
    final child = sha256
        .convert([...bigIntToBytes(key, 32), ...indexBytes])
        .bytes;
    var childKey = bytesToBigInt(child) % _curveOrder;
    if (childKey == BigInt.zero) childKey = BigInt.one;
    return DerivedKey(privateKey: childKey, index: index);
  }

  static DerivedKey fromPhrase(SeedPhrase phrase, int index) =>
      derive(phrase.seedBytes, index);

  final BigInt privateKey;
  final int index;

  List<int> get privateKeyBytes => bigIntToBytes(privateKey, 32);

  String get privateKeyHex => bytesToHex(privateKeyBytes);

  /// Demo address: the last 20 bytes of SHA-256(private key), in the
  /// familiar `0x` + 40-hex form. This is NOT a real Ethereum address
  /// (that needs keccak-256 of a secp256k1 public key); it only reuses
  /// the wallet model's strict address format so accounts plug into
  /// the existing [Wallet] type.
  String get address {
    final digest = sha256.convert(privateKeyBytes).bytes;
    return '0x${bytesToHex(digest.sublist(12))}';
  }
}

/// A wallet account derived from a seed phrase: address plus balance.
class WalletAccount {
  factory WalletAccount.fromSeed(SeedPhrase phrase, int index) {
    final key = DerivedKey.fromPhrase(phrase, index);
    return WalletAccount._(key, Wallet(address: key.address));
  }

  WalletAccount._(this.key, this.wallet);

  final DerivedKey key;
  final Wallet wallet;

  String get address => wallet.address;
}
