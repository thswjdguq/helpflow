/// 날짜/시간 관련 유틸리티 함수 모음
/// Flutter 내장 DateUtils와 충돌을 피하기 위해 클래스명을 AppDateUtils로 명명
class AppDateUtils {
  AppDateUtils._(); // 인스턴스화 방지

  // ── 날짜 포맷 ─────────────────────────────────────

  /// DateTime을 'YYYY-MM-DD' 형식 문자열로 변환
  /// 예: 2026-03-15
  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// DateTime을 'YYYY-MM-DD HH:mm' 형식 문자열로 변환
  /// 예: 2026-03-15 09:30
  static String formatDateTime(DateTime date) {
    final dateStr = formatDate(date);
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$dateStr $h:$min';
  }

  /// DateTime을 한국어 상대 시간 문자열로 변환
  /// 예: '방금 전', '5분 전', '2시간 전', '3일 전', '2026-03-01'
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return formatDate(date);
    }
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// ISO 8601 문자열을 DateTime으로 파싱 (null-safe)
  /// 파싱 실패 시 null 반환
  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: date_utils.dart
// 역할: 날짜 포맷(YYYY-MM-DD, YYYY-MM-DD HH:mm), 상대 시간('방금 전', 'N분 전'),
//       오늘 여부 확인, ISO 문자열 파싱 등 날짜 관련 유틸리티 제공.
// 사용: AppDateUtils.formatDate(date) 형식으로 참조.
