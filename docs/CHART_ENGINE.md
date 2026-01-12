# 차트 엔진 가이드

이 문서는 Tyche의 커스텀 차트 엔진 구현을 설명합니다.

## 개요

Tyche는 외부 차트 라이브러리 대신 **CustomPainter**를 기반으로 자체 차트 엔진을 구현했습니다.

### 선택 이유

| 외부 라이브러리 | CustomPainter |
|---------------|---------------|
| 빠른 구현 | 완전한 커스터마이징 |
| 제한된 기능 | 무한한 확장성 |
| 의존성 관리 필요 | 성능 최적화 가능 |
| 스타일 제약 | 브랜드 UI 구현 |

## 아키텍처

```
┌─────────────────────────────────────────────────┐
│              InteractiveChart                   │
│  (GestureDetector + CustomPaint)                │
├─────────────────────────────────────────────────┤
│                ChartViewport                    │
│  (줌, 팬, 가시 범위 관리)                        │
├───────────┬───────────┬───────────┬─────────────┤
│   Grid    │ Candlestick│  Volume  │ Crosshair   │
│  Painter  │   Painter  │  Painter │   Painter   │
└───────────┴───────────┴───────────┴─────────────┘
```

## 핵심 컴포넌트

### 1. ChartViewport

차트의 가시 영역과 줌/팬 상태를 관리합니다.

```dart
// lib/chart_engine/core/chart_viewport.dart

class ChartViewport extends ChangeNotifier {
  double _startIndex;   // 시작 캔들 인덱스
  double _endIndex;     // 끝 캔들 인덱스
  double _minPrice;     // 최소 가격
  double _maxPrice;     // 최대 가격

  // 줌 기능
  void zoom(double factor, double focalPointRatio) {
    final range = _endIndex - _startIndex;
    final focalPoint = _startIndex + range * focalPointRatio;
    final newRange = (range / factor).clamp(10, _totalCandles);
    // ...
    notifyListeners();
  }

  // 팬(스크롤) 기능
  void pan(double deltaCandles) {
    final newStart = (_startIndex + deltaCandles).clamp(0, max);
    // ...
    notifyListeners();
  }
}
```

### 2. CandlestickPainter

캔들스틱을 렌더링합니다.

```dart
// lib/chart_engine/painters/candlestick_painter.dart

class CandlestickPainter extends CustomPainter {
  final List<Candle> candles;
  final ChartViewport viewport;
  final ChartTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    for (final candle in visibleCandles) {
      _drawCandle(canvas, candle, x, width, size);
    }
  }

  void _drawCandle(Canvas canvas, Candle candle, double x,
                   double width, Size size) {
    final isUp = candle.isBullish;
    final color = isUp ? theme.upColor : theme.downColor;

    // 심지 (Wick) 그리기
    canvas.drawLine(
      Offset(x, wickTop),
      Offset(x, wickBottom),
      wickPaint,
    );

    // 몸통 (Body) 그리기
    canvas.drawRect(bodyRect, bodyPaint);
  }

  @override
  bool shouldRepaint(CandlestickPainter oldDelegate) {
    return candles != oldDelegate.candles ||
           viewport.startIndex != oldDelegate.viewport.startIndex;
  }
}
```

### 3. VolumePainter

거래량 바를 렌더링합니다.

```dart
// lib/chart_engine/painters/volume_painter.dart

class VolumePainter extends CustomPainter {
  void _drawVolumeBar(Canvas canvas, Candle candle,
                      double x, double width, Size size) {
    final isUp = candle.isBullish;
    final color = isUp ? theme.volumeUpColor : theme.volumeDownColor;

    final barHeight = _volumeToHeight(candle.volume, size);
    final rect = Rect.fromLTRB(
      x - barWidth / 2,
      size.height - barHeight,
      x + barWidth / 2,
      size.height,
    );

    canvas.drawRect(rect, paint);
  }
}
```

### 4. CrosshairPainter

크로스헤어와 정보 라벨을 렌더링합니다.

```dart
// lib/chart_engine/painters/crosshair_painter.dart

class CrosshairPainter extends CustomPainter {
  final Offset position;
  final String? priceLabel;
  final String? timeLabel;

  @override
  void paint(Canvas canvas, Size size) {
    // 수평선
    canvas.drawLine(
      Offset(0, position.dy),
      Offset(size.width, position.dy),
      paint,
    );

    // 수직선
    canvas.drawLine(
      Offset(position.dx, 0),
      Offset(position.dx, size.height),
      paint,
    );

    // 교차점
    canvas.drawCircle(position, 4, circlePaint);

    // 라벨
    _drawLabel(canvas, priceLabel, ...);
  }
}
```

