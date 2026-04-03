# HelpFlow — 프로젝트 컨텍스트

## 이 파일의 목적
이 파일은 Claude Code가 작업 시작 전 **가장 먼저 읽는 루트 컨텍스트**다.
새 대화를 시작할 때마다 이 파일을 먼저 읽고 프로젝트 전체 구조를 파악한 뒤 작업한다.

---

## 프로젝트 한 줄 요약
> IT 기기·소프트웨어 문제를 쉽게 접수하고 해결받는 Flutter 기반 크로스플랫폼 헬프데스크 플랫폼.
> 웹(관리자·직원)과 모바일 앱(현장 담당자)을 단일 Flutter 코드베이스로 구현한다.

## 설계 철학
> "접수는 쉽게, 처리는 빠르게, 이력은 투명하게."

---

## 기술 스택

| 분류 | 기술 | 비고 |
|------|------|------|
| Framework | Flutter 3.x + Dart | 웹/앱 단일 코드베이스 |
| 상태관리 | Riverpod 2.x (NotifierProvider 패턴 고정) | 바이브코딩 AI 패턴 일관성 |
| 인증 | Firebase Authentication (이메일/비밀번호) | 이미 연결 완료 |
| DB | Cloud Firestore | 실시간 스트림 지원 |
| 파일 저장 | Firebase Storage | 첨부 이미지 업로드 |
| 푸시 알림 | Firebase Cloud Messaging (FCM) | 10주차 구현 예정 |
| 로컬 캐시 | Hive | 오프라인 대응 |
| QR 스캔 | mobile_scanner | 10주차 구현 예정 (FCM과 택1) |
| 라우팅 | go_router (ShellRoute 구조) | 이미 설정 완료 |
| 디자인 | 토스(Toss) 스타일 | 흰 배경 #FFFFFF, radius 12, 넓은 여백 |

---

## 사용자 역할 & 권한

| 역할 | 코드 | 플랫폼 | 주요 기능 |
|------|------|--------|---------|
| 직원 | `user` | 웹 브라우저 | 티켓 접수 / 내 티켓 현황 조회 |
| 현장 담당자 | `agent` | 모바일 앱 | 알림 수신 / 티켓 처리 / QR 스캔 |
| 관리자 | `admin` | 웹 브라우저 | 담당자 배정 / 대시보드 / 전체 관리 |

---

## 핵심 데이터 흐름

```
직원(user) → 티켓 접수 (제목/내용/사진)
    ↓
Firestore tickets 컬렉션 저장 (status: new)
    ↓
admin → 담당자(agent) 배정 (status: in_progress)
    ↓
agent → 처리 완료 입력 (status: resolved)
    ↓
자동 종료 또는 admin 최종 확인 (status: closed)
    ↓
대시보드에서 전체 현황 실시간 조회
```

---

## 티켓 상태 흐름

```
new → in_progress → resolved → closed
```

| 상태 | 의미 | 변경 권한 |
|------|------|---------|
| `new` | 접수 직후 | 자동 (접수 시) |
| `in_progress` | 담당자 처리 시작 | admin (배정 시 자동) |
| `resolved` | 처리 완료 | agent |
| `closed` | 최종 종료 (재변경 불가) | admin |

---

## Firestore 컬렉션 구조

```
users/{userId}
  ├─ uid, email, name, role, createdAt

tickets/{ticketId}
  ├─ id, title, description, category
  ├─ status, priority
  ├─ reporterId, agentId
  ├─ imageUrls (List<String>)
  ├─ createdAt, updatedAt

assets/{assetId}  ← 추후 구현
  ├─ name, type, location, serialNumber, qrCodeUrl
```

---

## 폴더 구조

