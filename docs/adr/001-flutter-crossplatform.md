# ADR 001 — Flutter 크로스플랫폼 채택

**날짜**: 2025-01-15  
**상태**: 승인됨

---

## 맥락

헬프데스크 서비스는 세 가지 사용자 그룹을 동시에 지원해야 합니다.

- **직원(user)**: PC 웹 브라우저에서 티켓 접수
- **현장 담당자(agent)**: 스마트폰 앱으로 실시간 알림 수신 및 처리
- **관리자(admin)**: PC 웹 대시보드에서 전체 현황 모니터링

이를 위해 웹 앱과 모바일 앱을 모두 구축해야 하는데, 두 개의 별도 코드베이스를 유지하면 개발 인력과 시간이 두 배 필요합니다.

---

## 결정

**Flutter + Dart 단일 코드베이스**로 웹(Chrome)과 Android 앱을 동시에 지원합니다.

---

## 근거

| 기준 | Flutter | React Native | 네이티브 분리 |
|------|---------|-------------|-------------|
| 코드 재사용률 | ~95% | ~85% | 0% |
| 웹 지원 | 공식 지원 | 별도 React 필요 | 별도 구축 |
| 상태관리 일관성 | Riverpod 단일 | 각 플랫폼 상이 | 각 플랫폼 상이 |
| 팀 규모 적합성 | 2인 팀 최적 | 2인 팀 가능 | 4인+ 필요 |

Flutter를 선택한 핵심 이유:
1. **단일 코드베이스**: 웹과 앱을 같은 Dart 코드로 구현. 직원용 웹 화면과 현장 담당자용 앱 화면이 같은 로직을 공유.
2. **반응형 레이아웃**: `LayoutBuilder`로 화면 너비에 따라 사이드바/레일/하단바를 자동 전환.
3. **Firebase 공식 SDK**: Firebase FlutterFire SDK가 웹/Android 모두 동일하게 동작.

---

## 결과

- Flutter 3.x + Dart 3.x 사용
- 웹: `flutter run -d chrome` / `flutter build web`
- Android: `flutter run -d android` / `flutter build apk`
- 코드 분기는 `Platform.isAndroid` 대신 `LayoutBuilder` 너비 기반으로 처리 (웹/앱 동작 차이 최소화)

---

## 트레이드오프

- Flutter 웹은 네이티브 웹(React)보다 초기 로딩이 느림 (CanvasKit 렌더러)
- iOS 지원은 Mac 개발 환경이 필요해 이번 프로젝트에서는 제외
