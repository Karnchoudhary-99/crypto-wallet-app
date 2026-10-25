import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'hex.dart';

/// Password-protected storage for a 32-byte private key, as a JSON string.
///
/// Format (version 1): `{"version":1,"salt":hex,"ciphertext":hex,
/// "mac":hex}`. The password key is SHA-256 iterated 1000 times over
/// (password bytes + salt); the keystream is SHA-256(key || block
/// counter) XORed with the key bytes; the MAC is SHA-256(key ||
/// ciphertext) and is verified before decryption.
///
/// This is demo-grade encryption — a stretched SHA-256 key and a
/// hand-rolled XOR stream, not AES-GCM or scrypt — and it must never
/// protect real funds. It demonstrates the keystore shape (salt, MAC,
/// wrong-password rejection) without extra dependencies.
class Keystore {
  static const _iterations = 1000;

  static List<int> _deriveKey(String password, List<int> salt) {
    var key = sha256.convert([...utf8.encode(password), ...salt]).bytes;
    for (var i = 1; i < _iterations; i++) {
      key = sha256.convert(key).bytes;
    }
    return key;
  }

  static String encrypt({
    required List<int> privateKeyBytes,
    required String password,
    List<int>? salt,
  }) {
    if (privateKeyBytes.length != 32) {
      throw ArgumentError(
        'Private key must be 32 bytes, got ${privateKeyBytes.length}',
      );
    }
    if (password.isEmpty) {
      throw ArgumentError('Keystore password cannot be empty');
    }
    final saltBytes = salt ??
        List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final key = _deriveKey(password, saltBytes);
    final keystream = sha256.convert([...key, 0, 0, 0, 0]).bytes;
    final ciphertext = [
      for (var i = 0; i < privateKeyBytes.length; i++)
        privateKeyBytes[i] ^ keystream[i],
    ];
    final mac = sha256.convert([...key, ...ciphertext]).bytes;
    return jsonEncode({
      'version': 1,
      'salt': bytesToHex(saltBytes),
      'ciphertext': bytesToHex(ciphertext),
      'mac': bytesToHex(mac),
    });
  }

  /// Decrypts a keystore JSON string. Throws [ArgumentError] on a bad
  /// format, a wrong password, or tampered ciphertext (MAC mismatch).
  static List<int> decrypt(String keystoreJson, String password) {
    final decoded = jsonDecode(keystoreJson);
    if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
      throw ArgumentError('Unsupported keystore format');
    }
    final salt = hexToBytes(decoded['salt'] as String);
    final ciphertext = hexToBytes(decoded['ciphertext'] as String);
    final expectedMac = decoded['mac'] as String;
    final key = _deriveKey(password, salt);
    final actualMac = bytesToHex(sha256.convert([...key, ...ciphertext]).bytes);
    if (actualMac != expectedMac) {
      throw ArgumentError(
        'Keystore authentication failed: wrong password or tampered data',
      );
    }
    final keystream = sha256.convert([...key, 0, 0, 0, 0]).bytes;
    return [
      for (var i = 0; i < ciphertext.length; i++)
        ciphertext[i] ^ keystream[i],
    ];
  }
}
