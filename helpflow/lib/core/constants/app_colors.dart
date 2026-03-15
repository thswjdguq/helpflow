import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 상수 정의
/// Material 3 시드 컬러 기반으로 구성
class AppColors {
  AppColors._(); // 인스턴스화 방지

  // ── 브랜드 컬러 ──────────────────────────────────
  /// 메인 시드 컬러 (파란 계열)
  static const Color primary = Color(0xFF0057FF);

  /// 성공 상태 색상
  static const Color success = Color(0xFF2E7D32);

  /// 경고 상태 색상
  static const Color warning = Color(0xFFF57F17);

  /// 오류 상태 색상
  static const Color error = Color(0xFFC62828);

  /// 정보 상태 색상
  static const Color info = Color(0xFF0277BD);

  // ── 티켓 우선순위 색상 ────────────────────────────
  /// 긴급 우선순위
  static const Color priorityUrgent = Color(0xFFB71C1C);

  /// 높음 우선순위
  static const Color priorityHigh = Color(0xFFE53935);

  /// 중간 우선순위
  static const Color priorityMedium = Color(0xFFFB8C00);

  /// 낮음 우선순위
  static const Color priorityLow = Color(0xFF43A047);

  // ── 티켓 상태 색상 ────────────────────────────────
  /// 대기 중 상태
  static const Color statusPending = Color(0xFF757575);

  /// 진행 중 상태
  static const Color statusInProgress = Color(0xFF1E88E5);

  /// 해결됨 상태
  static const Color statusResolved = Color(0xFF43A047);

  /// 마감됨 상태
  static const Color statusClosed = Color(0xFF9E9E9E);

  // ── 중립 색상 ─────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_colors.dart
// 역할: 앱 전역 색상 팔레트 정의. 브랜드 컬러, 티켓 우선순위/상태별 색상,
//       중립 색상(grey scale)을 상수로 관리.
// 사용: 모든 위젯에서 AppColors.primary 형식으로 참조.
