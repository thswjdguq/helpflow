/// 앱 전체에서 사용하는 문자열 상수 정의
/// 다국어 지원 확장 시 이 파일을 기준으로 arb 파일로 마이그레이션 예정
class AppStrings {
  AppStrings._(); // 인스턴스화 방지

  // ── 앱 기본 정보 ──────────────────────────────────
  static const String appName = 'HelpFlow';
  static const String appTagline = '고객 지원 티켓 관리 시스템';

  // ── 네비게이션 메뉴 ───────────────────────────────
  static const String navDashboard = '대시보드';
  static const String navTickets = '티켓 관리';
  static const String navSettings = '설정';

  // ── 대시보드 화면 ─────────────────────────────────
  static const String dashboardTitle = '대시보드';
  static const String dashboardTotalTickets = '전체 티켓';
  static const String dashboardPendingTickets = '대기 중';
  static const String dashboardInProgressTickets = '진행 중';
  static const String dashboardResolvedTickets = '해결됨';
  static const String dashboardRecentTickets = '최근 티켓';
  static const String dashboardChartPlaceholder = '7~8주차 fl_chart 연동 예정';

  // ── 티켓 관련 ─────────────────────────────────────
  static const String ticketListTitle = '티켓 목록';
  static const String ticketDetailTitle = '티켓 상세';
  static const String ticketNewTitle = '새 티켓 생성';
  static const String ticketEditTitle = '티켓 수정';

  static const String ticketFieldTitle = '제목';
  static const String ticketFieldDescription = '설명';
  static const String ticketFieldPriority = '우선순위';
  static const String ticketFieldStatus = '상태';
  static const String ticketFieldAssignee = '담당자';
  static const String ticketFieldCreatedAt = '생성일';
  static const String ticketFieldUpdatedAt = '수정일';

  // ── 티켓 우선순위 ─────────────────────────────────
  static const String priorityUrgent = '긴급';
  static const String priorityHigh = '높음';
  static const String priorityMedium = '중간';
  static const String priorityLow = '낮음';

  // ── 티켓 상태 ─────────────────────────────────────
  static const String statusPending = '대기 중';
  static const String statusInProgress = '진행 중';
  static const String statusResolved = '해결됨';
  static const String statusClosed = '마감됨';

  // ── 설정 화면 ─────────────────────────────────────
  static const String settingsTitle = '설정';
  static const String settingsDarkMode = '다크 모드';
  static const String settingsLanguage = '언어';
  static const String settingsNotification = '알림 설정';

  // ── 버튼 레이블 ───────────────────────────────────
  static const String btnNewTicket = '새 티켓';
  static const String btnSave = '저장';
  static const String btnCancel = '취소';
  static const String btnDelete = '삭제';
  static const String btnEdit = '수정';
  static const String btnClose = '닫기';
  static const String btnConfirm = '확인';

  // ── 빈 상태 메시지 ────────────────────────────────
  static const String emptyTickets = '티켓이 없습니다';
  static const String emptyTicketsSubtitle = '새 티켓을 생성해보세요';

  // ── 오류 메시지 ───────────────────────────────────
  static const String errorGeneral = '오류가 발생했습니다. 다시 시도해주세요.';
  static const String errorNotFound = '데이터를 찾을 수 없습니다.';

  // ── 유효성 검사 메시지 ────────────────────────────
  static const String validationRequired = '필수 항목입니다';
  static const String validationTitleTooShort = '제목은 2자 이상 입력해주세요';
  static const String validationTitleTooLong = '제목은 100자 이하로 입력해주세요';
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_strings.dart
// 역할: 앱 전역 텍스트 상수 모음. 네비게이션 레이블, 화면 제목, 버튼 텍스트,
//       오류/유효성 메시지 등을 한 곳에서 관리.
// 사용: AppStrings.navDashboard 형식으로 참조.
