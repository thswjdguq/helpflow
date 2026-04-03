# HelpFlow 개발 진행 현황

> 마지막 업데이트: 2026-03-19
> 브랜치: main (week-01, week-02 머지 완료) / 진행 중: week-02 (Firebase 인증 작업)

---

## 📁 프로젝트 기본 정보

| 항목 | 내용 |
|------|------|
| 프로젝트명 | HelpFlow |
| 설명 | IT 헬프데스크 운영 관리 플랫폼 |
| 플랫폼 | Flutter (웹 + 앱 반응형) |
| 상태 관리 | Riverpod (NotifierProvider 패턴) |
| 라우팅 | go_router (ShellRoute 구조) |
| 로컬 DB | Hive |
| 원격 DB | Firebase (Firestore) |
| GitHub | https://github.com/thswjdguq/helpflow |

---

## ✅ Week 1 — 프로젝트 초기 세팅

### 완료된 작업

#### 폴더 구조 생성
```
helpflow/lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       # 앱 색상 상수
│   │   ├── app_strings.dart      # 앱 문자열 상수
│   │   └── app_sizes.dart        # 반응형 브레이크포인트 및 크기 상수
│   ├── theme/
│   │   ├── app_theme.dart        # Material3 라이트/다크 테마
│   │   └── app_text_styles.dart  # 텍스트 스타일 정의
│   ├── router/
│   │   └── app_router.dart       # go_router ShellRoute 기반 라우터
│   └── utils/
│       ├── date_utils.dart       # 날짜 유틸 함수
│       └── validators.dart       # 입력값 유효성 검사
├── models/                       # (빈 폴더, 모델 클래스 예정)
├── services/                     # (빈 폴더, 서비스 클래스 예정)
├── providers/
│   └── theme_provider.dart       # 다크모드 상태 관리 (Riverpod)
├── views/
│   ├── layout/
│   │   ├── main_layout.dart      # 반응형 3단계 레이아웃
│   │   ├── sidebar_widget.dart   # 사이드바 네비게이션
│   │   └── top_bar_widget.dart   # 상단 바
│   ├── dashboard/
│   │   └── dashboard_screen.dart # 대시보드 (통계 카드 4개)
│   ├── tickets/
│   │   ├── ticket_list_screen.dart
│   │   ├── ticket_detail_screen.dart
│   │   └── ticket_form_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── shared/
│   └── widgets/
│       ├── custom_button.dart    # 공통 버튼 위젯
│       ├── loading_indicator.dart
│       └── empty_state_widget.dart
├── app.dart                      # MaterialApp.router 루트 위젯
└── main.dart                     # 앱 진입점 (Hive 초기화)
```

#### pubspec.yaml 의존성
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  hive_flutter: ^1.1.0
  go_router: ^14.2.7
  material_symbols_icons: ^4.2719.1
  # fl_chart: ^0.68.0  ← 7~8주차 활성화 예정

dev_dependencies:
  build_runner: ^2.4.13
  hive_generator: ^2.0.1
  riverpod_generator: ^2.4.0
  flutter_lints: ^6.0.0
```

#### 핵심 구현 사항
- **반응형 레이아웃**: 데스크탑(≥1024px) 고정 사이드바 / 태블릿(≥600px) 미니 레일 / 모바일 Drawer
- **테마**: Material3, 씨드 컬러 `#0057FF`, 라이트/다크 모두 구현
- **라우팅**: `/dashboard`, `/tickets`, `/tickets/:id`, `/tickets/new`, `/settings`
- **상태 관리**: `themeProvider` (NotifierProvider)로 다크모드 토글

#### 커밋 이력
```
ce01559  chore: 프로젝트 폴더 구조 및 pubspec 초기 설정
980bdcb  feat: Material3 테마 및 반응형 상수 정의
20678ec  feat: go_router ShellRoute 기반 라우팅 설계
f13c154  feat: 반응형 사이드바 레이아웃 뼈대 구현
7e6e964  feat: Riverpod 다크모드 상태 관리 구현
0b7d5ef  feat: 대시보드 뼈대 화면 및 통계 카드 UI 작성
330b5cf  docs: daily_report.md 1주차 Day 1 작성
```

