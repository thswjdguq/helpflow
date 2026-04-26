# HelpFlow 🛠️
> Flutter 크로스플랫폼 기반 경량 헬프데스크 플랫폼

웹(직원·관리자)과 모바일 앱(현장 담당자)을 **단일 Flutter 코드베이스**로 구현한 헬프데스크 서비스입니다.

---

## 📌 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 프로젝트명 | HelpFlow |
| 개발 기간 | 14주 (2025.01 ~ 2025.04) |
| 팀 구성 | 2인 (바이브코딩) |
| 타겟 직군 | IT기업 헬프데스크 / ITSM 직군 |
| 기술 스택 | Flutter 3.x · Firebase · Riverpod 2.x |
| 현재 상태 | Phase 8 완료 — 전 기능 구현 완료 |

---

## 💡 기획 배경

중소 IT 조직의 헬프데스크 업무는 여전히 이메일·메신저·전화로 운영되는 경우가 많습니다.
이로 인해 **신고 누락, 현장 소통 단절, 처리 이력 소실** 문제가 반복됩니다.

HelpFlow는 Flutter의 크로스플랫폼 특성을 활용해 이 문제를 해결합니다.

- 직원 → 웹 브라우저에서 앱 설치 없이 티켓 접수
- 현장 담당자 → 모바일 앱으로 실시간 알림 수신
- 관리자 → 웹 대시보드에서 전체 현황 실시간 모니터링

---

## 👥 사용자 역할

| 역할 | 플랫폼 | 주요 기능 |
|------|--------|-----------| 
| USER (직원) | 웹 브라우저 | 티켓 접수 / 내 티켓 현황 조회 |
| AGENT (현장 담당자) | 모바일 앱 | 알림 수신 / 티켓 처리 |
| ADMIN (관리자) | 웹 브라우저 | 담당자 배정 / 대시보드 / 사용자 관리 |

---

## ✅ 구현 완료 기능

### P0 — 핵심 기능 (완료)
- ✅ 이메일 로그인 / 회원가입 (Firebase Auth)
- ✅ 역할별 화면 분기 (user/agent/admin)
- ✅ 비로그인 시 대시보드 접근 차단 (라우팅 가드)
- ✅ 로그아웃 시 자동 로그인 화면 이동
- ✅ 티켓 접수 — 제목·내용·카테고리·우선순위·사진 첨부
- ✅ 티켓 목록 — 전체 / 내 티켓 / 내 배정 티켓 필터
- ✅ 티켓 상세 — 타임라인, 댓글, 이미지 첨부
- ✅ 티켓 상태 변경 NEW → IN_PROGRESS → RESOLVED → CLOSED
- ✅ 담당자(agent) 배정 기능 (admin 전용)
- ✅ Firebase Storage 이미지 업로드
- ✅ Firestore 보안 규칙 (역할별 접근 제어)

### P1 — 차별화 기능 (완료)
- ✅ 관리자 대시보드 — 실시간 통계 + fl_chart 바 차트
- ✅ 통계 리포트 — 카테고리별·우선순위별·일별 트렌드 차트
- ✅ 최근 티켓 목록 실데이터 연동
- ✅ 사용자 관리 화면 (admin 전용)
- ✅ 인앱 알림 (Firestore 실시간) — 배지 + 목록 화면
- ✅ 티켓 배정/해결/댓글 시 알림 자동 생성
- ✅ 반응형 레이아웃 (모바일 하단 바 / 태블릿 레일 / 데스크탑 사이드바)
- ✅ 검색 / 필터 기능 (키워드 + 상태별)
- ✅ 검색어 하이라이트 표시
- ✅ 화면 전환 페이지 애니메이션 (Fade + Slide)
- ✅ 에러 화면 처리 (ErrorView 위젯)
- ✅ 빈 상태 처리 (EmptyStateWidget)
- ✅ 오프라인 대응 — Hive 로컬 캐시 (24시간 유효)
- ✅ 스켈레톤 로딩 UI (토스 스타일 pulse 애니메이션)
- ✅ 당겨서 새로고침 (RefreshIndicator)

