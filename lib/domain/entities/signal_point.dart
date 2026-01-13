/// Type of trading signal
enum SignalType {
  buy,
  sell,
}

/// A single trading signal point
class SignalPoint {
  /// Timestamp of the signal
  final DateTime timestamp;

  /// Index of the candle where signal occurred
  final int candleIndex;

  /// Type of signal (buy/sell)
  final SignalType type;

  /// Confidence level (0-100)
  final double confidence;

  /// Optional reason/description for the signal
  final String? reason;

  const SignalPoint({
    required this.timestamp,
    required this.candleIndex,
    required this.type,
    required this.confidence,
    this.reason,
  });

  /// Check if this signal is recent (within specified number of candles from end)
  bool isRecentFrom(int totalCandles, {int threshold = 5}) {
    return totalCandles - candleIndex <= threshold;
  }

  /// Get display color for this signal
  bool get isBuy => type == SignalType.buy;
  bool get isSell => type == SignalType.sell;

  @override
  String toString() {
    return 'SignalPoint(index: $candleIndex, type: $type, confidence: ${confidence.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignalPoint &&
        other.candleIndex == candleIndex &&
        other.type == type;
  }

  @override
  int get hashCode => candleIndex.hashCode ^ type.hashCode;
}

/// Collection of signals for a strategy
class SignalHistory {
  final List<SignalPoint> signals;
  final String strategyName;
  final DateTime calculatedAt;

  const SignalHistory({
    required this.signals,
    required this.strategyName,
    required this.calculatedAt,
  });

  /// Get buy signals only
  List<SignalPoint> get buySignals =>
      signals.where((s) => s.type == SignalType.buy).toList();

  /// Get sell signals only
  List<SignalPoint> get sellSignals =>
      signals.where((s) => s.type == SignalType.sell).toList();

  /// Get recent signals (within threshold candles from end)
  List<SignalPoint> getRecentSignals(int totalCandles, {int threshold = 5}) {
    return signals.where((s) => s.isRecentFrom(totalCandles, threshold: threshold)).toList();
  }

  /// Get signal at specific candle index if exists
  SignalPoint? getSignalAt(int index) {
    try {
      return signals.firstWhere((s) => s.candleIndex == index);
    } catch (_) {
      return null;
    }
  }

  /// Check if there's a signal at specific index
  bool hasSignalAt(int index) => signals.any((s) => s.candleIndex == index);

  /// Get the most recent signal
  SignalPoint? get mostRecent {
    if (signals.isEmpty) return null;
    return signals.reduce((a, b) => a.candleIndex > b.candleIndex ? a : b);
  }

  /// Signal count summary
  int get totalCount => signals.length;
  int get buyCount => buySignals.length;
  int get sellCount => sellSignals.length;
}
