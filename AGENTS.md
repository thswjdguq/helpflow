# AGENTS.md — HelpFlow AI Agent 사용 가이드

이 프로젝트는 **Claude Code (Claude Sonnet 4.6)** 를 주 AI Agent로 사용해 전 과정을 개발했습니다.
이 파일은 프로젝트에서 AI Agent를 어떻게 활용했는지, 어떤 패턴이 효과적이었는지를 기록합니다.

---

## 사용 도구

| 도구 | 용도 |
|------|------|
| Claude Code (CLI) | 코드 생성, 리팩토링, 디버깅, 문서 작성 |
| CLAUDE.md | 프로젝트 컨텍스트 주입 (매 세션 자동 로드) |
| todo.md | 작업 우선순위 및 진행 상태 관리 |
| daily_report.md | 세션별 작업 기록 |

---

## 컨텍스트 주입 전략

### CLAUDE.md 구조
Claude Code는 세션 시작 시 `CLAUDE.md`를 자동으로 읽습니다.
이 파일에 다음 정보를 담아 매번 컨텍스트를 다시 설명하지 않도록 했습니다.

```
CLAUDE.md
├── 프로젝트 한 줄 요약
├── 기술 스택 (버전 포함)
├── 사용자 역할 & 권한 정의
├── 핵심 데이터 흐름
├── 티켓 상태 흐름
├── Firestore 컬렉션 구조
├── 폴더 구조 (파일 경로 포함)
├── 반응형 레이아웃 분기 기준
└── 코딩 규칙 (항상 준수)
```

**효과**: 새 대화를 시작해도 "Riverpod NotifierProvider 패턴 고정", "한글 주석 필수" 같은 규칙이 자동 적용됨.

---

## 작업 지시 패턴

### 효과적이었던 프롬프트 패턴

**1. 기능 단위 분할 요청**
```
나쁜 예: "티켓 기능 만들어줘"
좋은 예: "TicketModel → TicketService → TicketProvider → UI 순서로
          각각 완성 후 flutter analyze 확인하면서 구현해줘"
```

**2. 파일 역할 명시**
```
"helpflow/lib/shared/services/ticket_service.dart에
 Firestore CRUD 메서드 4개 추가해줘.
 기존 패턴은 auth_service.dart와 동일하게"
```

**3. 오류 수정 요청**
```
"flutter analyze 결과를 붙여넣고:
 이 오류들 순서대로 수정해줘. 각 수정 후 이유 설명해줘"
```

**4. 단계별 TODO 연동**
```
"todo.md의 Phase 5 항목 순서대로 진행해줘.
 각 항목 완료 시 체크박스 업데이트하고
 기능 하나 완성될 때마다 커밋해줘"
```

---

## 세션 운영 방식

### 세션 시작 시
1. Claude Code가 `CLAUDE.md` 자동 로드
2. `todo.md` 확인 → 미완료 항목 파악
3. `git status` 확인 → 현재 브랜치와 변경 사항 파악

### 세션 중
- 기능 1개 완성 → `flutter analyze` → 오류 0개 확인 → 커밋
- 커밋 메시지 규칙: `feat/fix/docs/refactor/chore: 설명`

### 세션 종료 시
- `daily_report.md` 맨 위에 오늘 작업 추가
- `todo.md` 완료 항목 체크
- `git push origin {브랜치명}`

---

## 브랜치 전략 (AI Agent 연동)

```
main ← 주 1회 병합 (세션 마무리 시)
  └── week-0N  ← 주차별 작업 브랜치
  └── feat/xxx ← 기능 단위 브랜치
```

AI Agent에게 브랜치 생성/병합/푸시를 지시할 때는 항상 명시적으로:
```
"week-05 브랜치에서 작업하고,
 완료 후 main에 병합해서 GitHub에 푸시해줘"
```

---

## 실패 사례 & 교훈

| 상황 | 문제 | 해결 |
|------|------|------|
| 컨텍스트 없이 요청 | 기존 패턴 무시하고 다른 방식으로 구현 | CLAUDE.md에 패턴 명시 |
| 한 번에 너무 많은 기능 요청 | 중간에 오류 발생 시 어디서 났는지 파악 어려움 | 기능 1개씩 분할 요청 |
| 오류 메시지 없이 "안 된다"고 요청 | AI가 문제를 특정 못함 | 정확한 오류 로그 붙여넣기 |
| 파일 경로 명시 안 함 | 엉뚱한 파일에 코드 추가 | 항상 절대/상대 경로 명시 |

---

## 가산점 항목 대응

이 프로젝트는 다음 방식으로 AI Agent를 활용했습니다.

- **CLAUDE.md**: 단일 파일로 agent 컨텍스트 + 코딩 규칙 + 아키텍처를 통합 관리
- **todo.md**: AI Agent가 작업 순서를 자율 결정하는 백로그 역할
- **커밋 자동화**: 기능 완성마다 AI가 `git add → commit → push` 수행
- **문서 자동 생성**: README, architecture.md, ADR 등 모두 AI Agent로 생성

> 핵심 원칙: AI가 생성한 코드라도 **본인이 모든 구조와 이유를 설명할 수 있어야** 한다.
