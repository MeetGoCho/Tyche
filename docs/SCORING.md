# 점수 계산 가이드

이 문서는 Tyche의 AI 유불리 점수 계산 로직을 설명합니다.

## 개요

Tyche는 **0-100점**의 유불리 점수를 통해 현재 시점이 매매에 얼마나 유리한지 수치화합니다.

### 핵심 원칙

1. **AI는 조력자**: 매수/매도 명령이 아닌 통계적 점수 제공
2. **전략별 가중치**: 선택한 전략에 따라 분석 요소의 비중 조절
3. **종합적 분석**: 5가지 기술적 분석 요소 통합

## 점수 해석

| 점수 | 신호 | 의미 |
|------|------|------|
| 80-100 | Strong Buy | 매우 유리한 진입 시점 |
| 60-79 | Buy | 유리한 진입 시점 |
| 40-59 | Neutral | 중립적 상황 |
| 20-39 | Sell | 불리한 시점, 관망 권장 |
| 0-19 | Strong Sell | 매우 불리한 시점 |

## 분석 요소

### 1. Trend (추세 분석)

이동평균선을 기반으로 현재 추세를 분석합니다.

```dart
// lib/scoring/analyzers/trend_analyzer.dart

class TrendAnalyzer {
  double analyze(List<Candle> candles) {
    double score = 50.0;

    final sma20 = _calculateSMA(closes, 20);
    final sma50 = _calculateSMA(closes, 50);

    // 골든크로스/데드크로스
    if (sma20.last > sma50.last) {
      score += 15;  // 단기 MA > 장기 MA = 상승 추세
    } else {
      score -= 15;
    }

    // 가격과 MA 위치 관계
    if (closes.last > sma20.last) score += 10;
    if (closes.last > sma50.last) score += 10;

    // MA 기울기 (추세 강도)
    final slope = _calculateSlope(sma20);
    score += (slope * 1000).clamp(-15, 15);

    return score.clamp(0, 100);
  }
}
```

**분석 항목**:
- SMA 20/50 교차 상태
- 현재가와 MA 위치 관계
- MA 기울기 (추세 강도)

### 2. Momentum (모멘텀 분석)

RSI와 가격 변화율로 모멘텀을 측정합니다.

```dart
// lib/scoring/analyzers/momentum_analyzer.dart

class MomentumAnalyzer {
  double analyze(List<Candle> candles) {
    double score = 50.0;

    // RSI 분석
    final rsi = _calculateRSI(closes, 14);
    if (rsi < 30) {
      score += 20;  // 과매도 → 반등 기대
    } else if (rsi > 70) {
      score -= 20;  // 과매수 → 조정 가능
    }

    // 모멘텀 (10일 전 대비)
    final momentum = (closes.last - closes[length - 10]) / closes[length - 10];
    score += (momentum * 100).clamp(-15, 15);

    // ROC (Rate of Change)
    final roc = _calculateROC(closes, 12);
    score += (roc / 2).clamp(-10, 10);

    return score.clamp(0, 100);
  }
}
```

**분석 항목**:
- RSI (14일)
- 모멘텀 (10일)
- ROC (12일)

### 3. Volatility (변동성 분석)

볼린저 밴드와 ATR로 변동성을 분석합니다.

```dart
// lib/scoring/analyzers/volatility_analyzer.dart

class VolatilityAnalyzer {
  double analyze(List<Candle> candles) {
    double score = 50.0;

    // 볼린저 밴드
    final bb = _calculateBollingerBands(closes, 20, 2);
    final percentB = (currentPrice - bb.lower) / (bb.upper - bb.lower);

    if (percentB < 0.2) {
      score += 15;  // 하단 밴드 근처 → 매수 기회
    } else if (percentB > 0.8) {
      score -= 15;  // 상단 밴드 근처 → 매도 고려
    }

    // 밴드 폭 (변동성 축소 = 돌파 임박)
    final bandWidth = (bb.upper - bb.lower) / bb.middle;
    if (bandWidth < 0.05) {
      score += 10;  // 변동성 축소 → 돌파 가능성
    }

    // ATR 기반 변동성
    final atr = _calculateATR(candles, 14);
    final atrPercent = atr / closes.last * 100;
    if (atrPercent < 2) score += 5;
    else if (atrPercent > 5) score -= 5;

    return score.clamp(0, 100);
  }
}
```

