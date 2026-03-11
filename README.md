# HelpFlow 🛠️
> Flutter 크로스플랫폼 기반 경량 헬프데스크 플랫폼

웹(직원·관리자)과 모바일 앱(현장 담당자)을 **단일 Flutter 코드베이스**로 구현한 헬프데스크 서비스입니다.

---

## 📌 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 프로젝트명 | HelpFlow |
| 개발 기간 | 15주 |
| 팀 구성 | 2인 (바이브코딩) |
| 타겟 직군 | IT기업 헬프데스크 / ITSM 직군 |
| 기술 스택 | Flutter 3.x · Firebase · Riverpod |

---

## 💡 기획 배경

중소 IT 조직의 헬프데스크 업무는 여전히 이메일·메신저·전화로 운영되는 경우가 많습니다.
이로 인해 **신고 누락, 현장 소통 단절, 처리 이력 소실** 문제가 반복됩니다.

HelpFlow는 Flutter의 크로스플랫폼 특성을 활용해 이 문제를 해결합니다.

- 직원 → 웹 브라우저에서 앱 설치 없이 티켓 접수
- 현장 담당자 → 모바일 앱으로 실시간 알림 수신 + QR 스캔
- 관리자 → 웹 대시보드에서 전체 현황 실시간 모니터링

---

## 👥 사용자 역할

| 역할 | 플랫폼 | 주요 기능 |
|------|--------|-----------|
| USER (직원) | 웹 브라우저 | 티켓 접수 / 내 티켓 현황 조회 |
| AGENT (현장 담당자) | 모바일 앱 | 알림 수신 / QR 스캔 / 티켓 처리 |
| ADMIN (관리자) | 웹 브라우저 | 담당자 배정 / 대시보드 / 자산 관리 |

---

## ✅ 핵심 기능

### P0 — 없으면 안 되는 기능
- 이메일 로그인 / 회원가입 (Firebase Auth)
- 티켓 접수 — 제목·내용·사진 첨부 (웹)
- 내 티켓 목록 조회 (웹·앱)
- 티켓 상태 변경 NEW → IN_PROGRESS → RESOLVED (앱)
- 담당자 배정 (웹, ADMIN)

### P1 — 차별화 기능
- 푸시 알림 수신 (FCM, 앱)
- QR 코드 스캔 → 자산 즉시 확인 (앱)
- 자산 등록 및 QR 코드 생성 (웹, ADMIN)
- 고장 이력 타임라인 (앱·웹)
- 실시간 관리자 대시보드 (웹)

### P2 — 완성도 기능
- 오프라인 캐시 및 동기화 (Hive)
- 댓글 / 코멘트 기능
- 처리 완료 통계 차트

---

## 🗂️ 티켓 상태 흐름

```
NEW → IN_PROGRESS → RESOLVED → CLOSED
```

- **NEW** : 직원 접수 직후. ADMIN이 AGENT 배정
- **IN_PROGRESS** : AGENT가 처리 시작
- **RESOLVED** : AGENT가 처리 완료 입력 (처리 내용 필수)
- **CLOSED** : 최종 종료. 재변경 불가

---

## 🛠️ 기술 스택

| 영역 | 기술 | 이유 |
|------|------|------|
| 프론트엔드 | Flutter 3.x + Dart | 웹/앱 단일 코드베이스 |
| 상태관리 | Riverpod 2.x | 바이브코딩 AI 패턴 일관성 |
| 인증 | Firebase Authentication | 별도 백엔드 없이 즉시 구현 |
| DB | Cloud Firestore | 실시간 스트림 지원 |
| 파일 저장 | Firebase Storage | 첨부 이미지 업로드 |
| 푸시 알림 | Firebase Cloud Messaging | Flutter FCM 간편 연동 |
| 로컬 캐시 | Hive | 오프라인 대응 |
| QR 스캔 | mobile_scanner | Flutter 공식 권장 패키지 |

---

## 📁 폴더 구조

```
lib/
├── features/
│   ├── auth/          # 로그인·회원가입 (A 담당)
│   ├── tickets/       # 티켓 접수·목록·상세 (공통)
│   ├── assets/        # 자산 관리·QR (A: 웹 / B: 앱)
│   ├── dashboard/     # 관리자 대시보드 (A 담당)
│   └── notifications/ # 알림 목록 (B 담당)
├── shared/
│   ├── widgets/       # 공통 버튼·카드·AppBar
│   ├── models/        # 데이터 모델 (Ticket, Asset, User)
│   └── services/      # Firebase 연결 (공통)
└── main.dart
```

---

## 🗓️ 15주 개발 로드맵

| Phase | 주차 | 내용 |
|-------|------|------|
| Phase 1 | 1~2주 | 환경 세팅, Firebase 연결, 데이터 구조 설계 |
| Phase 2 | 3~5주 | 인증, 티켓 접수·목록·상세, 상태 변경 |
| Phase 3 | 6~9주 | 담당자 배정, FCM 알림, QR 스캔, 대시보드 |
| Phase 4 | 10~12주 | P2 기능, UI polish, 예외 처리 |
| Phase 5 | 13~15주 | 보안 점검, 포트폴리오 정리, 발표 준비 |

---

## 🌿 GitHub 협업 규칙

### 브랜치 전략
```
main       ← 최종 배포본. 직접 push 금지
develop    ← 통합 브랜치. 주 1회 main 반영
feat/A-xxx ← A 담당 기능 브랜치
feat/B-xxx ← B 담당 기능 브랜치
fix/xxx    ← 버그 수정
```

### 커밋 메시지 규칙
```
feat: 기능 추가
fix:  버그 수정
style: UI 변경
docs: 문서 수정
refactor: 리팩토링
```

### 주 3회 커밋 루틴
- 월요일 — UI 레이아웃 커밋
- 수요일 — Firebase 연동·로직 커밋
- 금요일 — 버그 수정·문서 업데이트 커밋

---

## 🗃️ Firestore 주요 컬렉션

```
users/{userId}
  ├─ name, email, role, fcmToken

tickets/{ticketId}
  ├─ title, description, category
  ├─ status, priority
  ├─ reporterId, agentId, assetId
  ├─ imageUrls, resolution
  └─ comments/{commentId}

assets/{assetId}
  ├─ name, type, location
  ├─ serialNumber, qrCodeUrl
```

---

## 👨‍💻 팀 분업

| 담당 | 영역 |
|------|------|
| A | 웹 화면 (티켓 접수·관리, 대시보드, 자산 관리) |
| B | 모바일 앱 화면 (티켓 처리, QR 스캔, FCM 알림) |
