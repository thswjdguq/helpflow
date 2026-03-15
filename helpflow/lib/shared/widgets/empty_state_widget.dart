import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';

/// 빈 상태 표시 위젯
/// 데이터가 없거나 검색 결과가 없을 때 사용
class EmptyStateWidget extends StatelessWidget {
  /// 표시할 아이콘
  final IconData icon;

  /// 메인 메시지 (굵은 텍스트)
  final String message;

  /// 부제목 메시지 (선택, 작은 텍스트)
  final String? subtitle;

  /// 액션 버튼 위젯 (선택, 예: '새 티켓 만들기' 버튼)
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
    this.action,
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
            // 아이콘 (큰 크기, 흐릿한 색상)
            Icon(
              icon,
              size: 72,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingMd),

            // 메인 메시지
            Text(
              message,
              style: AppTextStyles.sectionTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // 부제목 (선택)
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.paddingXs),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼 (선택)
            if (action != null) ...[
              const SizedBox(height: AppSizes.paddingLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: empty_state_widget.dart
// 역할: 빈 상태 UI 위젯. 아이콘, 메인 메시지, 선택적 부제목, 선택적 액션 버튼 표시.
//       티켓 목록이 비어있거나 검색 결과 없음 등의 상태에 사용.
// 사용: EmptyStateWidget(icon: Icons.inbox, message: '티켓이 없습니다', subtitle: '새 티켓을 생성하세요')
