import 'package:flutter/foundation.dart';

class ChartViewport extends ChangeNotifier {
  double _startIndex;
  double _endIndex;
  final int _totalCandles;

  double _minPrice = 0;
  double _maxPrice = 100;
  double _minVolume = 0;
  double _maxVolume = 0;

  ChartViewport({
    required int candleCount,
    int visibleCandles = 60,
  })  : _totalCandles = candleCount,
        _startIndex = (candleCount - visibleCandles).clamp(0, candleCount - 1).toDouble(),
        _endIndex = candleCount.toDouble();

  double get startIndex => _startIndex;
  double get endIndex => _endIndex;
  int get totalCandles => _totalCandles;

  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  double get minVolume => _minVolume;
  double get maxVolume => _maxVolume;

  int get visibleCandleCount => (_endIndex - _startIndex).toInt();

  int get startIndexInt => _startIndex.floor().clamp(0, _totalCandles - 1);
  int get endIndexInt => _endIndex.ceil().clamp(1, _totalCandles);

  void updatePriceRange(double min, double max) {
    final padding = (max - min) * 0.1;
    _minPrice = min - padding;
    _maxPrice = max + padding;
  }

  void updateVolumeRange(double min, double max) {
    _minVolume = min;
    _maxVolume = max * 1.1;
  }

  void zoom(double factor, double focalPointRatio) {
    final range = _endIndex - _startIndex;
    final focalPoint = _startIndex + range * focalPointRatio;

    final newRange = (range / factor).clamp(10, _totalCandles.toDouble());
    final halfRange = newRange / 2;

    _startIndex = (focalPoint - halfRange).clamp(0, _totalCandles - 10);
    _endIndex = (_startIndex + newRange).clamp(10, _totalCandles.toDouble());

    if (_endIndex > _totalCandles) {
      _endIndex = _totalCandles.toDouble();
      _startIndex = (_endIndex - newRange).clamp(0, _totalCandles - 10);
    }

    notifyListeners();
  }

  void pan(double deltaCandles) {
    final range = _endIndex - _startIndex;
    final newStart = (_startIndex + deltaCandles).clamp(0.0, (_totalCandles - range).toDouble());
    final newEnd = newStart + range;

    if (newEnd <= _totalCandles) {
      _startIndex = newStart;
      _endIndex = newEnd;
      notifyListeners();
    }
  }

  void scrollToEnd() {
    final range = _endIndex - _startIndex;
    _endIndex = _totalCandles.toDouble();
    _startIndex = _endIndex - range;
    notifyListeners();
  }

  void setVisibleRange(double start, double end) {
    _startIndex = start.clamp(0, _totalCandles - 10);
    _endIndex = end.clamp(10, _totalCandles.toDouble());
    notifyListeners();
  }
}
