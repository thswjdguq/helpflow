# 2주차 Day 2 — Daily Report

**날짜**: 2026-03-19
**브랜치**: main (week-02 머지)
**작업자**: Claude Sonnet 4.6

---

## 완료한 작업

### 1. Firebase 패키지 추가 및 초기화
- `pubspec.yaml`에 `firebase_core ^3.0.0`, `firebase_auth ^5.0.0`, `cloud_firestore ^5.0.0`, `firebase_storage ^12.0.0` 추가
- `main.dart`에 `Firebase.initializeApp()` 추가 (플레이스홀더 예외 catch 처리)
- `lib/firebase_options.dart` 플레이스홀더 생성 (실제 연결 시 `flutterfire configure` 실행 필요)

### 2. Firebase 인증 구조 구현 (`lib/features/auth/`)
| 파일 | 역할 |
|------|------|
| `user_model.dart` | uid/email/name/role/createdAt 모델, fromFirestore/toMap |
| `auth_service.dart` | signInWithEmail / signUpWithEmail / signOut |
| `auth_provider.dart` | authStateProvider(StreamProvider), currentUserProvider(AsyncNotifierProvider) |
| `login_screen.dart` | 토스 스타일 로그인 UI, 유효성 검사, 에러 처리 |
| `signup_screen.dart` | 이름/이메일/비밀번호 회원가입 UI |

### 3. Firebase 공통 서비스 (`lib/shared/services/firebase_service.dart`)
- `handleFirebaseError()`: FirebaseAuthException 코드 → 한글 메시지 변환

### 4. 라우터 인증 분기 수정 (`lib/core/router/app_router.dart`)
- `appRouter` 전역 변수 → `appRouterProvider` (Riverpod Provider)로 전환
- `_GoRouterRefreshStream`: Firebase Auth 스트림 → ChangeNotifier 래핑
- `redirect` 콜백 추가: 미로그인 → `/login`, 로그인 후 인증 화면 접근 → `/dashboard`
- `/login`, `/signup` 경로 추가 (ShellRoute 밖, 사이드바 없음)

### 5. app.dart 업데이트
- `appRouter` (전역) → `ref.watch(appRouterProvider)` 로 교체
- Firebase Auth 상태 변화 시 GoRouter redirect 자동 재실행

---

## 발생한 오류 & 해결

| 오류 | 원인 | 해결 |
|------|------|------|
| `AppRoutes.signup isn't defined` | `login_screen.dart` 작성 시점에 AppRoutes에 signup 미정의 | `app_router.dart` 먼저 업데이트 후 해결 |
| `signup_screen.dart doesn't exist` | 파일 생성 전에 import | `signup_screen.dart` 생성으로 해결 |
| `authService` unused variable | `auth_provider.dart` build() 내 불필요한 변수 선언 | 해당 줄 제거 |
| `error: (_, __)` linter 경고 | 다중 언더스코어 불필요 경고 | `(_, _)` 로 수정 |

---

## 미완료 항목

- [ ] `flutterfire configure` 실행 후 `firebase_options.dart` 실제 값으로 교체
- [ ] Firebase Authentication 콘솔에서 이메일/비밀번호 로그인 활성화
- [ ] Firestore 보안 규칙 설정
- [ ] 라우터 인증 가드 테스트 (실제 Firebase 연결 후)

---

## 커밋 내역

```
24cd4b3  feat: 로그인/회원가입 화면 UI 구현 (토스 스타일)
8fcde63  feat: go_router redirect 콜백 및 인증 경로(/login, /signup) 추가
ad5d593  fix: 로그인 화면 라우팅 연결 및 인증 상태 분기 수정
```

---

## 생성·수정 파일 목록

| 파일 | 상태 |
|------|------|
| `lib/features/auth/login_screen.dart` | 신규 생성 |
| `lib/features/auth/signup_screen.dart` | 신규 생성 |
| `lib/features/auth/auth_provider.dart` | 신규 생성 |
| `lib/features/auth/auth_service.dart` | 신규 생성 |
| `lib/features/auth/user_model.dart` | 신규 생성 |
| `lib/shared/services/firebase_service.dart` | 신규 생성 |
| `lib/firebase_options.dart` | 신규 생성 (플레이스홀더) |
| `lib/core/router/app_router.dart` | 수정 (Provider 전환 + redirect 추가) |
| `lib/main.dart` | 수정 (Firebase.initializeApp 추가) |
| `lib/app.dart` | 수정 (appRouterProvider 연동) |
| `pubspec.yaml` | 수정 (Firebase 패키지 추가) |

---

# 1주차 Day 1 — Daily Report

**날짜**: 2026-03-15
**브랜치**: week-01
**작업자**: Claude Sonnet 4.6

---

## 오늘 완료한 작업

### 1. pubspec.yaml 의존성 추가
| 패키지 | 버전 | 용도 |
|---|---|---|
| flutter_riverpod | ^2.5.1 | 상태 관리 |
| hive_flutter | ^1.1.0 | 로컬 DB |
| go_router | ^14.2.7 | 라우팅 |
| material_symbols_icons | ^4.2719.1 | 아이콘 |
| fl_chart | 주석 처리 | 차트 (7~8주차 활성화 예정) |
| build_runner | ^2.4.13 | 코드 생성 |
| hive_generator | ^2.0.1 | Hive 어댑터 생성 |
| riverpod_generator | ^2.4.0 | Riverpod 코드 생성 |

