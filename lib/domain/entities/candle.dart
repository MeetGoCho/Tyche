import 'package:equatable/equatable.dart';

class Candle extends Equatable {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double? vwap;
  final DateTime timestamp;
  final int? transactions;

  const Candle({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.vwap,
    required this.timestamp,
    this.transactions,
  });

  bool get isBullish => close >= open;
  bool get isBearish => close < open;

  double get bodySize => (close - open).abs();
  double get upperWick => high - (isBullish ? close : open);
  double get lowerWick => (isBullish ? open : close) - low;
  double get range => high - low;

  double get changePercent {
    if (open == 0) return 0;
    return ((close - open) / open) * 100;
  }

  @override
  List<Object?> get props => [open, high, low, close, volume, vwap, timestamp, transactions];
}
