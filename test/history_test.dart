import 'package:crypto_wallet_app/crypto_wallet_app.dart';
import 'package:test/test.dart';

import 'transaction_test.dart' show sampleTx;

const _alice = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
const _bob = '0x1111111111111111111111111111111111111111';
const _carol = '0x2222222222222222222222222222222222222222';

WalletTransaction _tx({
  required String id,
  required DateTime at,
  TxType type = TxType.send,
  TxStatus status = TxStatus.confirmed,
  Asset? asset,
  String? memo,
}) {
  return WalletTransaction(
    id: id,
    from: _alice,
    to: type == TxType.send ? _bob : _carol,
    asset: asset ?? Asset.native,
    amount: BigInt.from(100),
    type: type,
    status: status,
    timestamp: at,
    memo: memo,
  );
}

TransactionHistory _sampleHistory() {
  final history = TransactionHistory();
  history.add(_tx(id: 't1', at: DateTime.utc(2026, 10, 23), memo: 'rent'));
  history.add(
    _tx(
      id: 't2',
      at: DateTime.utc(2026, 10, 25),
      type: TxType.receive,
      memo: 'salary',
    ),
  );
  history.add(
    _tx(
      id: 't3',
      at: DateTime.utc(2026, 10, 24),
      asset: Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6),
      status: TxStatus.pending,
    ),
  );
  return history;
}

void main() {
  group('TransactionHistory', () {
    test('orders newest first and rejects duplicate ids', () {
      final history = _sampleHistory();
      expect(history.all.map((tx) => tx.id).toList(), ['t2', 't3', 't1']);
      expect(history.length, 3);
      expect(() => history.add(_tx(id: 't1', at: DateTime.utc(2026, 10, 26))),
          throwsArgumentError);
      // sampleTx helper from transaction_test stays usable here.
      expect(sampleTx().id, 'tx-1');
    });

    test('filters by type, status, asset, counterparty and date range', () {
      final history = _sampleHistory();
      expect(
        history.filter(type: TxType.receive).map((tx) => tx.id).toList(),
        ['t2'],
      );
      expect(
        history.filter(status: TxStatus.pending).map((tx) => tx.id).toList(),
        ['t3'],
      );
      expect(
        history
            .filter(
              asset: Asset(symbol: 'USDC', name: 'USD Coin', decimals: 6),
            )
            .map((tx) => tx.id)
            .toList(),
        ['t3'],
      );
      expect(
        history.filter(counterparty: _carol).map((tx) => tx.id).toList(),
        ['t2'],
      );
      expect(
        history
            .filter(
              from: DateTime.utc(2026, 10, 24),
              to: DateTime.utc(2026, 10, 24, 23, 59),
            )
            .map((tx) => tx.id)
            .toList(),
        ['t3'],
      );
    });

    test('searches memos case-insensitively and pages newest first', () {
      final history = _sampleHistory();
      expect(
        history.searchMemo('SALARY').map((tx) => tx.id).toList(),
        ['t2'],
      );
      expect(history.searchMemo('missing'), isEmpty);
      expect(
        history.page(page: 0, pageSize: 2).map((tx) => tx.id).toList(),
        ['t2', 't3'],
      );
      expect(
        history.page(page: 1, pageSize: 2).map((tx) => tx.id).toList(),
        ['t1'],
      );
      expect(history.page(page: 5, pageSize: 2), isEmpty);
      expect(() => history.page(page: -1), throwsArgumentError);
      expect(() => history.page(pageSize: 0), throwsArgumentError);
    });
  });
}
