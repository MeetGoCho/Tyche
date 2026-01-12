# 아키텍처 가이드

이 문서는 Tyche 프로젝트의 아키텍처와 설계 원칙을 설명합니다.

## 아키텍처 개요

Tyche는 **Clean Architecture + Feature-first** 하이브리드 구조를 사용합니다.

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                         │
│  (UI, Controllers, Providers)                                   │
├─────────────────────────────────────────────────────────────────┤
│                        Domain Layer                             │
│  (Entities, Repository Interfaces, Use Cases)                   │
├─────────────────────────────────────────────────────────────────┤
│                         Data Layer                              │
│  (API, Models, Repository Implementations)                      │
├─────────────────────────────────────────────────────────────────┤
│                        Core / Infra                             │
│  (Theme, Router, Network, Utils)                                │
└─────────────────────────────────────────────────────────────────┘
```

## 디렉토리 구조

```
lib/
├── main.dart                     # 앱 진입점
├── app.dart                      # MaterialApp 설정
│
├── core/                         # 공통 핵심 모듈
│   ├── config/                   # 환경 설정
│   │   └── app_config.dart       # dotenv 기반 설정
│   │
│   ├── constants/                # 상수 정의
│   │   ├── app_constants.dart    # 앱 전역 상수
│   │   └── api_constants.dart    # API 관련 상수
│   │
│   ├── di/                       # 의존성 주입
│   │   └── providers.dart        # Riverpod Provider 정의
│   │
│   ├── errors/                   # 에러 처리
│   │   ├── exceptions.dart       # Exception 클래스
│   │   └── failures.dart         # Failure 클래스 (Either용)
│   │
│   ├── extensions/               # Dart 확장 함수
│   │   ├── datetime_extension.dart
│   │   ├── num_extension.dart
│   │   └── string_extension.dart
│   │
│   ├── network/                  # 네트워크 설정
│   │   └── api_client.dart       # Dio 클라이언트
│   │
│   ├── router/                   # 라우팅
│   │   ├── app_router.dart       # GoRouter 설정
│   │   └── route_names.dart      # 라우트 이름/경로
│   │
│   ├── theme/                    # 테마 시스템
│   │   ├── app_colors.dart       # 색상 팔레트
│   │   ├── app_text_styles.dart  # 텍스트 스타일
│   │   └── app_theme.dart        # ThemeData
│   │
│   └── utils/                    # 유틸리티
│       └── logger.dart           # 로깅
│
├── data/                         # 데이터 레이어
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── polygon_api.dart  # Polygon.io API
│   │   └── local/
│   │       └── cache_manager.dart # Hive 캐시
│   │
│   ├── models/                   # DTO (Data Transfer Object)
│   │   ├── candle_model.dart
│   │   ├── ticker_model.dart
│   │   ├── aggregate_response.dart
│   │   └── ticker_response.dart
│   │
│   └── repositories/             # Repository 구현체
│       └── stock_repository_impl.dart
│
├── domain/                       # 도메인 레이어
│   ├── entities/                 # 엔티티 (순수 비즈니스 모델)
│   │   ├── candle.dart
│   │   ├── stock.dart
│   │   ├── time_frame.dart
│   │   └── strategy_type.dart
│   │
│   └── repositories/             # Repository 인터페이스
│       └── stock_repository.dart
│
├── presentation/                 # UI 레이어
│   ├── common/                   # 공통 위젯
│   │   ├── widgets/
│   │   │   ├── main_shell.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   └── dialogs/
│   │
│   └── features/                 # 기능별 화면
│       ├── home/
│       │   └── home_screen.dart
│       ├── search/
│       │   └── search_screen.dart
│       ├── stock_detail/
│       │   ├── stock_detail_screen.dart
│       │   └── stock_detail_provider.dart
│       ├── chart/
│       │   └── chart_screen.dart
│       └── settings/
│           └── settings_screen.dart
│
├── chart_engine/                 # 커스텀 차트 엔진
│   ├── core/
│   │   ├── chart_config.dart     # 차트 설정
│   │   └── chart_viewport.dart   # 뷰포트 (줌/팬)
│   │
│   ├── painters/                 # CustomPainter 구현
│   │   ├── candlestick_painter.dart
│   │   ├── volume_painter.dart
│   │   ├── grid_painter.dart
│   │   └── crosshair_painter.dart
│   │
│   └── widgets/
│       └── interactive_chart.dart # 메인 차트 위젯
│
└── scoring/                      # 점수 계산 엔진
    ├── analyzers/                # 분석기
    │   ├── trend_analyzer.dart
    │   ├── momentum_analyzer.dart
    │   ├── volatility_analyzer.dart
    │   ├── volume_analyzer.dart
    │   └── pattern_analyzer.dart
    │
    ├── core/
    │   └── score_calculator.dart # 점수 계산 핵심 로직
    │
    └── models/
        └── score_result.dart     # 점수 결과 모델
