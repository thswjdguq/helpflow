import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/design_system.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';

/// 설정 화면
/// 현재 로그인 사용자 정보(이름/이메일/역할) 표시 및 로그아웃 기능 제공
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 현재 로그인 사용자 정보 구독
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 페이지 제목 ──────────────────────────────────────────────
              Text(
                '설정',
                style: HelpFlowTextStyles.headline2.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: HelpFlowSpacing.xxl),

              // ── 사용자 정보 카드 ─────────────────────────────────────────
              currentUser.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  return _UserInfoCard(user: user);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const Spacer(),

              // ── 로그아웃 버튼 ────────────────────────────────────────────
              // 클릭 시 signOut() → authStateProvider가 null 방출 →
              // GoRouter redirect가 자동으로 /login으로 이동
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(currentUserProvider.notifier).signOut();
                    } catch (_) {
                      // 로그아웃 실패는 드문 경우 — 무시
                    }
                  },
                  icon: const Icon(Icons.logout, color: HelpFlowColors.error),
                  label: const Text(
                    '로그아웃',
                    style: TextStyle(color: HelpFlowColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: HelpFlowColors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: HelpFlowSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HelpFlowSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 사용자 정보 카드 ──────────────────────────────────────────────────────────

/// 현재 로그인 사용자의 아바타·이름·이메일·역할을 카드 형태로 표시
class _UserInfoCard extends StatelessWidget {
  /// 표시할 사용자 모델
  final UserModel user;

  const _UserInfoCard({required this.user});

  /// 역할 코드 → 한글 레이블 변환
  String _roleLabel(String role) {
    switch (role) {
      case UserRole.admin:
        return '관리자';
      case UserRole.agent:
        return '현장 담당자';
      default:
        return '직원';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(HelpFlowSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? HelpFlowColors.darkBorder
              : HelpFlowColors.border,
        ),
      ),
      child: Row(
        children: [
          // 아바타: 이름 첫 글자 원형 표시
          CircleAvatar(
            radius: 24,
            backgroundColor: HelpFlowColors.primary,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: HelpFlowTextStyles.headline3.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: HelpFlowSpacing.lg),

          // 이름 / 이메일 / 역할 배지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름
                Text(
                  user.name,
                  style: HelpFlowTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: HelpFlowSpacing.xs),

                // 이메일
                Text(
                  user.email,
                  style: HelpFlowTextStyles.body2.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: HelpFlowSpacing.sm),

                // 역할 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HelpFlowSpacing.sm,
                    vertical: HelpFlowSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: HelpFlowColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: HelpFlowTextStyles.caption.copyWith(
                      color: HelpFlowColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: settings_screen.dart
// 역할: 설정 화면. 현재 로그인 사용자 정보(이름/이메일/역할) 표시 및 로그아웃.
//       currentUserProvider를 watch해 사용자 정보 카드 표시.
//       로그아웃 버튼 클릭 → signOut() → authStateProvider null 방출 →
//       GoRouter redirect 자동 /login 이동.
//       _UserInfoCard: 아바타(이름 첫 글자), 이름, 이메일, 역할 배지 표시.
// 연관 파일: auth_provider.dart, app_router.dart, user_model.dart
// ─────────────────────────────────────────────────────────────────────────────