---

## ✅ Week 2 — 디자인 시스템 + Firebase 인증 (진행 중)

### 완료된 작업

#### 디자인 시스템 (`lib/core/design_system.dart`)
토스(Toss) 스타일 디자인 토큰 통합 관리:

| 클래스 | 내용 |
|--------|------|
| `HelpFlowColors` | primary `#0057FF`, background `#FFFFFF`, surface `#F8F9FA`, gray 계열, error `#FF4D4F` |
| `HelpFlowTextStyles` | 시스템 폰트, headline1~3 / body1~2 / caption / button |
| `HelpFlowButtonStyles` | FilledButton / OutlinedButton / TextButton, radius 12 |
| `HelpFlowSpacing` | 4 / 8 / 12 / 16 / 20 / 24 / 32px 여백 상수 |

#### 레이아웃 업데이트 (`lib/views/layout/main_layout.dart`)
- 모바일(< 600px): 하단 내비게이션 바 추가 (홈 / 티켓 / 설정)
- 600px 이상: 기존 사이드바 레이아웃 유지

#### Firebase 패키지 추가
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_storage: ^12.0.0
```

#### Firebase 인증 구조 (`lib/features/auth/`)
| 파일 | 상태 | 역할 |
|------|------|------|
| `user_model.dart` | ✅ 완료 | uid/email/name/role/createdAt 모델, fromFirestore/toMap |
| `auth_service.dart` | ✅ 완료 | signInWithEmail / signUpWithEmail / signOut |
| `auth_provider.dart` | ✅ 완료 | authStateProvider (StreamProvider), currentUserProvider (AsyncNotifierProvider) |
| `login_screen.dart` | 🔄 진행 중 | 토스 스타일 로그인 UI |
| `signup_screen.dart` | ⏳ 대기 | 회원가입 UI |

#### 공통 서비스 (`lib/shared/services/firebase_service.dart`)
- `handleFirebaseError()`: FirebaseAuthException 에러 코드 → 한글 메시지 변환

### ⚠️ 남은 작업
- [ ] `login_screen.dart` 구현
- [ ] `signup_screen.dart` 구현
- [ ] `app_router.dart`에 `/login`, `/signup` 경로 추가
- [ ] `main.dart` Firebase.initializeApp() 연결
- [ ] `app.dart` 인증 상태 기반 화면 분기

### ⚠️ 주의 사항
`firebase_options.dart`는 현재 **플레이스홀더** 상태입니다.
실제 Firebase 프로젝트 연결 전에 아래 명령을 실행해야 합니다:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

#### 커밋 이력
```
06a133d  feat: HelpFlow 디자인 시스템 정의 (colors, typography, spacing)
792b920  feat: app_theme 디자인 시스템 연동
7552a5c  feat: 모바일 하단 내비게이션 바 추가 (600px 미만)
2ef70ad  feat: 전체 화면 배경색 통일
```

---

## 🗓️ 예정 작업

| 주차 | 주요 작업 |
|------|-----------|
| Week 2 (잔여) | 로그인/회원가입 화면, 라우터 인증 가드 |
| Week 3 | 티켓 모델 (Hive + Firestore), 티켓 목록/상세/생성 화면 |
| Week 4 | 티켓 상태 관리 (접수→처리중→완료), 필터/검색 |
| Week 5~6 | 대시보드 실데이터 연동, 역할별 권한 분기 |
| Week 7~8 | fl_chart 연동, 리포트 화면, 통계 차트 |

---

## 🔒 코딩 규칙 (프로젝트 전체 적용)

1. 보편적/정석 문법만 사용 (생소하거나 실험적인 문법 금지)
2. 모든 함수·클래스·로직에 상세한 **한글 주석** 필수
3. 각 파일 하단에 `[파일 요약]` 작성
4. `flutter_lints` 준수, Deprecated 문법 금지
5. 위젯/클래스가 100줄 넘으면 별도 파일로 분리
6. 파일 완성할 때마다 `flutter analyze` 실행 후 오류 없으면 진행
7. 커밋: 기능 하나 완성 시마다 (한 번에 몰아서 커밋 금지)
