import 'dart:convert';
import 'dart:math';

import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

void main() {
  group('SeedPhrase', () {
    test('generates 12- and 24-word phrases from the wordlist', () {
      final twelve = SeedPhrase.generate(words: 12, random: Random(42));
      expect(twelve.words, hasLength(12));
      expect(twelve.words.every(kWordlist.contains), isTrue);
      expect(SeedPhrase.isValid(twelve.phrase), isTrue);

      final twentyFour = SeedPhrase.generate(words: 24, random: Random(7));
      expect(twentyFour.words, hasLength(24));
      expect(SeedPhrase.isValid(twentyFour.phrase), isTrue);
    });

    test('round-trips through fromPhrase', () {
      final phrase = SeedPhrase.generate(random: Random(1));
      expect(SeedPhrase.fromPhrase(phrase.phrase).phrase, phrase.phrase);
    });

    test('rejects unknown words, wrong counts and bad checksums', () {
      expect(SeedPhrase.isValid('apple banana'), isFalse);
      final phrase = SeedPhrase.generate(random: Random(2));
      // Change a non-checksum word: the stored checksum no longer matches.
      final tamperedWord = List<String>.from(phrase.words);
      tamperedWord[0] = tamperedWord[0] == 'apple' ? 'banana' : 'apple';
      expect(SeedPhrase.isValid(tamperedWord.join(' ')), isFalse);
      // Swap the checksum word for a different wordlist word.
      final words = List<String>.from(phrase.words);
      words[words.length - 1] =
          words.last == 'apple' ? 'banana' : 'apple';
      expect(SeedPhrase.isValid(words.join(' ')), isFalse);
      expect(
        () => SeedPhrase(List.filled(11, 'apple')),
        throwsArgumentError,
      );
    });

    test('seed bytes are stable for a phrase', () {
      final phrase = SeedPhrase.generate(random: Random(3));
      expect(
        bytesToHex(phrase.seedBytes),
        bytesToHex(SeedPhrase.fromPhrase(phrase.phrase).seedBytes),
      );
    });
  });

  group('DerivedKey', () {
    test('is deterministic per phrase and index', () {
      final phrase = SeedPhrase.generate(random: Random(4));
      final a = DerivedKey.fromPhrase(phrase, 0);
      final b = DerivedKey.fromPhrase(phrase, 0);
      expect(a.privateKeyHex, b.privateKeyHex);
      expect(a.address, b.address);
      expect(Wallet.isValidAddress(a.address), isTrue);
    });

    test('differs across indices and phrases', () {
      final phrase = SeedPhrase.generate(random: Random(5));
      final other = SeedPhrase.generate(random: Random(6));
      expect(
        DerivedKey.fromPhrase(phrase, 0).privateKeyHex,
        isNot(DerivedKey.fromPhrase(phrase, 1).privateKeyHex),
      );
      expect(
        DerivedKey.fromPhrase(phrase, 0).privateKeyHex,
        isNot(DerivedKey.fromPhrase(other, 0).privateKeyHex),
      );
    });

    test('rejects a negative index', () {
      final phrase = SeedPhrase.generate(random: Random(7));
      expect(() => DerivedKey.fromPhrase(phrase, -1), throwsArgumentError);
    });

    test('WalletAccount address matches its derived key', () {
      final phrase = SeedPhrase.generate(random: Random(8));
      final account = WalletAccount.fromSeed(phrase, 2);
      expect(account.address, DerivedKey.fromPhrase(phrase, 2).address);
      expect(account.wallet.formattedBalance, '0');
    });
  });

  group('Keystore', () {
    test('round-trips a private key with a fixed salt', () {
      final phrase = SeedPhrase.generate(random: Random(9));
      final key = DerivedKey.fromPhrase(phrase, 0);
      final salt = List<int>.generate(16, (i) => i);
      final stored = Keystore.encrypt(
        privateKeyBytes: key.privateKeyBytes,
        password: 'correct horse battery staple',
        salt: salt,
      );
      expect(Keystore.decrypt(stored, 'correct horse battery staple'),
          key.privateKeyBytes);
    });

    test('rejects a wrong password and tampered ciphertext', () {
      final phrase = SeedPhrase.generate(random: Random(10));
      final key = DerivedKey.fromPhrase(phrase, 0);
      final stored = Keystore.encrypt(
        privateKeyBytes: key.privateKeyBytes,
        password: 'hunter2',
      );
      expect(() => Keystore.decrypt(stored, 'wrong-password'),
          throwsArgumentError);
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final cipher = decoded['ciphertext'] as String;
      decoded['ciphertext'] =
          (cipher[0] == '0' ? '1' : '0') + cipher.substring(1);
      expect(() => Keystore.decrypt(jsonEncode(decoded), 'hunter2'),
          throwsArgumentError);
    });

    test('rejects empty passwords and non-32-byte keys', () {
      expect(
        () => Keystore.encrypt(privateKeyBytes: List.filled(32, 0),
            password: ''),
        throwsArgumentError,
      );
      expect(
        () => Keystore.encrypt(
            privateKeyBytes: List.filled(16, 0), password: 'x'),
        throwsArgumentError,
      );
    });
  });

  group('hex helpers', () {
    test('round-trip bytes and reject bad hex', () {
      expect(bytesToHex(hexToBytes('00ff10')), '00ff10');
      expect(() => hexToBytes('zz'), throwsArgumentError);
      expect(() => hexToBytes('abc'), throwsArgumentError);
    });
  });
}