```
helpflow/
├── claude.md              ← 📌 이 파일 (루트 컨텍스트, 항상 먼저 읽기)
├── todo.md                ← 우선순위 & 주차별 TODO 체크리스트
├── daily_report.md        ← 작업 완료 후 매번 업데이트
├── lib/
│   ├── main.dart          ← Firebase 초기화 + ProviderScope
│   ├── app.dart           ← MaterialApp.router + 테마 + 인증 분기
│   ├── firebase_options.dart ← .gitignore 처리됨 (절대 커밋 금지)
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_sizes.dart      ← 반응형 브레이크포인트 상수
│   │   │   └── app_strings.dart    ← 문자열 상수
│   │   ├── theme/
│   │   │   ├── app_theme.dart      ← Material3 라이트/다크 테마
│   │   │   └── design_system.dart  ← 토스 스타일 색상/타이포/버튼
│   │   └── router/
│   │       └── app_router.dart     ← go_router ShellRoute 라우팅
│   ├── features/
│   │   ├── auth/
│   │   │   ├── user_model.dart     ← UserModel (uid/email/name/role)
│   │   │   ├── auth_service.dart   ← Firebase Auth CRUD
│   │   │   ├── auth_provider.dart  ← Riverpod 인증 상태
│   │   │   ├── login_screen.dart   ← 로그인 화면
│   │   │   └── signup_screen.dart  ← 회원가입 화면
│   │   ├── tickets/
│   │   │   ├── ticket_provider.dart← Riverpod 티켓 상태
│   │   │   ├── ticket_list_screen.dart
│   │   │   ├── ticket_detail_screen.dart
│   │   │   └── ticket_form_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── notifications/          ← 10주차 구현 예정
│   │   └── settings/
│   │       └── settings_screen.dart
│   ├── shared/
│   │   ├── models/
│   │   │   └── ticket_model.dart   ← TicketModel + Firestore 연동
│   │   ├── services/
│   │   │   ├── firebase_service.dart ← 공통 에러 처리
│   │   │   └── ticket_service.dart   ← Firestore CRUD
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── loading_indicator.dart
│   │       └── empty_state_widget.dart
│   └── views/
│       └── layout/
│           ├── main_layout.dart    ← 반응형 사이드바/하단바 레이아웃
│           ├── sidebar_widget.dart ← 웹 사이드바
│           └── top_bar_widget.dart ← 상단 앱바
└── android/
    └── app/
        └── google-services.json   ← .gitignore 처리됨 (절대 커밋 금지)
```

---

## 반응형 레이아웃 분기

```
웹 (≥ 1024px)   → 사이드바 고정 표시
태블릿 (≥ 600px) → 아이콘만 보이는 미니 레일
모바일 (< 600px) → 하단 내비게이션 바
```

---

## 코딩 규칙 (항상 준수)

1. **보편적 문법**: GitHub 오픈소스에서 가장 많이 쓰이는 정석 문법만 사용. 생소하거나 실험적인 문법 금지.
2. **한글 주석**: 모든 클래스·함수·복잡한 로직에 상세한 한글 주석 필수.
3. **파일 요약**: 각 파일 맨 하단에 아래 형식으로 작성:
   ```
   // ============================================================
   // [파일 요약]
   // 파일명: xxx.dart
   // 역할: 한 줄 설명
   // 주요 클래스/함수: 목록
   // 연관 파일: 관련 파일명
   // ============================================================
   ```
4. **lint 준수**: flutter_lints 준수, Deprecated 문법 금지. 파일 완성 시 flutter analyze 실행.
5. **파일 분리**: 위젯·클래스 100줄 초과 시 별도 파일로 분리.
6. **보안**: API 키·토큰·비밀번호 하드코딩 금지. 커밋 전 git status로 민감 파일 확인.
7. **커밋**: 기능 하나 완성 시마다 커밋. 한 번에 몰아서 커밋 금지.
8. **daily_report.md**: 모든 작업 완료 후 반드시 맨 위에 오늘 작업 내용 추가.

---

## 보안 규칙 (.gitignore 필수 항목)

```
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
.env
*.key
```

---

## 개발 단계 (14주)

### Phase 1 — 기반 (1~3주차) ← 현재
Firebase 연결, 인증(로그인/회원가입), 기본 레이아웃

### Phase 2 — 핵심 기능 (4~6주차)
티켓 CRUD, 상태 관리, 담당자 배정

### Phase 3 — 관리자 기능 (7~8주차)
대시보드 실데이터 연동, 통계 차트

### Phase 4 — 모바일 최적화 (9주차)
하단 네비게이션, 모바일 전용 UI

### Phase 5 — 부가 기능 (10주차, 택1)
QR 스캔 **또는** FCM 푸시 알림 (둘 중 하나만)

### Phase 6 — 완성도 (11~12주차)
UI Polish, 토스 스타일 완성, 예외 처리

### Phase 7 — 안정화 (13주차)
버그 수정, flutter analyze 오류 0개, 리팩토링

### Phase 8 — 마무리 (14주차)
README 완성, 포트폴리오 정리, 발표 자료
