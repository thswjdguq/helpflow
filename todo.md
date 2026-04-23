# HelpFlow — 개발 우선순위 & TODO

## 현재 Phase: Phase 4~6 (4주차 진행 중)

---

## Phase 1 — 기반 구축 (1~3주차)

### ✅ 완료
- [x] Flutter 프로젝트 생성
- [x] 폴더 구조 (features/shared/core) 생성
- [x] pubspec.yaml 패키지 추가
- [x] Material3 테마 + 디자인 시스템 정의
- [x] go_router ShellRoute 라우팅 설정
- [x] 반응형 사이드바 레이아웃 뼈대
- [x] Firebase 프로젝트 연결 (flutterfire configure)
- [x] .gitignore 보안 설정
- [x] Firebase Authentication 이메일/비밀번호 활성화
- [x] 회원가입 / 로그인 동작 확인
- [x] 로그인 후 메인화면 진입 확인

### 🔴 P0 — 진행 중 (이번 주)
- [x] 비로그인 시 대시보드 접근 차단 (로그인 필수 라우팅)
- [x] 다크모드 색상 불일치 수정
- [x] TicketModel 설계 (Firestore 연동)
- [x] TicketService CRUD 구현
- [x] TicketProvider Riverpod 상태 관리

### 🔴 P0 — 3주차
- [x] Firestore 보안 규칙 설정
- [x] 역할별 화면 분기 (user/agent/admin)
- [x] 로그아웃 시 자동으로 로그인 화면 이동
- [x] 전체 인증 흐름 안정화

---

## Phase 2 — 핵심 기능 (4~6주차)

### 🔴 P0 — 티켓 기능
- [x] 티켓 접수 화면 (제목/내용/카테고리/우선순위/사진 첨부)
- [x] 티켓 목록 화면 (전체 / 내 티켓 필터)
- [x] 티켓 상세 화면 (타임라인, 댓글)
- [x] 티켓 상태 변경 (new → in_progress → resolved → closed)
- [x] 담당자(agent) 배정 기능 (admin 전용)
- [x] Firebase Storage 이미지 업로드 연동

### 🔴 P0 — Firestore 보안 규칙
- [x] 로그인한 유저만 읽기/쓰기 가능
- [x] 본인 티켓만 수정 가능
- [x] admin은 전체 접근 가능

---

## Phase 3 — 관리자 기능 (7~8주차)

### 🔴 P0 — 대시보드
- [x] 통계 데이터 Firestore에서 실시간 집계
- [x] fl_chart 연동 (티켓 현황 차트)
- [x] 카드 위젯 실데이터 연동 (전체/처리중/해결됨/긴급)
- [x] 최근 티켓 목록 실데이터 연동

### 🟡 P1 — 관리자 전용
- [x] 사용자 관리 화면 (admin 전용)
- [x] 담당자 배정 고도화
- [x] 티켓 통계 리포트

---

## Phase 4 — 모바일 최적화 (9주차)

### 🟡 P1
- [x] 하단 내비게이션 바 (600px 미만)
- [x] 모바일 전용 UI 최적화
- [x] 반응형 레이아웃 전체 점검

---

## Phase 5 — 부가 기능 (10주차, 택1)

### 🟡 P1 — 인앱 알림 (Firestore 실시간)
- [ ] NotificationModel + NotificationService 구현
- [ ] notificationProvider (미읽음 카운트 + 목록 스트림)
- [ ] 알림 화면 (NotificationsScreen)
- [ ] 상단 바 알림 벨 아이콘 + 뱃지
- [ ] 티켓 배정/해결/댓글 시 알림 자동 생성

### 🟢 P2 — 향후 (선택)
- [ ] FCM 실제 푸시 (Cloud Functions 필요)
- [ ] QR 스캔 (mobile_scanner 패키지 추가 필요)

---

## Phase 6 — 완성도 (11~12주차)

### 🟡 P1
- [ ] 토스 스타일 UI 완성도 끌어올리기
- [ ] 화면 전환 페이지 애니메이션 (Fade + Slide)
- [ ] 에러 화면 처리 (공통 ErrorView 위젯)
- [x] 빈 화면 처리 (EmptyStateWidget)
- [x] 검색 / 필터 기능
- [ ] 오프라인 대응 (Hive 로컬 캐시)

---

## Phase 7 — 안정화 (13주차)

### 🔴 P0
- [ ] flutter analyze 오류 0개
- [ ] 전체 기능 시나리오 테스트
- [ ] 버그 수정
- [ ] 코드 리팩토링 (중복 제거)
- [ ] 주석 및 파일 요약 전체 점검

---

## Phase 8 — 마무리 (14주차)

### 🔴 P0
- [ ] README.md 최종 업데이트
- [ ] 스크린샷 / 데모 영상 촬영
- [ ] 포트폴리오용 설명 작성
- [ ] 발표 자료 준비
- [ ] GitHub 정리 (브랜치 병합, 태그)

---

## 주차별 커밋 루틴

| 요일 | 작업 | 커밋 내용 |
|------|------|---------|
| 화요일 | 모델·서비스 설계 | feat: XXX 모델/서비스 구현 |
| 목요일 | UI 화면 구현 | feat: XXX 화면 UI 구현 |
| 토요일 | 로직 연결 + 문서 | feat: XXX 기능 완성 + daily_report 업데이트 |

---

## 브랜치 전략

```
main      ← 최종본. 주 1회 병합
  └── week-02  ← 현재 작업 브랜치
  └── week-03  ← 완료
  └── week-04  ← 현재 작업 브랜치
```

---

## 우선순위 범례

| 레벨 | 의미 |
|------|------|
| 🔴 P0 | 필수 — 없으면 앱 동작 불가 |
| 🟡 P1 | 핵심 차별화 — 완성도에 필요 |
| 🟢 P2 | 고도화 — 시간 허용 시 추가 |
