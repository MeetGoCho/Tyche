import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Chart display type
enum ChartType {
  candlestick,
  bar,
  hollow,
  heikinAshi,
  line,
  area,
}

/// Overlay indicators (displayed on main chart)
enum OverlayIndicator {
  sma20,
  sma50,
  sma200,
  ema20,
  bollingerBands,
}

/// Sub indicators (displayed in separate panel)
enum SubIndicator {
  rsi,
  macd,
  stochasticRsi,
  momentum,
}

class ChartConfig {
  final ChartType type;
  final bool showGrid;
  final bool showVolume;
  final double volumeHeightRatio;
  final ChartTheme theme;
  final Set<OverlayIndicator> overlayIndicators;
  final SubIndicator? subIndicator;

  const ChartConfig({
    this.type = ChartType.candlestick,
    this.showGrid = true,
    this.showVolume = true,
    this.volumeHeightRatio = 0.2,
    this.theme = const ChartTheme(),
    this.overlayIndicators = const {},
    this.subIndicator,
  });

  bool get hasSubIndicator => subIndicator != null;

  ChartConfig copyWith({
    ChartType? type,
    bool? showGrid,
    bool? showVolume,
    double? volumeHeightRatio,
    ChartTheme? theme,
    Set<OverlayIndicator>? overlayIndicators,
    SubIndicator? subIndicator,
    bool clearSubIndicator = false,
  }) {
    return ChartConfig(
      type: type ?? this.type,
      showGrid: showGrid ?? this.showGrid,
      showVolume: showVolume ?? this.showVolume,
      volumeHeightRatio: volumeHeightRatio ?? this.volumeHeightRatio,
      theme: theme ?? this.theme,
      overlayIndicators: overlayIndicators ?? this.overlayIndicators,
      subIndicator: clearSubIndicator ? null : (subIndicator ?? this.subIndicator),
    );
  }

  ChartConfig toggleOverlay(OverlayIndicator indicator) {
    final newSet = Set<OverlayIndicator>.from(overlayIndicators);
    if (newSet.contains(indicator)) {
      newSet.remove(indicator);
    } else {
      newSet.add(indicator);
    }
    return copyWith(overlayIndicators: newSet);
  }

  ChartConfig setSubIndicator(SubIndicator? indicator) {
    if (indicator == subIndicator) {
      return copyWith(clearSubIndicator: true);
    }
    return copyWith(subIndicator: indicator);
  }
}

class ChartTheme {
  final Color upColor;
  final Color downColor;
  final Color gridColor;
  final Color backgroundColor;
  final Color textColor;
  final Color crosshairColor;
  final Color volumeUpColor;
  final Color volumeDownColor;

  const ChartTheme({
    this.upColor = AppColors.bullish,
    this.downColor = AppColors.bearish,
    this.gridColor = AppColors.gridLine,
    this.backgroundColor = AppColors.background,
    this.textColor = AppColors.textSecondary,
    this.crosshairColor = AppColors.crosshair,
    this.volumeUpColor = const Color(0x8026A69A),
    this.volumeDownColor = const Color(0x80EF5350),
  });
}
