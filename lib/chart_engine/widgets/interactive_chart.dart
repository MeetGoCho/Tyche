import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/candle.dart';
import '../../domain/entities/signal_point.dart';
import '../../core/theme/app_colors.dart';
import '../../core/extensions/num_extension.dart';
import '../../core/extensions/datetime_extension.dart';
import '../core/chart_config.dart';
import '../core/chart_viewport.dart';
import '../painters/grid_painter.dart';
import '../painters/candlestick_painter.dart';
import '../painters/volume_painter.dart';
import '../painters/crosshair_painter.dart';
import '../painters/indicator_overlay_painter.dart';
import '../painters/sub_indicator_painter.dart';
import '../painters/signal_painter.dart';
import '../indicators/moving_average.dart';
import '../indicators/bollinger_bands.dart';
import '../indicators/rsi.dart';
import '../indicators/macd.dart';
import '../indicators/momentum.dart';

class InteractiveChart extends StatefulWidget {
  final List<Candle> candles;
  final ChartConfig config;
  final ValueChanged<Candle>? onCandleSelected;
  final List<SignalPoint>? signals;

  const InteractiveChart({
    super.key,
    required this.candles,
    this.config = const ChartConfig(),
    this.onCandleSelected,
    this.signals,
  });

  @override
  State<InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<InteractiveChart> {
  late ChartViewport _viewport;
  Offset? _crosshairPosition;
  Candle? _selectedCandle;
  double _lastScale = 1.0;

  // Cached indicator data
  Map<String, List<double?>> _overlayIndicators = {};
  Map<String, List<double?>> _subIndicatorData = {};
  double _subIndicatorMin = 0;
  double _subIndicatorMax = 100;

  @override
  void initState() {
    super.initState();
    _initViewport();
    _calculateIndicators();
  }

  @override
  void didUpdateWidget(InteractiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candles.length != widget.candles.length) {
      _initViewport();
      _calculateIndicators();
    } else if (oldWidget.config.overlayIndicators != widget.config.overlayIndicators ||
        oldWidget.config.subIndicator != widget.config.subIndicator) {
      _calculateIndicators();
    }
  }

  void _initViewport() {
    _viewport = ChartViewport(
      candleCount: widget.candles.length,
      visibleCandles: min(60, widget.candles.length),
    );
    _viewport.addListener(_onViewportChanged);
    _updatePriceRange();
  }

  void _onViewportChanged() {
    _updatePriceRange();
    setState(() {});
  }

  void _calculateIndicators() {
    if (widget.candles.isEmpty) return;

    // Calculate overlay indicators
    _overlayIndicators.clear();

    for (final indicator in widget.config.overlayIndicators) {
      switch (indicator) {
        case OverlayIndicator.sma20:
          _overlayIndicators['SMA20'] = SMAIndicator(period: 20).calculate(widget.candles);
          break;
        case OverlayIndicator.sma50:
          _overlayIndicators['SMA50'] = SMAIndicator(period: 50).calculate(widget.candles);
          break;
        case OverlayIndicator.sma200:
          _overlayIndicators['SMA200'] = SMAIndicator(period: 200).calculate(widget.candles);
          break;
        case OverlayIndicator.ema20:
          _overlayIndicators['EMA20'] = EMAIndicator(period: 20).calculate(widget.candles);
          break;
        case OverlayIndicator.bollingerBands:
          final bb = BollingerBandsIndicator().calculateAll(widget.candles);
          _overlayIndicators['BB_upper'] = bb.upper;
          _overlayIndicators['BB_middle'] = bb.middle;
          _overlayIndicators['BB_lower'] = bb.lower;
          break;
      }
    }

    // Calculate sub indicator
    _subIndicatorData.clear();

    switch (widget.config.subIndicator) {
      case SubIndicator.rsi:
        _subIndicatorData['rsi'] = RSIIndicator(period: 14).calculate(widget.candles);
        _subIndicatorMin = 0;
        _subIndicatorMax = 100;
        break;
      case SubIndicator.macd:
        final macd = MACDIndicator().calculateAll(widget.candles);
        _subIndicatorData['macd'] = macd.macd;
        _subIndicatorData['signal'] = macd.signal;
        _subIndicatorData['histogram'] = macd.histogram;
        _calculateMacdRange(macd);
        break;
      case SubIndicator.stochasticRsi:
        final stoch = StochasticRSIIndicator().calculateAll(widget.candles);
        _subIndicatorData['k'] = stoch.k;
        _subIndicatorData['d'] = stoch.d;
        _subIndicatorMin = 0;
        _subIndicatorMax = 100;
        break;
      case SubIndicator.momentum:
        _subIndicatorData['momentum'] = MomentumIndicator(period: 10).calculate(widget.candles);
        _calculateMomentumRange();
        break;
      case null:
        break;
    }
  }

