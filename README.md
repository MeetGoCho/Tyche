# Tyche (Strategy-Core)

AI 기반 투자 전략 분석 플랫폼

## 개요

Tyche는 사용자가 선택한 매매 전략에 따라 시장의 '유불리'를 실시간 데이터로 분석하고, 0-100점의 점수로 시각화해주는 투자 조력 앱입니다.

### 핵심 철학

- **AI는 조력자**: 절대적인 매수/매도 명령이 아닌, 통계적 유불리 점수 제공
- **사용자 책임의 원칙**: 최종 매매 결정은 사용자가 수행
- **원천 데이터 기반**: 외부 차트를 불러오는 것이 아닌, Raw Data를 직접 파싱하여 독자적 UI 구축

## 기술 스택

| 영역 | 기술 |
|------|------|
| 플랫폼 | Flutter (Android, iOS, Web) |
| 상태관리 | Riverpod |
| 라우팅 | GoRouter |
| 네트워크 | Dio |
| 로컬 저장소 | Hive |
| 데이터 소스 | Polygon.io API |

## 시작하기

### 사전 요구사항

- Flutter SDK 3.16.0 이상
- Dart SDK 3.2.0 이상
- Polygon.io API 키 ([발급 링크](https://polygon.io/))

### 설치

```bash
# 저장소 클론
git clone https://github.com/your-repo/tyche.git
cd tyche

# 환경 변수 설정
cp .env.example .env
# .env 파일을 열어 POLYGON_API_KEY 값 설정

# 의존성 설치
flutter pub get

# 코드 생성 (필요시)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

### 환경 변수

`.env` 파일에 다음 값을 설정하세요:

```
POLYGON_API_KEY=your_polygon_api_key
ENV=development
```

## 주요 기능

### 1. 커스텀 차트 엔진
- CustomPainter 기반 캔들스틱 차트
- 핀치 줌, 팬(스크롤), 크로스헤어 지원
- 거래량 차트 연동

### 2. AI 유불리 점수 (0-100)
5가지 분석 요소를 전략별 가중치로 계산:
- Trend (추세)
- Momentum (모멘텀)
- Volatility (변동성)
- Volume (거래량)
- Pattern (패턴)

### 3. 5가지 매매 전략
| 전략 | 설명 |
|------|------|
| Moving Average | 이동평균선 기반 추세 분석 |
| RSI | 과매수/과매도 모멘텀 분석 |
| MACD | 추세 전환점 포착 |
| Bollinger Bands | 변동성 기반 지지/저항 분석 |
| Volume Breakout | 거래량 돌파 신호 분석 |

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── app.dart                  # MaterialApp 설정
├── core/                     # 공통 핵심 모듈
├── data/                     # 데이터 레이어 (API, Repository 구현)
├── domain/                   # 도메인 레이어 (Entity, Repository 인터페이스)
├── presentation/             # UI 레이어 (화면, 위젯)
├── chart_engine/             # 커스텀 차트 엔진
└── scoring/                  # 점수 계산 엔진
```

자세한 구조는 [ARCHITECTURE.md](./docs/ARCHITECTURE.md) 참조

## 문서

- [아키텍처 가이드](./docs/ARCHITECTURE.md) - 프로젝트 구조 및 설계 원칙
- [API 가이드](./docs/API.md) - Polygon.io API 연동 가이드
- [차트 엔진 가이드](./docs/CHART_ENGINE.md) - 커스텀 차트 구현 가이드
- [점수 계산 가이드](./docs/SCORING.md) - 유불리 점수 계산 로직

## 로드맵

### Phase 1 (MVP) - 완료
- [x] 프로젝트 기반 설정
- [x] Polygon.io API 연동
- [x] 커스텀 차트 엔진
- [x] 5가지 전략 점수 계산
- [x] 기본 UI (Home, Search, Detail, Chart)

### Phase 2 (예정)
- [ ] 실시간 데이터 스트리밍
- [ ] 백테스팅 기능
- [ ] 전략 마켓플레이스
- [ ] 푸시 알림

### Phase 3 (예정)
- [ ] 한국 주식 데이터 통합
- [ ] 재무제표 분석
- [ ] 뉴스 감성 분석
- [ ] 소셜 기능

## 라이선스

이 프로젝트는 비공개 프로젝트입니다.
