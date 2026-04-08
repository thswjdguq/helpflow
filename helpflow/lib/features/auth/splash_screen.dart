import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// 앱 시작 스플래시 화면
///
/// Firebase Auth 초기화 중(authState loading) 표시.
/// 로딩 완료 후 go_router redirect가 인증 상태에 따라 자동 이동:
///   - 비로그인 → /login
///   - 로그인 + admin → /dashboard
///   - 로그인 + user/agent → /tickets
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: HelpFlowColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),

            // 앱 이름
            const Text('HelpFlow', style: HelpFlowTextStyles.headline2),
            const SizedBox(height: 8),
            Text(
              '헬프데스크 관리 시스템',
              style: HelpFlowTextStyles.body2.copyWith(
                color: HelpFlowColors.gray500,
              ),
            ),
            const SizedBox(height: 48),

            // 로딩 인디케이터
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: HelpFlowColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: splash_screen.dart
// 역할: 앱 시작 시 Firebase Auth 초기화 중 표시하는 스플래시 화면.
//       인증 완료 후 go_router redirect가 자동으로 알맞은 화면으로 이동.
// 연관 파일: app_router.dart (initialLocation, redirect 로직)
// ─────────────────────────────────────────────────────────────────────────────
