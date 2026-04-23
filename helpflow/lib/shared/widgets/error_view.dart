import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

/// 공통 에러 표시 위젯
///
/// 데이터 로드 실패, 네트워크 오류 등 에러 상태에서 사용합니다.
/// [message]로 에러 설명을 표시하고, [onRetry]가 있으면 재시도 버튼을 표시합니다.
class ErrorView extends StatelessWidget {
  /// 사용자에게 표시할 에러 메시지
  final String message;

  /// 재시도 콜백 (null이면 버튼 미표시)
  final VoidCallback? onRetry;

  /// 표시할 아이콘 (기본: error_outline)
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            Text(
              '오류가 발생했습니다',
              style: AppTextStyles.sectionTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingLg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: error_view.dart
// 역할: 공통 에러 상태 표시 위젯.
//       message: 에러 설명 텍스트.
//       onRetry: 재시도 콜백 (null이면 버튼 미표시).
//       icon: 커스텀 아이콘 (기본 error_outline).
// 사용: ticketListStream.when(error: (e,_) => ErrorView(message: e.toString()))
// ─────────────────────────────────────────────────────────────────────────────
