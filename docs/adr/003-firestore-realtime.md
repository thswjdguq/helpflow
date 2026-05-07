# ADR 003 — Cloud Firestore 실시간 DB 채택

**날짜**: 2025-01-15  
**상태**: 승인됨

---

## 맥락

헬프데스크 서비스에서 다음이 요구됩니다.
- 티켓 상태 변경 시 모든 관련 사용자에게 즉시 반영
- 관리자 대시보드 통계가 실시간으로 업데이트
- 별도 백엔드 서버 없이 인증·DB·파일 저장을 처리 (2인 소규모 팀)
- 역할별 데이터 접근 제어

---

## 결정

**Cloud Firestore** (Firebase) + **Firebase Authentication** + **Firebase Storage** 조합을 채택합니다.

---

## 근거

| 기준 | Firestore | MySQL/PostgreSQL | Supabase |
|------|-----------|-----------------|---------|
| 실시간 스트림 | ✅ 기본 제공 | ❌ 폴링 필요 | ✅ Realtime 제공 |
| 백엔드 서버 필요 | ❌ 불필요 | ✅ 필요 | △ 선택적 |
| Flutter SDK | ✅ FlutterFire 공식 | ❌ 직접 구현 | ✅ 있음 |
| 인증 통합 | ✅ Firebase Auth | ❌ 별도 구현 | ✅ 있음 |
| 보안 규칙 | ✅ 선언적 규칙 | SQL 권한 | Row Level Security |
| 오프라인 지원 | ✅ 자동 캐싱 | ❌ | △ |

Firestore를 선택한 핵심 이유:
1. **백엔드 불필요**: 2인 팀이 프론트엔드에 집중할 수 있음.
2. **실시간 스트림**: `.snapshots()`가 Dart `Stream`을 반환 → Riverpod `StreamProvider`와 완벽하게 연동.
3. **보안 규칙**: 역할 기반 접근 제어를 `firestore.rules` 파일로 선언적으로 관리.

---

## 컬렉션 설계 결정

### 플랫(flat) 구조 vs 중첩(nested) 구조

댓글을 `tickets/{id}/comments/{id}` 서브컬렉션으로 설계했습니다.

**이유**:
- 티켓 목록 조회 시 댓글을 함께 읽어오지 않아도 됨 (불필요한 데이터 전송 없음)
- 댓글만 별도로 실시간 구독 가능

### 알림 별도 컬렉션

알림을 `notifications/{id}` 최상위 컬렉션으로 설계했습니다.

**이유**:
- `recipientId`로 인덱스를 걸어 특정 사용자의 알림만 빠르게 조회
- 티켓과 독립적으로 읽음 처리 가능

---

## Hive 로컬 캐시 병행

Firestore 외에 **Hive**를 오프라인 캐시로 사용합니다.

```
온라인: Firestore 스트림 → Hive 자동 갱신
오프라인: Hive에서 마지막 데이터 표시 (24시간 TTL)
로그아웃: Hive 캐시 전체 삭제
```

**이유**: Firestore 오프라인 SDK 캐시는 기기 재시작 시 초기화될 수 있어 명시적 캐시 관리가 필요.

---

## 결과

- Firestore 보안 규칙: `helpflow/firestore.rules`
- Firestore 인덱스: `helpflow/firestore.indexes.json`
- Firebase 배포: `firebase deploy --only firestore`

---

## 트레이드오프

- Firestore는 문서 단위 과금 → 대규모 쿼리 시 비용 증가 가능 (이번 프로젝트 규모에선 무료 티어 내)
- 복잡한 JOIN 쿼리는 불가능 → 통계 집계는 클라이언트에서 처리
