/// 앱 전체에서 사용하는 크기 및 레이아웃 상수 정의
/// 반응형 브레이크포인트, 사이드바 너비, 간격 등을 포함
class AppSizes {
  AppSizes._(); // 인스턴스화 방지

  // ── 반응형 브레이크포인트 ──────────────────────────
  /// 데스크탑 기준 너비 (1024px 이상 → 사이드바 항상 표시)
  static const double breakpointDesktop = 1024.0;

  /// 태블릿 기준 너비 (600px 이상 → 미니 레일 표시)
  static const double breakpointTablet = 600.0;

  // ── 사이드바 / 네비게이션 크기 ────────────────────
  /// 데스크탑 사이드바 전체 너비
  static const double sidebarWidth = 240.0;

  /// 태블릿 아이콘 전용 미니 레일 너비
  static const double railWidth = 64.0;

  // ── 상단 바 높이 ──────────────────────────────────
  static const double topBarHeight = 64.0;

  // ── 카드 / 컨텐츠 ────────────────────────────────
  /// 통계 카드 최소 너비
  static const double statCardMinWidth = 180.0;

  /// 통계 카드 높이
  static const double statCardHeight = 100.0;

  /// 카드 border radius
  static const double cardRadius = 12.0;

  /// 버튼 border radius
  static const double buttonRadius = 8.0;

  // ── 패딩 / 여백 ───────────────────────────────────
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  // ── 아이콘 크기 ───────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // ── 페이지 최대 너비 (대형 화면 대응) ─────────────
  static const double pageMaxWidth = 1440.0;
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_sizes.dart
// 역할: 반응형 브레이크포인트(desktop 1024, tablet 600), 사이드바 너비(240),
//       미니 레일 너비(64), 패딩/여백/아이콘 크기 등 레이아웃 상수 관리.
// 사용: AppSizes.breakpointDesktop, AppSizes.sidebarWidth 형식으로 참조.