### 5. InteractiveChart

모든 Painter를 통합하고 제스처를 처리합니다.

```dart
// lib/chart_engine/widgets/interactive_chart.dart

class InteractiveChart extends StatefulWidget {
  final List<Candle> candles;
  final ChartConfig config;

  @override
  State<InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<InteractiveChart> {
  late ChartViewport _viewport;
  Offset? _crosshairPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          CustomPaint(painter: GridPainter(...)),
          CustomPaint(painter: CandlestickPainter(...)),
          if (_crosshairPosition != null)
            CustomPaint(painter: CrosshairPainter(...)),
        ],
      ),
    );
  }
}
```

## 좌표 변환

### 가격 → Y 좌표

```dart
double _priceToY(double price, Size size) {
  final range = viewport.maxPrice - viewport.minPrice;
  if (range == 0) return size.height / 2;
  return size.height * (1 - (price - viewport.minPrice) / range);
}
```

### 인덱스 → X 좌표

```dart
double _indexToX(int index, Size size, double candleWidth) {
  final relativeIndex = index - viewport.startIndexInt;
  return (relativeIndex + 0.5) * candleWidth;
}
```

### Y 좌표 → 가격

```dart
double _yToPrice(double y, Size size) {
  final ratio = 1 - y / size.height;
  return viewport.minPrice + ratio * (viewport.maxPrice - viewport.minPrice);
}
```

## 제스처 처리

### 줌 (Pinch)

```dart
void _onScaleUpdate(ScaleUpdateDetails details) {
  if (details.pointerCount == 2) {
    final scaleDiff = details.scale / _lastScale;
    _viewport.zoom(scaleDiff, 0.5);
    _lastScale = details.scale;
  }
}
```

### 팬 (Drag)

```dart
void _onScaleUpdate(ScaleUpdateDetails details) {
  if (details.pointerCount == 1) {
    final dx = details.focalPointDelta.dx;
    final candlesPerPixel = _viewport.visibleCandleCount / size.width;
    _viewport.pan(-dx * candlesPerPixel);
  }
}
```

### 크로스헤어 (Long Press)

```dart
void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
  final candleIndex = _positionToCandleIndex(details.localPosition);
  setState(() {
    _crosshairPosition = details.localPosition;
    _selectedCandle = candles[candleIndex];
  });
}
```

## 성능 최적화

### 1. RepaintBoundary

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: CandlestickPainter(...),
  ),
)
```

### 2. shouldRepaint 최적화

```dart
@override
bool shouldRepaint(CandlestickPainter oldDelegate) {
  return candles != oldDelegate.candles ||
         viewport.startIndex != oldDelegate.viewport.startIndex ||
         viewport.endIndex != oldDelegate.viewport.endIndex;
}
```

### 3. 가시 영역만 렌더링

```dart
List<Candle> _getVisibleCandles() {
  final start = viewport.startIndexInt;
  final end = viewport.endIndexInt;
  return candles.sublist(start, end.clamp(0, candles.length));
}
```

## ChartConfig

차트 설정을 관리합니다.

```dart
class ChartConfig {
  final ChartType type;        // candlestick, line, area
  final bool showGrid;         // 그리드 표시
  final bool showVolume;       // 거래량 표시
  final double volumeHeightRatio;  // 거래량 높이 비율
  final ChartTheme theme;      // 테마
}

class ChartTheme {
  final Color upColor;         // 상승 색상
  final Color downColor;       // 하락 색상
  final Color gridColor;       // 그리드 색상
  final Color crosshairColor;  // 크로스헤어 색상
}
```

## 확장 포인트

### 1. 새 지표 추가

```dart
class MAIndicatorPainter extends CustomPainter {
  final List<double> maValues;
  final int period;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (int i = 0; i < maValues.length; i++) {
      final x = _indexToX(i);
      final y = _priceToY(maValues[i]);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }
}
```

### 2. 새 차트 타입 추가

```dart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (final candle in visibleCandles) {
      path.lineTo(_priceToY(candle.close));
    }
    canvas.drawPath(path, paint);
  }
}
```

## 사용 예시

```dart
InteractiveChart(
  candles: stockData.candles,
  config: ChartConfig(
    type: ChartType.candlestick,
    showGrid: true,
    showVolume: true,
    theme: ChartTheme(
      upColor: Colors.green,
      downColor: Colors.red,
    ),
  ),
  onCandleSelected: (candle) {
    print('Selected: ${candle.close}');
  },
)
```
