/// Crypto wallet core: address validation, seed phrases, key derivation
/// and password-protected key storage.
///
/// Key management here is demo-grade by design: a custom wordlist (not
/// BIP-39), hash-based derivation (not BIP-32/secp256k1) and a
/// SHA-256-based keystore (not AES-GCM). Never use it for real funds;
/// see each module's docs for exactly what is and is not real.
library;

export 'src/asset.dart';
export 'src/asset_balance.dart';
export 'src/portfolio.dart';
export 'src/transaction.dart';
export 'src/derivation.dart';
export 'src/hex.dart';
export 'src/keystore.dart';
export 'src/seed_phrase.dart';
export 'src/wallet.dart';
export 'src/wordlist.dart';
