import 'package:flutter/material.dart';

/// 설정 화면 (뼈대)
/// 다크 모드 토글, 언어, 알림 설정 등 구현 예정
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('설정 화면'),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: settings_screen.dart
// 역할: 설정 화면 뼈대. 추후 다크 모드, 언어, 알림 설정 옵션 구현 예정.