### P2 — 향후 예정 (미완료)
- [ ] FCM 실제 푸시 (Cloud Functions 필요)
- [ ] QR 스캔 (mobile_scanner 패키지)

---

## 🗂️ 티켓 상태 흐름

```
NEW → IN_PROGRESS → RESOLVED → CLOSED
```

| 상태 | 의미 | 변경 권한 |
|------|------|---------|
| NEW | 직원 접수 직후 | 자동 (접수 시) |
| IN_PROGRESS | 담당자 처리 시작 | admin (배정 시 자동) |
| RESOLVED | 처리 완료 | agent |
| CLOSED | 최종 종료 (재변경 불가) | admin |

---

## 🛠️ 기술 스택

| 영역 | 기술 | 이유 |
|------|------|------|
| 프론트엔드 | Flutter 3.x + Dart | 웹/앱 단일 코드베이스 |
| 상태관리 | Riverpod 2.x | NotifierProvider 패턴 일관성 |
| 인증 | Firebase Authentication | 별도 백엔드 없이 즉시 구현 |
| DB | Cloud Firestore | 실시간 스트림 지원 |
| 파일 저장 | Firebase Storage | 첨부 이미지 업로드 |
| 로컬 캐시 | Hive | 오프라인 대응 (24h 캐시) |
| 차트 | fl_chart | 대시보드 통계 시각화 |
| 폰트 | Google Fonts (Noto Sans KR) | 한글 렌더링 안정성 |
| 라우팅 | go_router | ShellRoute 기반 레이아웃 |

---

## 🚀 시작하기

### 사전 준비

- Flutter SDK 3.x 이상
- Dart 3.x 이상
- Firebase 프로젝트 (Firestore, Auth, Storage 활성화)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/thswjdguq/helpflow.git
cd helpflow/helpflow

# 2. 패키지 설치
flutter pub get

# 3. Firebase 연결 (본인 프로젝트로 교체)
flutterfire configure

# 4. 웹 실행
flutter run -d chrome

# 5. Android 실행
flutter run -d android
```

> **주의**: `lib/firebase_options.dart`와 `android/app/google-services.json`은 `.gitignore`에 포함되어 있어 직접 발급이 필요합니다.

### 테스트 계정 설정

Firebase Console > Authentication에서 다음 계정 생성 후 Firestore `users` 컬렉션에 문서 추가:

```json
// users/{uid}
{
  "uid": "Firebase Auth UID",
  "email": "admin@test.com",
  "name": "관리자",
  "role": "admin",
  "createdAt": "Timestamp"
}
```

역할: `admin` / `agent` / `user`

---

## 📁 폴더 구조

```
lib/
├── core/
│   ├── constants/      # app_sizes, app_strings
│   ├── theme/          # app_theme, design_system (토스 스타일)
│   └── router/         # app_router (ShellRoute + 인증 가드)
├── features/
│   ├── auth/           # 로그인·회원가입 (AuthService, AuthProvider)
│   ├── tickets/        # TicketProvider (CRUD + 캐시 연동)
│   ├── dashboard/      # DashboardProvider (통계 집계)
│   ├── reports/        # ReportsProvider (차트 데이터)
│   └── notifications/  # NotificationProvider (인앱 알림)
├── shared/
│   ├── models/         # TicketModel, CommentModel, NotificationModel
│   ├── services/       # TicketService, StorageService, OfflineCacheService
│   └── widgets/        # EmptyStateWidget, ErrorView, SkeletonLoader
├── views/
│   ├── layout/         # MainLayout, SidebarWidget, TopBarWidget
│   ├── dashboard/      # DashboardScreen (admin/agent/user 분기)
│   ├── tickets/        # TicketListScreen, TicketDetailScreen, TicketFormScreen
│   ├── notifications/  # NotificationsScreen
│   ├── reports/        # ReportsScreen (통계 차트)
│   └── admin/          # AdminUserManagementScreen
├── app.dart
└── main.dart
```

---

## 🗓️ 개발 로드맵

| Phase | 주차 | 내용 | 상태 |
|-------|------|------|------|
| Phase 1 | 1~3주 | 환경 세팅, Firebase 연결, 인증 흐름 | ✅ 완료 |
| Phase 2 | 4~6주 | 티켓 CRUD, 상태 변경, Firestore 보안 규칙 | ✅ 완료 |
| Phase 3 | 7~8주 | 관리자 대시보드, 통계 차트, 사용자 관리 | ✅ 완료 |
| Phase 4 | 9주 | 모바일 최적화, 반응형 레이아웃 | ✅ 완료 |
| Phase 5 | 10주 | 인앱 알림, 알림 뱃지, 자동 알림 생성 | ✅ 완료 |
| Phase 6 | 11~12주 | 검색/필터, 에러 처리, 오프라인 캐시, 스켈레톤 UI | ✅ 완료 |
| Phase 7 | 13주 | 코드 품질 (flutter analyze 0 issues) | ✅ 완료 |
| Phase 8 | 14주 | README, 포트폴리오 정리, GitHub 태그 | ✅ 완료 |

---

## 🗃️ Firestore 컬렉션 구조

```
users/{userId}
  ├─ uid, email, name, role, createdAt

