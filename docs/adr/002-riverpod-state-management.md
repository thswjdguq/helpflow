# ADR 002 — Riverpod 2.x 상태관리 채택

**날짜**: 2025-01-15  
**상태**: 승인됨

---

## 맥락

Flutter 앱에서 상태관리 라이브러리 선택이 필요합니다.
주요 후보: `setState`, `Provider`, `Riverpod`, `Bloc`, `GetX`

이 앱은 다음 요구사항이 있습니다.
- Firestore 실시간 스트림을 여러 화면에서 공유
- 인증 상태 변화에 따라 라우팅 자동 처리
- 역할(admin/agent/user)에 따라 서로 다른 데이터를 구독
- AI Agent(Claude Code)와 협업하는 바이브코딩 환경에서 패턴 일관성 유지

---

## 결정

**Riverpod 2.x** (NotifierProvider + StreamProvider 패턴)을 채택합니다.

---

## 근거

| 기준 | setState | Provider | Riverpod 2.x | Bloc |
|------|----------|---------|-------------|------|
| 전역 상태 공유 | 어려움 | 가능 | 쉬움 | 가능 |
| 스트림 지원 | 직접 구현 | StreamProvider | StreamProvider | StreamBloc |
| 컴파일 타임 안전성 | 낮음 | 낮음 | 높음 | 높음 |
| AI 코드 생성 일관성 | 낮음 | 보통 | 높음 | 보통 |
| 보일러플레이트 | 없음 | 보통 | 보통 | 많음 |

Riverpod을 선택한 핵심 이유:
1. **StreamProvider**: Firestore 스트림을 `ref.watch()`로 구독하면 UI가 자동 갱신.
2. **Provider 간 의존성**: `ticketServiceProvider`를 `ticketListStreamProvider`가 참조하는 방식으로 DI 구조 명확.
3. **AI 패턴 일관성**: Claude Code가 동일한 `AsyncNotifierProvider` 패턴으로 모든 기능을 생성해 코드 일관성 유지.
4. **ref.invalidate()**: 당겨서 새로고침 구현 시 `ref.invalidate(provider)`로 간단히 처리.

---

## 적용 패턴

```dart
// 읽기 전용 스트림 → StreamProvider
final ticketListStreamProvider = StreamProvider<List<TicketModel>>((ref) {
  return ref.watch(ticketServiceProvider).getAllTickets();
});

// 상태 변경 + 비동기 → AsyncNotifierProvider
class TicketNotifier extends AsyncNotifier<List<TicketModel>> {
  Future<void> createTicket(TicketModel ticket) async { ... }
}

// 단순 의존성 → Provider
final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService();
});
```

---

## 결과

- 모든 Provider는 `features/` 디렉토리 내 도메인별로 분리
- `ConsumerWidget` / `ConsumerStatefulWidget`으로 위젯에서 구독
- `ref.watch()` (반응형) vs `ref.read()` (일회성 액션) 용도 구분

---

## 트레이드오프

- Riverpod 2.x는 1.x와 API가 달라 마이그레이션 필요 (이번 프로젝트는 2.x로 시작)
- `AsyncValue<T>`의 `.when()` 처리를 모든 화면에서 반복 작성해야 함
