/// Per-address sequence numbers for transaction building.
///
/// A fresh address starts at nonce 0. [consume] hands out the next
/// nonce and advances it, so two transactions built in a row never
/// share a nonce; [peek] reads without advancing, for display or for
/// building a transaction that is not sent yet.
class NonceTracker {
  final Map<String, int> _next = {};

  int peek(String address) => _next[address] ?? 0;

  int consume(String address) {
    final nonce = peek(address);
    _next[address] = nonce + 1;
    return nonce;
  }

  void reset(String address) => _next.remove(address);
}