  void _calculateMacdRange(MACDResult macd) {
    double minVal = 0;
    double maxVal = 0;

    for (int i = 0; i < macd.macd.length; i++) {
      if (macd.macd[i] != null) {
        minVal = min(minVal, macd.macd[i]!);
        maxVal = max(maxVal, macd.macd[i]!);
      }
      if (macd.signal[i] != null) {
        minVal = min(minVal, macd.signal[i]!);
        maxVal = max(maxVal, macd.signal[i]!);
      }
      if (macd.histogram[i] != null) {
        minVal = min(minVal, macd.histogram[i]!);
        maxVal = max(maxVal, macd.histogram[i]!);
      }
    }

    final padding = (maxVal - minVal) * 0.1;
    _subIndicatorMin = minVal - padding;
    _subIndicatorMax = maxVal + padding;
  }

  void _calculateMomentumRange() {
    final momentum = _subIndicatorData['momentum'];
    if (momentum == null) return;

    double minVal = 0;
    double maxVal = 0;

    for (final v in momentum) {
      if (v != null) {
        minVal = min(minVal, v);
        maxVal = max(maxVal, v);
      }
    }

    final padding = (maxVal - minVal) * 0.1;
    _subIndicatorMin = minVal - padding;
    _subIndicatorMax = maxVal + padding;
  }

  void _updatePriceRange() {
    if (widget.candles.isEmpty) return;

    final start = _viewport.startIndexInt;
    final end = _viewport.endIndexInt;
    final visibleCandles = widget.candles.sublist(start, end);

    if (visibleCandles.isEmpty) return;

    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    double minVolume = double.infinity;
    double maxVolume = double.negativeInfinity;

    for (final candle in visibleCandles) {
      minPrice = min(minPrice, candle.low);
      maxPrice = max(maxPrice, candle.high);
      minVolume = min(minVolume, candle.volume);
      maxVolume = max(maxVolume, candle.volume);
    }

    // Extend price range to include visible indicators
    for (final values in _overlayIndicators.values) {
      for (int i = start; i < end && i < values.length; i++) {
        if (values[i] != null) {
          minPrice = min(minPrice, values[i]!);
          maxPrice = max(maxPrice, values[i]!);
        }
      }
    }

    _viewport.updatePriceRange(minPrice, maxPrice);
    _viewport.updateVolumeRange(minVolume, maxVolume);
  }

  @override
  void dispose() {
    _viewport.removeListener(_onViewportChanged);
    _viewport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final hasSubIndicator = widget.config.hasSubIndicator;

    return Column(
      children: [
        // 가격 정보 헤더
        if (_selectedCandle != null) _buildCandleInfo(_selectedCandle!),
        // 메인 차트
        Expanded(
          flex: hasSubIndicator ? 3 : (widget.config.showVolume ? 3 : 1),
          child: _buildMainChart(),
        ),
        // 보조 지표
        if (hasSubIndicator)
          Expanded(
            flex: 1,
            child: _buildSubIndicatorChart(),
          ),
        // 거래량 차트
        if (widget.config.showVolume)
          Expanded(
            flex: 1,
            child: _buildVolumeChart(),
          ),
      ],
    );
  }