```

## 레이어별 책임

### Core Layer
- **config**: 환경 변수 및 앱 설정 관리
- **di**: Riverpod Provider를 통한 의존성 주입
- **errors**: 에러/예외 타입 정의
- **network**: HTTP 클라이언트 설정
- **router**: 네비게이션 설정
- **theme**: UI 테마 시스템

### Data Layer
- **datasources**: 외부 데이터 소스 (API, 로컬 저장소)
- **models**: API 응답 매핑용 DTO
- **repositories**: Repository 인터페이스 구현체

### Domain Layer
- **entities**: 순수 비즈니스 모델 (외부 의존성 없음)
- **repositories**: Repository 추상 인터페이스

### Presentation Layer
- **common**: 재사용 가능한 공통 위젯
- **features**: 기능별 화면 및 상태 관리

### Chart Engine
- **core**: 차트 설정 및 뷰포트 관리
- **painters**: CustomPainter 기반 렌더링
- **widgets**: 통합 차트 위젯

### Scoring Engine
- **analyzers**: 기술적 분석 로직
- **core**: 점수 계산 로직
- **models**: 점수 결과 모델

## 설계 원칙

### 1. 단방향 의존성
```
Presentation → Domain ← Data
```
- Domain은 어떤 레이어에도 의존하지 않음
- Presentation과 Data는 Domain에 의존

### 2. Repository 패턴
```dart
// Domain (인터페이스)
abstract class StockRepository {
  Future<Either<Failure, List<Candle>>> getCandles(...);
}

// Data (구현체)
class StockRepositoryImpl implements StockRepository {
  @override
  Future<Either<Failure, List<Candle>>> getCandles(...) { ... }
}
```

### 3. Either 타입으로 에러 처리
```dart
final result = await repository.getCandles(...);
result.fold(
  (failure) => /* 에러 처리 */,
  (candles) => /* 성공 처리 */,
);
```

### 4. Provider를 통한 상태 관리
```dart
// StateNotifier 기반
class StockDetailNotifier extends StateNotifier<StockDetailState> {
  // ...
}

// Family Provider로 파라미터 전달
final stockDetailProvider = StateNotifierProvider.family<
  StockDetailNotifier, StockDetailState, String
>((ref, ticker) => StockDetailNotifier(ref, ticker));
```

## 데이터 흐름

```
User Action
    ↓
Presentation (Screen/Widget)
    ↓
Provider (StateNotifier)
    ↓
Repository (Interface)
    ↓
Repository Impl
    ↓
DataSource (API/Cache)
    ↓
External Service (Polygon.io)
```

## 기술 선택 근거

| 항목 | 선택 | 이유 |
|------|------|------|
| 상태관리 | Riverpod | 타입 안전, 의존성 주입 통합, 테스트 용이 |
| 라우팅 | GoRouter | Flutter 공식 추천, 딥링크, Web 지원 |
| 네트워크 | Dio | 인터셉터, 타임아웃, 에러 핸들링 |
| 캐싱 | Hive | NoSQL, 빠른 읽기/쓰기, 간단한 설정 |
| 에러 처리 | fpdart (Either) | 명시적 에러 타입, 함수형 체이닝 |
| 차트 | CustomPainter | 완전한 커스터마이징, 성능 최적화 |
