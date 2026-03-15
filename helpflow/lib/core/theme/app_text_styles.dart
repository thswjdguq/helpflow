import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 텍스트 스타일 정의
/// Material 3 TextTheme을 기반으로 커스텀 스타일 추가
class AppTextStyles {
  AppTextStyles._(); // 인스턴스화 방지

  // ── 페이지 제목 ───────────────────────────────────
  /// 화면 제목 (AppBar, 페이지 헤더)
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 섹션 제목
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  // ── 카드 / 리스트 아이템 ──────────────────────────
  /// 카드 제목
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
  );

  /// 카드 부제목 / 설명
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
  );

  // ── 통계 카드 ─────────────────────────────────────
  /// 통계 숫자 (큰 숫자 표시)
  static const TextStyle statNumber = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
  );

  /// 통계 레이블
  static const TextStyle statLabel = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // ── 네비게이션 ────────────────────────────────────
  /// 사이드바 메뉴 항목
  static const TextStyle navItem = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // ── 배지 / 태그 ───────────────────────────────────
  /// 상태 배지 텍스트
  static const TextStyle badge = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // ── 본문 ──────────────────────────────────────────
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_text_styles.dart
// 역할: 페이지 제목, 카드 제목, 통계 숫자, 네비게이션 항목, 배지 등
//       앱 전역 텍스트 스타일을 정적 상수로 정의.
// 사용: AppTextStyles.pageTitle 형식으로 참조.
