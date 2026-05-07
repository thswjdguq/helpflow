# HelpFlow — 시스템 아키텍처

---

## 전체 구조

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                        │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐ │
│  │   Web    │  │ Android  │  │  (iOS - 확장 가능)  │ │
│  │(Chrome)  │  │   App    │  │                    │ │
│  └────┬─────┘  └────┬─────┘  └────────────────────┘ │
│       │              │                               │
│  ┌────▼──────────────▼──────────────────────────┐   │
│  │              Presentation Layer               │   │
│  │  views/ (screens) + shared/widgets/           │   │
│  └────────────────────┬──────────────────────────┘   │
│                       │                               │
│  ┌────────────────────▼──────────────────────────┐   │
│  │              State Layer (Riverpod)            │   │
│  │  features/{auth,tickets,dashboard,             │   │
│  │            notifications,reports}/             │   │
│  └────────────────────┬──────────────────────────┘   │
│                       │                               │
│  ┌────────────────────▼──────────────────────────┐   │
│  │              Service Layer                     │   │
│  │  shared/services/ (TicketService,              │   │
│  │  StorageService, OfflineCacheService, ...)     │   │
│  └────────────────────┬──────────────────────────┘   │
└───────────────────────┼─────────────────────────────┘
                        │ Firebase SDK
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
  ┌──────────┐  ┌──────────────┐  ┌──────────┐
  │ Firebase │  │  Firestore   │  │ Firebase │
  │   Auth   │  │  (실시간 DB)  │  │ Storage  │
  └──────────┘  └──────────────┘  └──────────┘
```

---

## 레이어 설명

### 1. Presentation Layer (`views/`, `shared/widgets/`)
- 화면 렌더링 담당
- `ConsumerWidget` / `ConsumerStatefulWidget` 사용
- 상태는 직접 보유하지 않고 Riverpod Provider를 watch
- 반응형 분기: `LayoutBuilder`로 너비 감지 후 `MainLayout`에서 분기

### 2. State Layer (`features/*/`)
- Riverpod Provider로 서버 상태와 UI 상태를 분리
- `StreamProvider`: Firestore 실시간 스트림 (티켓 목록, 알림)
- `AsyncNotifierProvider`: 비동기 작업 + 상태 변경 (티켓 생성/수정)
- `Provider`: 단순 의존성 주입 (서비스 인스턴스)

### 3. Service Layer (`shared/services/`)
- Firebase SDK 직접 호출
- Presentation/State 레이어가 Firebase에 직접 의존하지 않도록 추상화
- `OfflineCacheService`: Hive 캐시 읽기/쓰기

---

## 데이터 흐름

### 온라인 상태
```
Firestore → StreamProvider(stream) → ConsumerWidget(watch) → UI 자동 갱신
```

### 오프라인 상태
```
Hive.box.get() → Provider → UI (24시간 TTL 확인 후 표시)
```

### 캐시 갱신 시점
```
Firestore 스트림 수신 → OfflineCacheService.save() → Hive 갱신
```

---

## 반응형 레이아웃

```
MainLayout (LayoutBuilder)
├── 너비 ≥ 1024px → _DesktopLayout (SidebarWidget 고정)
├── 너비 ≥ 600px  → _TabletLayout (NavigationRail)
└── 너비 < 600px  → _MobileLayout (BottomNavigationBar)
```

---

## 인증 & 라우팅

```
app.dart
└── GoRouter (app_router.dart)
    ├── redirect 로직: authStateProvider 감지
    │   ├── 미인증 → /login 으로 강제 이동
    │   └── 인증됨 → 요청 경로 통과
    ├── /login, /signup → NoTransitionPage (인증 화면)
    └── ShellRoute (MainLayout 감싸기)
        ├── /dashboard → FadeTransition
        ├── /tickets   → FadeTransition
        ├── /notifications → FadeTransition
        ├── /reports   → FadeTransition (admin only)
        └── /admin/users → FadeTransition (admin only)
```

---

## 역할 기반 접근 제어 (RBAC)

### Flutter 앱 레벨
```dart
// 역할에 따라 UI 분기
final role = ref.watch(currentUserProvider).value?.role;
if (role == UserRole.admin) { ... }
```

### Firestore 보안 규칙 레벨
```javascript
// 티켓: 본인 또는 admin만 수정 가능
allow update: if resource.data.reporterId == request.auth.uid || isAdmin();

// 알림: 수신자 본인만 읽기 가능
allow read: if resource.data.recipientId == request.auth.uid;
```

---

## 의존성 그래프 (주요 Provider)

```
authStateProvider (StreamProvider<User?>)
    └── currentUserProvider (StreamProvider<UserModel?>)
            ├── ticketListStreamProvider
            ├── myTicketListStreamProvider
            ├── myAssignedTicketListProvider
            ├── notificationListProvider
            └── unreadNotificationCountProvider

ticketServiceProvider (Provider<TicketService>)
    ├── ticketListStreamProvider
    └── ticketProvider (AsyncNotifierProvider)

offlineCacheServiceProvider (Provider<OfflineCacheService>)
    └── ticketProvider (캐시 읽기/쓰기)
```

---

## 디렉토리 구조 (역할별)

```
lib/
├── core/           # 앱 전역 설정 (라우터, 테마, 상수)
├── features/       # 도메인별 상태 관리 (Provider)
├── shared/         # 재사용 모델·서비스·위젯
└── views/          # 화면 UI

핵심 원칙: features/ → shared/ 단방향 의존
           views/ → features/ + shared/ 참조
           shared/ → 외부 의존 없음 (순수 레이어)
```
