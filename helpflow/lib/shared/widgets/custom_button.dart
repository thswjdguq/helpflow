import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';

/// 앱 공용 버튼 위젯
/// FilledButton, OutlinedButton, TextButton 변형 지원
/// 로딩 상태, 아이콘, 비활성화 처리 포함
class CustomButton extends StatelessWidget {
  /// 버튼 레이블 텍스트
  final String label;

  /// 버튼 클릭 콜백 (null이면 비활성화)
  final VoidCallback? onPressed;

  /// 버튼 변형 스타일
  final CustomButtonVariant variant;

  /// 버튼 앞에 표시할 아이콘 (선택)
  final IconData? icon;

  /// 로딩 상태 표시 여부
  final bool isLoading;

  /// 버튼 최소 너비 (선택, 기본값: null)
  final double? minWidth;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CustomButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.minWidth,
  });

  /// 로딩 중이거나 onPressed가 null이면 버튼 비활성화
  VoidCallback? get _effectiveOnPressed => isLoading ? null : onPressed;

  /// 버튼 내부 자식 위젯 (로딩 스피너 또는 레이블)
  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      // 로딩 중일 때 스피너 표시
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == CustomButtonVariant.filled
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.paddingXs),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (variant) {
      case CustomButtonVariant.filled:
        // 주요 액션 버튼 (파란 배경)
        button = FilledButton(
          onPressed: _effectiveOnPressed,
          child: _buildChild(context),
        );
      case CustomButtonVariant.outlined:
        // 보조 액션 버튼 (외곽선)
        button = OutlinedButton(
          onPressed: _effectiveOnPressed,
          child: _buildChild(context),
        );
      case CustomButtonVariant.text:
        // 텍스트 버튼 (배경 없음)
        button = TextButton(
          onPressed: _effectiveOnPressed,
          child: _buildChild(context),
        );
    }

    // minWidth가 지정된 경우 ConstrainedBox로 감싸기
    if (minWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth!),
        child: button,
      );
    }

    return button;
  }
}

/// 버튼 변형 종류
enum CustomButtonVariant {
  /// 채워진 버튼 (주요 액션)
  filled,

  /// 외곽선 버튼 (보조 액션)
  outlined,

  /// 텍스트 버튼 (약한 액션)
  text,
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: custom_button.dart
// 역할: 앱 공용 버튼 위젯. filled/outlined/text 변형, 로딩 스피너,
//       아이콘, 비활성화 처리를 하나의 위젯으로 통합.
// 사용: CustomButton(label: '저장', onPressed: _save, variant: CustomButtonVariant.filled)