> **이슈**: `riverpod_generator ^2.4.3`이 `hive_generator`의 `analyzer` 버전과 충돌.
> **해결**: `riverpod_generator ^2.4.0`으로 다운그레이드.

---

### 2. 폴더 구조 생성
```
lib/
├── core/
│   ├── constants/     app_colors, app_strings, app_sizes
│   ├── theme/         app_theme, app_text_styles
│   ├── router/        app_router
│   └── utils/         date_utils, validators
├── models/            (빈 폴더, 2주차 구현 예정)
├── services/          (빈 폴더, 추후 구현 예정)
├── providers/         theme_provider
├── views/
│   ├── layout/        main_layout, sidebar_widget, top_bar_widget
│   ├── dashboard/     dashboard_screen
│   ├── tickets/       ticket_list, ticket_detail, ticket_form
│   └── settings/      settings_screen
├── shared/widgets/    custom_button, loading_indicator, empty_state_widget
├── app.dart
└── main.dart
```

---

### 3. 핵심 파일 구현 내용

#### core/constants/
- **app_colors.dart**: 브랜드 컬러(0xFF0057FF), 티켓 우선순위/상태별 색상, Grey scale 팔레트
- **app_strings.dart**: 네비게이션, 화면 제목, 버튼, 에러/유효성 메시지 전역 상수
- **app_sizes.dart**: 브레이크포인트(desktop 1024, tablet 600), 사이드바 240/레일 64 너비

#### core/theme/
- **app_theme.dart**: Material 3, `ColorScheme.fromSeed(0xFF0057FF)` 라이트/다크 테마
- **app_text_styles.dart**: pageTitle, statNumber, navItem, badge 등 텍스트 스타일

#### core/router/app_router.dart
- go_router `ShellRoute` + `NoTransitionPage` 적용
- `/dashboard`, `/tickets`, `/tickets/new`, `/tickets/:id`, `/settings` 경로
- `AppRoutes` 상수 클래스로 경로 문자열 중앙 관리

#### providers/theme_provider.dart
- `Notifier<bool>` 기반 `ThemeNotifier`
- `toggle()`, `setDark()`, `setLight()` 메서드
- `NotifierProvider<ThemeNotifier, bool>`로 전역 등록

#### views/layout/
- **main_layout.dart**: `MediaQuery.sizeOf` 기반 3단계 반응형 분기
- **sidebar_widget.dart**: `AnimatedContainer` 활성 항목 강조, Drawer 모드 지원
- **top_bar_widget.dart**: 경로 기반 제목 자동 표시, 새 티켓 버튼, 다크모드 토글

#### views/dashboard/dashboard_screen.dart
- 통계 카드 4개 (`Wrap` 반응형 배치)
- 차트 플레이스홀더 (7~8주차 fl_chart 연동 예정)
- 최근 티켓 더미 목록 (상태/우선순위 Chip 포함)

#### main.dart / app.dart
- `Hive.initFlutter()` → `TicketModel` 어댑터 등록 주석(2주차 활성화)
- `ProviderScope` → `App` (MaterialApp.router)
- `themeProvider` 구독 → `ThemeMode` 동적 전환

---

### 4. 커밋 내역
```
ce01559  chore: 프로젝트 폴더 구조 및 pubspec 초기 설정
980bdcb  feat: Material3 테마 및 반응형 상수 정의
20678ec  feat: go_router ShellRoute 기반 라우팅 설계
f13c154  feat: 반응형 사이드바 레이아웃 뼈대 구현
7e6e964  feat: Riverpod 다크모드 상태 관리 구현
0b7d5ef  feat: 대시보드 뼈대 화면 및 통계 카드 UI 작성
```

---

## 이슈 및 해결

| # | 이슈 | 원인 | 해결 |
|---|---|---|---|
| 1 | `riverpod_generator` vs `hive_generator` 충돌 | analyzer 버전 범위 불일치 | `riverpod_generator ^2.4.0`으로 다운그레이드 |
| 2 | `withOpacity` deprecated | Flutter 최신 lint 경고 | `.withValues(alpha: ...)` 로 교체 |
| 3 | 불필요한 `__` 사용 | separatorBuilder 파라미터 | `_` 단일 언더스코어로 교체 |
| 4 | `unnecessary_brace_in_string_interps` | `${min}`, `${max}` | `$min`, `$max` 로 수정 |

---

## 내일 예정 (Day 2)

- [ ] `TicketModel` Hive 어댑터 구현 (models/)
- [ ] `TicketService` CRUD 서비스 구현 (services/)
- [ ] `ticketProvider` 상태 관리 구현 (providers/)
- [ ] 티켓 목록 화면 실제 구현 (ticket_list_screen.dart)
- [ ] 티켓 생성 폼 유효성 검사 연동 (ticket_form_screen.dart)

---

## flutter analyze 결과

```
No issues found! (ran in 2.0s)
```
