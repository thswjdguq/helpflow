import 'package:flutter/material.dart';

/// 공용 로딩 인디케이터 위젯
/// 전체 화면 로딩과 인라인 로딩 두 가지 모드 지원
class LoadingIndicator extends StatelessWidget {
  /// 표시할 로딩 메시지 (선택, 기본값: '로딩 중...')
  final String? message;

  /// 전체 화면을 덮는 오버레이 모드 여부 (기본값: false)
  final bool fullScreen;

  const LoadingIndicator({
    super.key,
    this.message,
    this.fullScreen = false,
  });

  /// 전체 화면 오버레이 모드 생성자
  const LoadingIndicator.fullScreen({super.key, this.message})
      : fullScreen = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 로딩 콘텐츠 (스피너 + 메시지)
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      // 전체 화면 모드: 반투명 배경 + 중앙 배치
      return ColoredBox(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        child: Center(child: content),
      );
    }

    // 인라인 모드: 중앙 배치
    return Center(child: content);
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: loading_indicator.dart
// 역할: 공용 로딩 인디케이터. 기본(인라인) 모드와 fullScreen 오버레이 모드 지원.
//       선택적 메시지 텍스트 표시.
// 사용: LoadingIndicator() / LoadingIndicator.fullScreen(message: '저장 중...')
