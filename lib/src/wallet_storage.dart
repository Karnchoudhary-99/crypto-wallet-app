import 'dart:convert';
import 'dart:io';

import 'wallet_data.dart';

/// Saves and loads a whole wallet to a single JSON file on disk.
///
/// Files are written atomically-ish: the JSON goes to a temporary
/// sibling file first and is then renamed over the target, so a crash
/// mid-write never leaves a half-written wallet file behind. Loading
/// a missing file or malformed JSON throws [ArgumentError] with the
/// path attached, rather than silently returning an empty wallet.
class WalletStorage {
  const WalletStorage();

  void save(WalletData data, String path) {
    final file = File(path);
    final temp = File('$path.tmp');
    temp.writeAsStringSync(jsonEncode(data.toJson()));
    temp.renameSync(file.path);
  }

  WalletData load(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw ArgumentError('Wallet file not found: $path');
    }
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map) {
      throw ArgumentError('Wallet file is not a JSON object: $path');
    }
    try {
      return WalletData.fromJson(Map<String, Object?>.from(decoded));
    } on ArgumentError {
      throw ArgumentError('Wallet file has invalid contents: $path');
    }
  }
}
