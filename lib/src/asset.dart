/// A fungible asset a wallet can hold, e.g. a native coin or a token.
///
/// An [Asset] is identified by its [symbol]; [decimals] says how many
/// decimal places one whole unit has in the smallest unit (0 for a
/// whole-unit-only asset, 18 for an ether-like one). Prices are out of
/// scope on purpose: this module tracks *holdings*, not market value.
class Asset {
  Asset({required this.symbol, required this.name, required this.decimals}) {
    if (!RegExp(r'^[A-Z0-9]{1,10}$').hasMatch(symbol)) {
      throw ArgumentError(
        'Asset symbol must be 1-10 uppercase letters/digits: $symbol',
      );
    }
    if (name.isEmpty) {
      throw ArgumentError('Asset name cannot be empty');
    }
    if (decimals < 0 || decimals > 18) {
      throw ArgumentError('Asset decimals must be between 0 and 18: $decimals');
    }
  }

  final String symbol;
  final String name;
  final int decimals;

  /// The native coin of this demo wallet: 18 decimals, like ether.
  static Asset get native =>
      Asset(symbol: 'ETH', name: 'Ether', decimals: 18);

  Map<String, Object?> toJson() => {
        'symbol': symbol,
        'name': name,
        'decimals': decimals,
      };

  factory Asset.fromJson(Map<String, Object?> json) {
    final symbol = json['symbol'];
    final name = json['name'];
    final decimals = json['decimals'];
    if (symbol is! String || name is! String || decimals is! int) {
      throw ArgumentError('Invalid asset JSON: $json');
    }
    return Asset(symbol: symbol, name: name, decimals: decimals);
  }

  @override
  bool operator ==(Object other) =>
      other is Asset &&
      other.symbol == symbol &&
      other.name == name &&
      other.decimals == decimals;

  @override
  int get hashCode => Object.hash(symbol, name, decimals);

  @override
  String toString() => '$symbol ($name, $decimals decimals)';
}