**분석 항목**:
- 볼린저 밴드 위치 (%B)
- 볼린저 밴드 폭 (스퀴즈)
- ATR (14일)

### 4. Volume (거래량 분석)

거래량과 OBV로 수급을 분석합니다.

```dart
// lib/scoring/analyzers/volume_analyzer.dart

class VolumeAnalyzer {
  double analyze(List<Candle> candles) {
    double score = 50.0;

    // 거래량 이동평균 대비
    final volumeMA = _calculateSMA(volumes, 20);
    final volumeRatio = currentVolume / volumeMA.last;

    if (volumeRatio > 2 && lastCandle.isBullish) {
      score += 20;  // 상승 + 거래량 급증
    } else if (volumeRatio > 2 && lastCandle.isBearish) {
      score -= 10;  // 하락 + 거래량 급증
    }

    // OBV 추세
    final obv = _calculateOBV(candles);
    final obvMA = _calculateSMA(obv, 20);
    if (obv.last > obvMA.last) {
      score += 10;  // OBV 상승 추세
    } else {
      score -= 10;
    }

    return score.clamp(0, 100);
  }
}
```

**분석 항목**:
- 거래량 MA 대비 비율
- 거래량-가격 방향 일치 여부
- OBV (On Balance Volume) 추세

### 5. Pattern (패턴 분석)

캔들스틱 패턴을 분석합니다.

```dart
// lib/scoring/analyzers/pattern_analyzer.dart

class PatternAnalyzer {
  double analyze(List<Candle> candles) {
    double score = 50.0;

    // 연속 상승/하락
    if (consecutiveBullish >= 3) score += 10;
    if (consecutiveBearish >= 3) score -= 10;

    // 도지 패턴 (반전 신호)
    if (_isDoji(lastCandle)) {
      if (prevCandle.isBearish) score += 5;  // 하락 후 도지
      else score -= 5;
    }

    // 망치형 (Hammer)
    if (_isHammer(lastCandle)) score += 10;

    // 장악형 (Engulfing)
    if (_isBullishEngulfing(prev, curr)) score += 15;
    if (_isBearishEngulfing(prev, curr)) score -= 15;

    return score.clamp(0, 100);
  }
}
```

**분석 항목**:
- 연속 상승/하락 캔들
- 도지 (Doji)
- 망치형 (Hammer)
- 역망치형 (Inverted Hammer)
- 상승/하락 장악형 (Engulfing)

## 전략별 가중치

각 전략은 5가지 분석 요소에 다른 가중치를 적용합니다.

```dart
// lib/scoring/core/score_calculator.dart

_StrategyWeights _getWeightsForStrategy(StrategyType strategy) {
  switch (strategy) {
    case StrategyType.movingAverage:
      return _StrategyWeights(
        trend: 0.40,      // 추세 중심
        momentum: 0.20,
        volatility: 0.15,
        volume: 0.15,
        pattern: 0.10,
      );

    case StrategyType.rsi:
      return _StrategyWeights(
        trend: 0.15,
        momentum: 0.45,   // 모멘텀 중심
        volatility: 0.15,
        volume: 0.15,
        pattern: 0.10,
      );

    case StrategyType.macd:
      return _StrategyWeights(
        trend: 0.30,
        momentum: 0.35,   // 추세+모멘텀
        volatility: 0.10,
        volume: 0.15,
        pattern: 0.10,
      );

    case StrategyType.bollingerBands:
      return _StrategyWeights(
        trend: 0.15,
        momentum: 0.20,
        volatility: 0.40,  // 변동성 중심
        volume: 0.15,
        pattern: 0.10,
      );

    case StrategyType.volumeBreakout:
      return _StrategyWeights(
        trend: 0.20,
        momentum: 0.15,
        volatility: 0.15,
        volume: 0.40,     // 거래량 중심
        pattern: 0.10,
      );
  }
}
```

