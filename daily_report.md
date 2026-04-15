# HelpFlow — 작업 일지

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
