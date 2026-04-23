# HelpFlow — 작업 일지

---

## 2026-04-23 (4주차)

### 작업 내용
**인앱 알림 시스템 + 페이지 전환 애니메이션 + 에러 화면 + 보안 규칙 배포**

#### 신규/변경 파일
| 파일 | 변경 내용 |
|------|---------|
| `notification_model.dart` | 알림 데이터 모델 + NotificationType 상수 |
| `notification_service.dart` | Firestore 알림 CRUD (생성/목록/읽음처리) |
| `notification_provider.dart` | 알림 목록 + 미읽음 카운트 실시간 스트림 |
| `notifications_screen.dart` | 알림 목록 화면 + 읽음/미읽음 스타일 분기 |
| `ticket_detail_screen.dart` | 배정/해결/댓글 시 알림 자동 생성 |
| `top_bar_widget.dart` | 알림 벨 아이콘 + 미읽음 뱃지 |
| `app_router.dart` | /notifications 경로 + _fadePage 전환 애니메이션 |
| `error_view.dart` | 공통 에러 표시 위젯 (아이콘 + 메시지 + 재시도) |
| `ticket_list_screen.dart` | ErrorView 적용 + 재시도 버튼 |
| `reports_screen.dart` | ErrorView 적용 + 재시도 버튼 |
| `firestore.rules` | notifications 컬렉션 보안 규칙 추가 |
| `firestore.indexes.json` | notifications 복합 인덱스 2종 추가 |
| `todo.md` | Phase 5 항목 재정의 (FCM→인앱 알림), 4주차 브랜치 업데이트 |

#### 기능 상세
- **인앱 알림**:
  - 티켓 배정 → 해당 agent 알림
  - 티켓 resolved/closed → reporter 알림
  - 댓글 작성(공개) → 상대방 알림
  - 알림 화면: 최신순 목록, 타입별 아이콘/색상, 미읽음 파란 점 표시
  - "모두 읽음" 일괄 처리 (WriteBatch)
  - 탭 → 해당 티켓 상세 이동
- **상단 바**: 알림 벨 아이콘 + 미읽음 수 빨간 뱃지 (99+까지 표시)
- **페이지 전환**: NoTransitionPage → _fadePage (200ms fade) 전체 적용
- **에러 화면**: 공통 ErrorView 위젯 (아이콘 + 메시지 + 재시도 버튼)
- **Firestore 배포**: 알림 규칙 + 인덱스 2종 배포 완료

#### 커밋
- `feat: 인앱 알림 시스템 + 페이지 전환 애니메이션 + 에러 화면 개선`

### flutter analyze
- 0 issues

---

## 2026-04-17 (3주차)

### 작업 내용
**통계 리포트 화면 + 모바일 UI 최적화 + 반응형 레이아웃 점검**

#### 변경/신규 파일
| 파일 | 변경 내용 |
|------|---------|
| `reports_provider.dart` | 전체 티켓 통계 집계 Provider (상태/카테고리/우선순위/일별 추이) |
| `reports_screen.dart` | admin 전용 통계 리포트 화면 (fl_chart 4종 차트) |
| `app_router.dart` | `/reports` 경로 추가 |
| `app_strings.dart` | `navReports`, `reportsTitle` 상수 추가 |
| `sidebar_widget.dart` | admin 전용 통계 리포트 메뉴 추가 |
| `main_layout.dart` | NavigationRail + BottomNavBar에 리포트 탭 추가 |
| `top_bar_widget.dart` | `/reports` 경로 제목 매핑 추가 |
| `ticket_list_screen.dart` | pull-to-refresh (RefreshIndicator) 추가 |

#### 기능 상세
- **통계 리포트 (admin 전용)**:
  - 요약 카드 4개: 전체 티켓 / 해결률 / 긴급 티켓 / 미처리
  - 상태별 막대 차트 (신규/처리중/해결완료/종료)
  - 일별 접수 꺾은선 차트 (최근 14일, 도트 + 영역 그라데이션)
  - 카테고리별 막대 차트 (하드웨어/소프트웨어/네트워크/기타)
  - 우선순위별 막대 차트 (긴급/높음/보통/낮음)
  - 반응형: 태블릿 이상 카테고리+우선순위 2열 배치
- **pull-to-refresh**: 티켓 목록 아래로 당기면 Provider invalidate 후 재구독
- **반응형 점검**: 리포트 요약 카드 LayoutBuilder로 4열/2열 자동 전환

#### 커밋
- `feat: 통계 리포트 화면 + pull-to-refresh + 반응형 레이아웃 개선`

### flutter analyze
- 0 issues

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
