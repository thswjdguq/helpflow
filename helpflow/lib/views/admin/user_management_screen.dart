import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/design_system.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/admin/user_provider.dart';
import '../../features/auth/user_model.dart';

/// 사용자 관리 화면 (admin 전용)
///
/// Firestore users 컬렉션 전체를 실시간 조회해 목록 표시.
/// 각 사용자의 역할 배지를 탭하면 역할 변경 다이얼로그 표시.
class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 페이지 제목 ────────────────────────────────────────────
            Text(
              '사용자 관리',
              style: AppTextStyles.pageTitle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '사용자의 역할을 관리합니다',
              style: AppTextStyles.bodySm.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLg),

            // ── 사용자 목록 ────────────────────────────────────────────
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        '등록된 사용자가 없습니다',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _UserTile(user: users[index]),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    style: const TextStyle(color: HelpFlowColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 사용자 목록 타일 ──────────────────────────────────────────────────────────

/// 사용자 한 명의 정보 표시 + 역할 변경 버튼
class _UserTile extends ConsumerWidget {
  final UserModel user;

  const _UserTile({required this.user});

  /// 역할 코드 → 표시 텍스트
  String _roleLabel(String role) {
    switch (role) {
      case UserRole.admin:
        return '관리자';
      case UserRole.agent:
        return '담당자';
      default:
        return '직원';
    }
  }

  /// 역할 코드 → 색상
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

  /// 역할 변경 다이얼로그 표시
  Future<void> _showRoleDialog(BuildContext context, WidgetRef ref) async {
    String selected = user.role;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('${user.name} 역할 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.email,
                style: AppTextStyles.bodySm.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMd),
              // RadioGroup으로 역할 선택 (Flutter 3.32+ 신규 API)
              RadioGroup<String>(
                groupValue: selected,
                onChanged: (v) {
                  if (v != null) setState(() => selected = v);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: UserRole.user,
                      title: Text('직원', style: AppTextStyles.bodyMd),
                    ),
                    RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: UserRole.agent,
                      title: Text('담당자', style: AppTextStyles.bodyMd),
                    ),
                    RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: UserRole.admin,
                      title: Text('관리자', style: AppTextStyles.bodyMd),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('변경'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || selected == user.role) return;

    try {
      await ref.read(userServiceProvider).updateUserRole(user.uid, selected);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('역할이 변경됐습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: HelpFlowColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _roleColor(user.role);

    return ListTile(
      // 이름 이니셜 아바타
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: AppTextStyles.cardTitle.copyWith(color: color),
        ),
      ),
      title: Text(user.name, style: AppTextStyles.cardTitle),
      subtitle: Text(
        user.email,
        style: AppTextStyles.bodySm.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 역할 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _roleLabel(user.role),
              style: AppTextStyles.badge.copyWith(color: color),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm),
          // 역할 변경 버튼
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            iconSize: AppSizes.iconMd,
            tooltip: '역할 변경',
            onPressed: () => _showRoleDialog(context, ref),
          ),
        ],
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: user_management_screen.dart
// 역할: admin 전용 사용자 관리 화면.
//       userListProvider로 전체 사용자 실시간 목록 표시.
//       _UserTile: 이름/이메일/역할 배지 표시 + 편집 버튼 → _showRoleDialog.
//       _showRoleDialog: 라디오 버튼으로 역할(직원/담당자/관리자) 변경.
// 연관 파일: user_provider.dart, user_service.dart, user_model.dart
// ─────────────────────────────────────────────────────────────────────────────
