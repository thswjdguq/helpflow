import '../constants/app_strings.dart';

/// 폼 입력 유효성 검사 함수 모음
/// Flutter Form 위젯의 validator 파라미터에 직접 전달 가능한 형태로 설계
class Validators {
  Validators._(); // 인스턴스화 방지

  // ── 공통 유효성 검사 ──────────────────────────────

  /// 필수 항목 검사 (null 또는 빈 문자열이면 오류 반환)
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    return null;
  }

  // ── 티켓 관련 유효성 검사 ─────────────────────────

  /// 티켓 제목 유효성 검사 (2자 이상 100자 이하)
  static String? ticketTitle(String? value) {
    final requiredResult = required(value);
    if (requiredResult != null) return requiredResult;

    final trimmed = value!.trim();
    if (trimmed.length < 2) {
      return AppStrings.validationTitleTooShort;
    }
    if (trimmed.length > 100) {
      return AppStrings.validationTitleTooLong;
    }
    return null;
  }

  /// 티켓 설명 유효성 검사 (선택 항목, 입력 시 최대 2000자)
  static String? ticketDescription(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 2000) {
      return '설명은 2000자 이하로 입력해주세요';
    }
    return null;
  }

  // ── 범용 유효성 검사 ──────────────────────────────

  /// 최소 길이 검사
  static String? Function(String?) minLength(int min, String fieldName) {
    return (String? value) {
      if (value == null || value.trim().length < min) {
        return '$fieldName은(는) $min자 이상 입력해주세요';
      }
      return null;
    };
  }

  /// 최대 길이 검사
  static String? Function(String?) maxLength(int max, String fieldName) {
    return (String? value) {
      if (value != null && value.trim().length > max) {
        return '$fieldName은(는) $max자 이하로 입력해주세요';
      }
      return null;
    };
  }

  /// 복수 검사기를 순서대로 실행하여 첫 번째 오류 반환
  /// 사용 예: Validators.compose([Validators.required, Validators.ticketTitle])
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: validators.dart
// 역할: Flutter Form validator 파라미터에 전달 가능한 유효성 검사 함수 모음.
//       필수 항목, 티켓 제목/설명 검사, 최소/최대 길이 검사, 검사기 조합(compose) 제공.
// 사용: TextFormField(validator: Validators.ticketTitle) 형식으로 참조.
