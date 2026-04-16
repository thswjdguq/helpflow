import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/design_system.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import '../../providers/theme_provider.dart';

/// 설정 화면
///
/// 계정 정보 카드, 앱 설정(다크모드), 로그아웃 버튼 구성.
/// 실제 헬프데스크의 설정 화면처럼 섹션별로 그룹화.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 페이지 제목 ──────────────────────────────────────────────
              Text(
                '설정',
                style: AppTextStyles.pageTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLg),

              // ── 계정 섹션 ────────────────────────────────────────────────
              _SectionHeader(label: '계정'),
              const SizedBox(height: AppSizes.paddingSm),
              currentUser.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  return _AccountCard(user: user);
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSizes.paddingLg),

              // ── 앱 설정 섹션 ─────────────────────────────────────────────
              _SectionHeader(label: '앱 설정'),
              const SizedBox(height: AppSizes.paddingSm),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: '다크 모드',
                    subtitle: isDark ? '어두운 테마 사용 중' : '밝은 테마 사용 중',
                    value: isDark,
                    onChanged: (_) =>
                        ref.read(themeProvider.notifier).toggle(),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingLg),

              // ── 앱 정보 섹션 ─────────────────────────────────────────────
              _SectionHeader(label: '앱 정보'),
              const SizedBox(height: AppSizes.paddingSm),
              _SettingsCard(
                children: [
                  _InfoTile(
                    icon: Icons.info_outline,
                    title: '앱 이름',
                    trailing: 'HelpFlow',
                  ),
                  const Divider(height: 1, indent: 52),
                  _InfoTile(
                    icon: Icons.build_outlined,
                    title: '버전',
                    trailing: '1.0.0',
                  ),
                  const Divider(height: 1, indent: 52),
                  _InfoTile(
                    icon: Icons.description_outlined,
                    title: '라이선스',
                    trailing: 'MIT',
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingXl),

              // ── 로그아웃 버튼 ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('로그아웃'),
                        content: const Text('정말 로그아웃하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('취소'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: HelpFlowColors.error,
                            ),
                            child: const Text('로그아웃'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    try {
                      await ref.read(currentUserProvider.notifier).signOut();
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.logout, color: HelpFlowColors.error),
                  label: const Text(
                    '로그아웃',
                    style: TextStyle(color: HelpFlowColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: HelpFlowColors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.buttonRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMd),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 섹션 헤더 ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── 계정 카드 ────────────────────────────────────────────────────────────────

/// 로그인 사용자의 아바타·이름·이메일·역할 배지를 표시하는 카드
class _AccountCard extends StatelessWidget {
  final UserModel user;
  const _AccountCard({required this.user});

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

  Color _roleColor(String role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFB71C1C);
      case UserRole.agent:
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF43A047);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _roleColor(user.role);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Row(
          children: [
            // 아바타
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: AppTextStyles.pageTitle.copyWith(color: color),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : '(이름 없음)',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 역할 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _roleLabel(user.role),
                      style: AppTextStyles.badge.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 설정 카드 컨테이너 ────────────────────────────────────────────────────────

/// 설정 항목들을 묶는 카드 컨테이너
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }
}

// ── 스위치 타일 ──────────────────────────────────────────────────────────────

/// 토글 스위치가 있는 설정 항목
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title, style: AppTextStyles.bodyMd),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }
}

// ── 정보 타일 ────────────────────────────────────────────────────────────────

/// 우측에 텍스트 값이 표시되는 읽기 전용 설정 항목
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
      title: Text(title, style: AppTextStyles.bodyMd),
      trailing: Text(
        trailing,
        style: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: settings_screen.dart
// 역할: 설정 화면. 계정 정보 카드 + 앱 설정(다크모드) + 앱 정보 + 로그아웃.
//       로그아웃 시 확인 다이얼로그 표시 후 signOut() 호출.
//       _AccountCard: 아바타·이름·이메일·역할 배지.
//       _SwitchTile: 다크모드 토글 스위치.
//       _InfoTile: 앱 이름·버전·라이선스 읽기 전용 표시.
// 연관 파일: auth_provider.dart, theme_provider.dart, user_model.dart
// ─────────────────────────────────────────────────────────────────────────────
