import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'wordlist.dart';

/// A demo seed phrase: 12 or 24 words from [kWordlist].
///
/// Format: the first n - 1 words are random; the last word is a checksum
/// word whose index is the sum of the earlier indices modulo the wordlist
/// length. [isValid] / the validating constructor reject a phrase with a
/// wrong word count, an unknown word, or a checksum mismatch.
///
/// This format is custom — it is NOT BIP-39, and it must never be used
/// to hold real funds. It exists so the rest of the wallet (derivation,
/// keystore, signing) can be built and tested without a real wallet.
class SeedPhrase {
  SeedPhrase(this.words) {
    if (words.length != 12 && words.length != 24) {
      throw ArgumentError(
        'Seed phrase must have 12 or 24 words, got ${words.length}',
      );
    }
    for (final word in words) {
      if (!kWordlist.contains(word)) {
        throw ArgumentError('Unknown seed word: $word');
      }
    }
    if (words.last != _checksumWord(words.sublist(0, words.length - 1))) {
      throw ArgumentError('Seed phrase checksum word does not match');
    }
  }

  factory SeedPhrase.fromPhrase(String phrase) =>
      SeedPhrase(phrase.trim().split(RegExp(r'\s+')));

  /// Generates a fresh phrase. [random] exists for tests; by default a
  /// cryptographically secure random source is used.
  static SeedPhrase generate({int words = 12, Random? random}) {
    if (words != 12 && words != 24) {
      throw ArgumentError('Seed phrase must have 12 or 24 words, got $words');
    }
    final rng = random ?? Random.secure();
    final picked = List<String>.generate(
      words - 1,
      (_) => kWordlist[rng.nextInt(kWordlist.length)],
    );
    return SeedPhrase([...picked, _checksumWord(picked)]);
  }

  static String _checksumWord(List<String> words) {
    var sum = 0;
    for (final word in words) {
      sum += kWordlist.indexOf(word);
    }
    return kWordlist[sum % kWordlist.length];
  }

  final List<String> words;

  String get phrase => words.join(' ');

  /// Seed bytes for key derivation: SHA-256 of the phrase text.
  List<int> get seedBytes => sha256.convert(utf8.encode(phrase)).bytes;

  static bool isValid(String phrase) {
    try {
      SeedPhrase.fromPhrase(phrase);
      return true;
    } on ArgumentError {
      return false;
    }
  }
}
