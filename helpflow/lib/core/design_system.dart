import 'package:flutter/material.dart';

// ── HelpFlow 디자인 시스템 ───────────────────────────────────────────────────
// 토스(Toss) 스타일 기반의 색상, 텍스트 스타일, 버튼 스타일, 여백 상수를 정의한다.
// 모든 화면과 위젯에서 이 파일의 상수를 참조해 시각적 일관성을 유지한다.

// ── 색상 시스템 ───────────────────────────────────────────────────────────────

/// HelpFlow 앱 전체 색상 상수
/// 토스 스타일: 순백색 배경, 씨드 블루, 절제된 그레이 계열
class HelpFlowColors {
  HelpFlowColors._(); // 인스턴스화 방지

  // ── 브랜드 컬러 ──────────────────────────────────
  /// 메인 브랜드 색상 (씨드 컬러와 동일)
  static const Color primary = Color(0xFF0057FF);

  // ── 배경 / 서피스 ─────────────────────────────────
  /// 앱 배경색: 순백색 (토스 스타일 기준)
  static const Color background = Color(0xFFFFFFFF);

  /// 카드/컨테이너 서피스: 연한 회색빛 흰색
  static const Color surface = Color(0xFFF8F9FA);

  // ── 그레이 계열 (토스 스타일 3단계) ─────────────────
  /// 가장 연한 그레이: 입력 필드 배경, 구분선 등에 사용
  static const Color gray100 = Color(0xFFF2F3F5);

  /// 중간 그레이: 비활성 텍스트, placeholder 등에 사용
  static const Color gray500 = Color(0xFF8B95A1);

  /// 진한 그레이: 보조 텍스트, 아이콘 등에 사용
  static const Color gray700 = Color(0xFF4E5968);

  // ── 에러 컬러 ─────────────────────────────────────
  /// 오류/경고 상태 색상 (토스 스타일 레드)
  static const Color error = Color(0xFFFF4D4F);
}

// ── 텍스트 스타일 시스템 ──────────────────────────────────────────────────────

/// HelpFlow 텍스트 스타일 상수
/// 시스템 폰트(sans-serif) 기반, 토스 스타일 가독성 기준
class HelpFlowTextStyles {
  HelpFlowTextStyles._(); // 인스턴스화 방지

  // ── Headline: 페이지/섹션 제목 ────────────────────

  /// 최상위 페이지 제목 (28px, Bold)
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  /// 섹션 주요 제목 (22px, Bold)
  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// 카드/다이얼로그 제목 (18px, SemiBold)
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // ── Body: 본문 텍스트 ──────────────────────────────

  /// 기본 본문 텍스트 (16px, Regular)
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// 보조 본문 텍스트 (14px, Regular)
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // ── Caption: 부가 정보 ─────────────────────────────

  /// 캡션/메타 텍스트 (12px, Regular, 회색 고정)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: HelpFlowColors.gray500,
  );

  // ── Button: 버튼 레이블 ────────────────────────────

  /// 버튼 레이블 텍스트 (15px, SemiBold)
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.0,
  );
}

// ── 버튼 스타일 시스템 ────────────────────────────────────────────────────────

/// HelpFlow 버튼 스타일 상수
/// 공통 radius 12, 넉넉한 패딩 적용
class HelpFlowButtonStyles {
  HelpFlowButtonStyles._(); // 인스턴스화 방지

  /// FilledButton 스타일 (주요 액션)
  static ButtonStyle get filled => FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: HelpFlowTextStyles.button,
      );

  /// OutlinedButton 스타일 (보조 액션)
  static ButtonStyle get outlined => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: HelpFlowTextStyles.button,
      );

  /// TextButton 스타일 (텍스트 액션)
  static ButtonStyle get text => TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: HelpFlowTextStyles.button,
      );
}

// ── 여백 상수 시스템 ──────────────────────────────────────────────────────────

/// HelpFlow 여백/간격 상수
/// 4px 배수 기반, 7단계 정의
class HelpFlowSpacing {
  HelpFlowSpacing._(); // 인스턴스화 방지

  /// 4px — 아이콘·텍스트 간 최소 간격
  static const double xs = 4;

  /// 8px — 요소 내부 소간격
  static const double sm = 8;

  /// 12px — 요소 간 기본 소간격
  static const double md = 12;

  /// 16px — 컴포넌트 간 기본 간격
  static const double lg = 16;

  /// 20px — 섹션 간 중간 간격
  static const double xl = 20;

  /// 24px — 섹션 간 넉넉한 간격
  static const double xxl = 24;

  /// 32px — 페이지/섹션 최상위 여백
  static const double xxxl = 32;
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: design_system.dart
// 역할: HelpFlow 앱 전체 디자인 시스템 정의.
//       HelpFlowColors: 브랜드/배경/서피스/그레이/에러 색상 상수.
//       HelpFlowTextStyles: headline1~3, body1~2, caption, button 텍스트 스타일.
//       HelpFlowButtonStyles: FilledButton/OutlinedButton/TextButton 공통 스타일 (radius 12).
//       HelpFlowSpacing: 4~32px 7단계 여백 상수.
// 사용: 모든 화면·위젯에서 HelpFlowColors.primary, HelpFlowSpacing.lg 형식으로 참조.
