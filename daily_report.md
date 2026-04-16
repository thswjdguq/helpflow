# HelpFlow — 작업 일지

---

## 2026-04-16 (2주차 계속 — Firestore 보안 규칙)

### 작업 내용
**Firestore 보안 규칙 + 복합 인덱스 설정 및 배포**

#### 변경 파일
| 파일 | 변경 내용 |
|------|---------|
| `firestore.rules` | 역할 기반 보안 규칙 전체 작성 |
| `firestore.indexes.json` | 복합 인덱스 4종 정의 |
| `firebase.json` | firestore rules/indexes 섹션 추가 |

#### 보안 규칙 상세
- **users 컬렉션**: 본인만 읽기, 생성 시 role='user' 강제, 수정/삭제는 admin만
- **tickets 컬렉션**:
  - 읽기: admin/agent 전체, user는 본인 접수 티켓만
  - 생성: user만, reporterId=본인uid, status='new' 강제
  - 수정: admin 전체, agent는 본인 배정+in_progress→resolved만, user는 new 상태에서 내용만
  - 삭제: admin만
- **comments 서브컬렉션**: isInternal=true는 admin/agent만 작성, 삭제는 작성자 본인 또는 admin
- **assets 컬렉션**: 로그인 사용자 읽기, 쓰기는 admin만

#### 복합 인덱스
- `tickets`: reporterId + createdAt(desc)
- `tickets`: agentId + createdAt(desc)
- `tickets`: status + createdAt(desc)
- `comments`: ticketId + createdAt(asc)

#### 배포
- `firebase deploy --only firestore:rules` → 성공
- `firebase deploy --only firestore:indexes` → 성공

#### 커밋
- `feat: Firestore 보안 규칙 + 복합 인덱스 설정 및 배포`

### flutter analyze
- 0 issues

---

## 2026-04-16 (2주차 계속)

### 작업 내용
**검색·필터 고도화 + 상단 바 사용자 정보 + 설정 화면 + 모바일 FAB**

#### 변경 파일
| 파일 | 변경 내용 |
|------|---------|
| `ticket_list_screen.dart` | 키워드 검색 바 추가 (제목·설명·접수자 대상, 하이라이트) |
| `top_bar_widget.dart` | 로그인 사용자 아바타·이름·역할 표시, 새 티켓 버튼 user만 표시 |
| `settings_screen.dart` | 계정 카드 + 다크모드 스위치 + 앱 정보 + 로그아웃 확인 다이얼로그 |
| `main_layout.dart` | 모바일 user 역할 전용 FAB (대시보드·티켓 목록에서만 표시) |

#### 기능 상세
- **검색**: 상태 필터 + 키워드 조합 검색, 결과 없을 때 `search_off` 아이콘 EmptyState
- **검색 하이라이트**: 일치 구간을 RichText로 primary 색상 강조
- **상단 바**: 태블릿 이상에서 이름+역할 텍스트, 모바일에서는 아바타만
- **설정 화면**: 섹션 그룹화(계정/앱 설정/앱 정보), 로그아웃 확인 다이얼로그
- **모바일 FAB**: user 역할이 대시보드·티켓 목록에 있을 때만 표시

#### 커밋
- `feat: 검색·필터 고도화 + 상단 바 사용자 정보 + 설정 화면 + 모바일 FAB`

### flutter analyze
- 0 issues

---

## 2026-04-15 (2주차)

### 작업 내용
**역할별 대시보드 + 티켓 목록 분리 (실제 헬프데스크 UX)**

#### 변경 파일
| 파일 | 변경 내용 |
|------|---------|
| `ticket_service.dart` | `getTicketsByAgent(agentId)` 메서드 추가 |
| `ticket_provider.dart` | `myAssignedTicketListProvider` 추가 (agent 전용) |
| `dashboard_provider.dart` | `myAgentStatsProvider`, `myAgentRecentTicketsProvider`, `myUserStatsProvider`, `myUserRecentTicketsProvider` 추가 |
| `dashboard_screen.dart` | 역할별 대시보드 3종 분기 |
| `ticket_list_screen.dart` | 역할별 Provider 분기 + user 전용 상단 헤더 |

#### 역할별 UX 변경
- **admin 대시보드**: 전체 현황 통계 카드 + 상태별 바 차트 + 최근 전체 티켓
- **agent 대시보드**: 내 배정 통계 카드 + 처리 대기 배너(처리 중 건수 강조) + 최근 배정 티켓
- **user 대시보드**: 내 접수 통계 카드 + 새 티켓 접수 CTA 배너 + 최근 내 티켓
- **admin 티켓 목록**: 전체 티켓 + 배정 여부 표시
- **agent 티켓 목록**: 내 배정 티켓만 (이전: 전체 티켓 오표시 → 수정)
- **user 티켓 목록**: 내 접수 티켓 + 상단 새 티켓 접수 버튼

#### 커밋
- `feat: 역할별 대시보드 + 티켓 목록 분리 (admin/agent/user)` → week-02, main 병합 완료

### flutter analyze
- 0 issues

---
