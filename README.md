# Crypto Wallet App

A crypto wallet app in Dart: key management, addresses, balances and
transactions — built as a dependency-light Dart package with a CLI demo.

> Demo scope only: this project is a portfolio build for learning and
> demonstration. Do not use it to hold real funds.

## Roadmap

- [x] Project scaffold (Dart package layout, CI, wallet model + CLI demo)
- [x] Key management (seed phrases, key derivation, password keystore)
- [x] Multi-asset balances (Asset, AssetBalance, Portfolio)
- [x] Transaction history (WalletTransaction, TransactionHistory, summary, CSV)
- [x] Transaction building + signing (UnsignedTransaction, builder, demo signing, nonces)
- [x] Local storage + import/export (WalletData, WalletStorage, merge)
- [x] Self-review checklist, then public

## Quick start

```bash
dart pub get
dart test
dart run crypto_wallet_app balances
dart run crypto_wallet_app history
dart run crypto_wallet_app build "apple banana cherry mango lemon grape peach pear plum melon kiwi golden" 0 0x1111111111111111111111111111111111111111 1000000000000000000
dart run crypto_wallet_app store /tmp/demo-wallet.json
dart run crypto_wallet_app 0x742d35Cc6634C0532925a3b844Bc454e4438f44e 1500000000000000000
dart run crypto_wallet_app new
dart run crypto_wallet_app derive "apple banana cherry mango lemon grape peach pear plum melon kiwi golden" 0
```

## Key management

- **Seed phrases** (`lib/src/seed_phrase.dart`): 12 or 24 words from a
  custom 128-word list (`lib/src/wordlist.dart`), with a checksum word
  (last word = sum of earlier word indices mod 128). Phrases are
  validated on construction; tampered or unknown words are rejected.
- **Key derivation** (`lib/src/derivation.dart`): deterministic per
  phrase + account index. The master key is HMAC-SHA512 of the phrase
  seed; account *i* is SHA-256 of the master key plus the index.
  Addresses are the last 20 bytes of SHA-256 of the private key, in
  `0x` + 40-hex form, so they plug into the existing `Wallet` model.
- **Keystore** (`lib/src/keystore.dart`): a 32-byte private key stored
  as JSON with a random salt, an XOR keystream from a 1000-times
  iterated SHA-256 password key, and a SHA-256 MAC. Decryption with a
  wrong password or tampered ciphertext fails on the MAC check.

## Multi-asset balances

- **Asset** (`lib/src/asset.dart`): symbol, name and decimals (0–18),
  validated on construction and JSON-serializable.
- **AssetBalance** (`lib/src/asset_balance.dart`): an amount in the
  asset's smallest unit, formatted per that asset's decimals, with
  same-asset add/subtract (subtracting below zero is rejected).
- **Portfolio** (`lib/src/portfolio.dart`): holdings keyed by symbol.
  Repeated adds merge, subtracting to zero drops the asset, unknown
  assets read as zero, and the whole portfolio round-trips through JSON.
  `dart run crypto_wallet_app balances` prints a sample portfolio
  (1.5 ETH, 250 USDC).

## Transaction history

- **WalletTransaction** (`lib/src/transaction.dart`): send/receive with
  from/to addresses, asset, amount and fee (a send debits amount + fee),
  pending/confirmed/failed status, timestamp and optional memo.
- **TransactionHistory** (`lib/src/transaction_history.dart`): unique-id
  storage, newest-first views, filters (asset, type, status,
  counterparty, date range), case-insensitive memo search, paging and
  RFC 4180 CSV export, plus JSON round-trips.
- **HistorySummary** (`lib/src/history_summary.dart`): counts per status
  and confirmed sent/received totals per asset (pending/failed never
  count toward totals).
- **Portfolio.applyTransaction** applies a confirmed transaction to
  holdings — sends debit amount + fee, receives credit the amount;
  pending transactions are ignored and failed ones rejected.
  `dart run crypto_wallet_app history` prints a sample history.

## Transaction building + signing

- **UnsignedTransaction** (`lib/src/unsigned_transaction.dart`): sender,
  recipient, asset, amount, fee and nonce, with a canonical signing
  payload covering every field and JSON round-trips.
- **TransactionBuilder** (`lib/src/transaction_builder.dart`): fluent
  builder with zero fee/nonce defaults and explicit errors for missing
  required fields.
- **SignedTransaction** (`lib/src/signing.dart`): demo signing — HMAC-SHA256
  of the payload keyed by the private key, verified only by the same key,
  and rejected unless the signer is the transaction's sender.
- **NonceTracker** (`lib/src/nonce_tracker.dart`): per-address sequence
  numbers with peek/consume/reset, so consecutive builds never reuse a nonce.
- `dart run crypto_wallet_app build …` derives an account, builds, signs
  and verifies a transaction; `examples/build_tx.dart` runs the full flow
  end to end (build → sign → apply to a portfolio → record in history).

Signing here is demo-grade HMAC, NOT ECDSA — it is not publicly
verifiable and must never be used for real funds.

## Local storage + import/export

- **WalletData** (`lib/src/wallet_data.dart`): a whole wallet — portfolio
  plus history — as one JSON object, with a merge that sums holdings
  and adds only transactions not already known by id (merge combines
  distinct wallets; restoring a saved wallet is a plain fromJson, since
  merging the same export twice would double-count holdings).
- **WalletStorage** (`lib/src/wallet_storage.dart`): saves that JSON to
  a file via a temp-file rename (no half-written files) and loads it
  back with path-attached errors for missing or malformed files.
  `dart run crypto_wallet_app store <file>` saves a sample wallet and
  reloads it to prove the round-trip.

**Honest limits:** this is NOT BIP-39, NOT BIP-32, and NOT a real
Ethereum address (no secp256k1, no keccak-256). Nothing derived here
can be imported into a real wallet, and the keystore is demo-grade
encryption, not AES-GCM. The point is a complete, tested key-management
shape — generation, derivation, storage — not custody of real funds.

## License

MIT
