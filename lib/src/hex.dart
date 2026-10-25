/// Small hex helpers shared by key derivation and the keystore.

String bytesToHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

List<int> hexToBytes(String hex) {
  final clean = hex.toLowerCase();
  if (clean.length.isOdd || !RegExp(r'^[0-9a-f]*$').hasMatch(clean)) {
    throw ArgumentError('Invalid hex string: $hex');
  }
  final out = <int>[];
  for (var i = 0; i < clean.length; i += 2) {
    out.add(int.parse(clean.substring(i, i + 2), radix: 16));
  }
  return out;
}

/// A [BigInt] as exactly [length] big-endian bytes.
List<int> bigIntToBytes(BigInt value, int length) {
  final hex = value.toRadixString(16).padLeft(length * 2, '0');
  return hexToBytes(hex);
}

BigInt bytesToBigInt(List<int> bytes) =>
    BigInt.parse(bytesToHex(bytes), radix: 16);