  Widget _buildCandleInfo(Candle candle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Text(
            candle.timestamp.toDisplayFormat(),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 16),
          _InfoLabel('O', candle.open.toDecimal()),
          _InfoLabel('H', candle.high.toDecimal()),
          _InfoLabel('L', candle.low.toDecimal()),
          _InfoLabel('C', candle.close.toDecimal(), color: candle.isBullish ? AppColors.bullish : AppColors.bearish),
        ],
      ),
    );
  }

  Widget _buildMainChart() {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RepaintBoundary(
            child: Stack(
              children: [
                // 그리드
                if (widget.config.showGrid)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GridPainter(
                      viewport: _viewport,
                      theme: widget.config.theme,
                    ),
                  ),
                // 캔들스틱
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: CandlestickPainter(
                    candles: widget.candles,
                    viewport: _viewport,
                    theme: widget.config.theme,
                  ),
                ),
                // 오버레이 지표
                if (_overlayIndicators.isNotEmpty)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: IndicatorOverlayPainter(
                      viewport: _viewport,
                      theme: widget.config.theme,
                      indicators: _overlayIndicators,
                    ),
                  ),
                // 매수/매도 신호
                if (widget.signals != null && widget.signals!.isNotEmpty)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: SignalPainter(
                      viewport: _viewport,
                      signals: widget.signals!,
                      totalCandles: widget.candles.length,
                    ),
                  ),
                // 크로스헤어
                if (_crosshairPosition != null)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CrosshairPainter(
                      position: _crosshairPosition!,
                      theme: widget.config.theme,
                      priceLabel: _selectedCandle?.close.toDecimal(),
                      timeLabel: _selectedCandle?.timestamp.toDisplayFormat(),
                    ),
                  ),
                // 가격 축 (오른쪽)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildPriceAxis(constraints.maxHeight),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubIndicatorChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: SubIndicatorPainter(
                viewport: _viewport,
                theme: widget.config.theme,
                type: _getSubIndicatorType(),
                data: _subIndicatorData,
                minValue: _subIndicatorMin,
                maxValue: _subIndicatorMax,
              ),
            ),
          ),
        );
      },
    );
  }

  SubIndicatorType _getSubIndicatorType() {
    switch (widget.config.subIndicator) {
      case SubIndicator.rsi:
        return SubIndicatorType.rsi;
      case SubIndicator.macd:
        return SubIndicatorType.macd;
      case SubIndicator.stochasticRsi:
        return SubIndicatorType.stochRsi;
      case SubIndicator.momentum:
        return SubIndicatorType.momentum;
      case null:
        return SubIndicatorType.rsi;
    }
  }

  Widget _buildVolumeChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: VolumePainter(
                candles: widget.candles,
                viewport: _viewport,
                theme: widget.config.theme,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceAxis(double height) {
    const labelCount = 5;
    final labels = <Widget>[];

    for (int i = 0; i <= labelCount; i++) {
      final price = _viewport.maxPrice -
          (_viewport.maxPrice - _viewport.minPrice) * i / labelCount;
      labels.add(
        Positioned(
          top: height * i / labelCount - 6,
          right: 4,
          child: Text(
            price.toDecimal(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 50,
      child: Stack(children: labels),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 2) {
      // 줌
      final scaleDiff = details.scale / _lastScale;
      _viewport.zoom(scaleDiff, 0.5);
      _lastScale = details.scale;
    } else if (details.pointerCount == 1) {
      // 팬
      final dx = details.focalPointDelta.dx;
      final candlesPerPixel = _viewport.visibleCandleCount / context.size!.width;
      _viewport.pan(-dx * candlesPerPixel);
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _updateCrosshair(details.localPosition);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _updateCrosshair(details.localPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _crosshairPosition = null;
      _selectedCandle = null;
    });
  }

  void _updateCrosshair(Offset position) {
    final width = context.size?.width ?? 0;
    if (width == 0) return;

    final candleWidth = width / _viewport.visibleCandleCount;
    final candleIndex = _viewport.startIndexInt + (position.dx / candleWidth).floor();

    if (candleIndex >= 0 && candleIndex < widget.candles.length) {
      setState(() {
        _crosshairPosition = position;
        _selectedCandle = widget.candles[candleIndex];
      });
      widget.onCandleSelected?.call(_selectedCandle!);
    }
  }
}

class _InfoLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoLabel(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          Text(
            value,
            style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
