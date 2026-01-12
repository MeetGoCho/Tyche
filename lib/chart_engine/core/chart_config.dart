import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ChartType { candlestick, line, area }

class ChartConfig {
  final ChartType type;
  final bool showGrid;
  final bool showVolume;
  final double volumeHeightRatio;
  final ChartTheme theme;

  const ChartConfig({
    this.type = ChartType.candlestick,
    this.showGrid = true,
    this.showVolume = true,
    this.volumeHeightRatio = 0.2,
    this.theme = const ChartTheme(),
  });

  ChartConfig copyWith({
    ChartType? type,
    bool? showGrid,
    bool? showVolume,
    double? volumeHeightRatio,
    ChartTheme? theme,
  }) {
    return ChartConfig(
      type: type ?? this.type,
      showGrid: showGrid ?? this.showGrid,
      showVolume: showVolume ?? this.showVolume,
      volumeHeightRatio: volumeHeightRatio ?? this.volumeHeightRatio,
      theme: theme ?? this.theme,
    );
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