tickets/{ticketId}
  ├─ title, description, category
  ├─ status, priority
  ├─ reporterId, reporterName, agentId
  ├─ imageUrls, resolution
  ├─ createdAt, updatedAt
  └─ comments/{commentId}
      ├─ content, authorId, authorName, isInternal
      └─ createdAt

notifications/{notificationId}
  ├─ recipientId, type, ticketId, ticketTitle
  ├─ message, isRead
  └─ createdAt
```

---

## 🔧 코드 품질

```
flutter analyze → No issues found! (0 errors, 0 warnings, 0 hints)
```

### 오프라인 캐시 전략
- **온라인**: Firestore 스트림 수신 → Hive Box 자동 갱신
- **오프라인**: 마지막 저장 데이터 표시 (24시간 유효)
- **로그아웃**: 캐시 전체 삭제 (사용자 데이터 분리)

---

## 🌿 브랜치 전략

```
main         ← 최종 배포본
week-01~05   ← 주차별 작업 브랜치
feat/xxx     ← 기능 단위 개발 브랜치
fix/xxx      ← 버그 수정
```

### 커밋 메시지 규칙
```
feat:     기능 추가
fix:      버그 수정
style:    UI 변경
docs:     문서 수정
refactor: 리팩토링
chore:    빌드·설정 변경
```

---

## 👨‍💻 팀 분업

| 담당 | 영역 |
|------|------|
| A | 웹 화면 (티켓 접수·관리, 대시보드, 통계 리포트) |
| B | 모바일 앱 화면 (티켓 처리, 알림, 오프라인 캐시) |

---

## 📸 스크린샷

> 준비 중

---

## 📝 포트폴리오 포인트

1. **단일 코드베이스 크로스플랫폼**: Flutter 하나로 웹(Chrome)과 Android 앱을 동시 지원. 중복 개발 비용 제로.
2. **역할 기반 접근 제어(RBAC)**: user/agent/admin 세 가지 역할에 따라 UI, 라우팅, Firestore 보안 규칙이 모두 분기.
3. **실시간 데이터 동기화**: Firestore StreamProvider로 티켓·알림·대시보드가 모두 실시간 반영. 새로고침 불필요.
4. **오프라인 대응**: Hive 로컬 캐시로 네트워크 없이도 최근 데이터 열람 가능 (24h TTL).
5. **토스 스타일 디자인 시스템**: 색상·여백·반경·타이포를 `design_system.dart`로 단일 관리. 디자인 일관성 보장.
6. **반응형 레이아웃**: 화면 너비에 따라 사이드바(≥1024px) → 레일(≥600px) → 하단바(<600px)로 자동 전환.
7. **Riverpod 2.x 상태 관리**: AsyncNotifierProvider + StreamProvider 패턴으로 서버 상태와 UI 상태를 명확히 분리.