### 가중치 표

| 전략 | Trend | Momentum | Volatility | Volume | Pattern |
|------|-------|----------|------------|--------|---------|
| Moving Average | **40%** | 20% | 15% | 15% | 10% |
| RSI | 15% | **45%** | 15% | 15% | 10% |
| MACD | 30% | **35%** | 10% | 15% | 10% |
| Bollinger Bands | 15% | 20% | **40%** | 15% | 10% |
| Volume Breakout | 20% | 15% | 15% | **40%** | 10% |

## 점수 계산 흐름

```
┌─────────────────────────────────────────────────────────┐
│                   Input: Candles                        │
└─────────────────────┬───────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────┐
│              5개 Analyzer 병렬 실행                      │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐   │
│  │  Trend  │Momentum │Volatility│ Volume │ Pattern │   │
│  │   72    │   65    │    58   │   70   │    68   │   │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘   │
└─────────────────────┬───────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────┐
│              전략별 가중치 적용                          │
│  Score = 72×0.40 + 65×0.20 + 58×0.15 + 70×0.15 + 68×0.10│
│        = 28.8 + 13 + 8.7 + 10.5 + 6.8 = 67.8           │
└─────────────────────┬───────────────────────────────────┘
                      ▼
┌─────────────────────────────────────────────────────────┐
│              정규화 및 신호 결정                         │
│              Score: 68 → Signal: "Buy"                  │
└─────────────────────────────────────────────────────────┘
```

## ScoreResult 모델

```dart
// lib/scoring/models/score_result.dart

class ScoreResult {
  final int overallScore;        // 종합 점수 (0-100)
  final ScoreBreakdown breakdown; // 세부 점수
  final Signal signal;           // 신호 (Strong Buy ~ Strong Sell)
  final StrategyType strategy;   // 사용된 전략
  final DateTime calculatedAt;   // 계산 시점
}

class ScoreBreakdown {
  final double trend;
  final double momentum;
  final double volatility;
  final double volume;
  final double pattern;
}

enum Signal {
  strongBuy('Strong Buy', green),
  buy('Buy', lightGreen),
  neutral('Neutral', grey),
  sell('Sell', orange),
  strongSell('Strong Sell', red);
}
```

## 사용 예시

```dart
final calculator = ScoreCalculator();

final result = calculator.calculateScore(
  candles: stockCandles,
  strategy: StrategyType.movingAverage,
);

print('Score: ${result.overallScore}');
print('Signal: ${result.signal.label}');
print('Trend: ${result.breakdown.trend}');
```

## 한계 및 주의사항

1. **과거 데이터 기반**: 과거 패턴이 미래를 보장하지 않음
2. **시장 상황 미반영**: 뉴스, 이벤트 등 외부 요인 미반영
3. **단일 종목 분석**: 섹터/시장 전체 흐름 미반영
4. **백테스팅 필요**: 실제 수익률 검증 필요

> **중요**: 점수는 참고 지표이며, 최종 투자 결정과 책임은 사용자에게 있습니다.

## 확장 포인트

### 새 분석기 추가

```dart
class NewAnalyzer {
  double analyze(List<Candle> candles) {
    double score = 50.0;
    // 분석 로직
    return score.clamp(0, 100);
  }
}
```

### 새 전략 추가

```dart
case StrategyType.newStrategy:
  return _StrategyWeights(
    trend: 0.25,
    momentum: 0.25,
    volatility: 0.25,
    volume: 0.25,
    pattern: 0.00,  // 새 분석기에 가중치 부여
  );
```
