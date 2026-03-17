import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// 티켓 생성/수정 폼 화면 (뼈대)
/// 새 티켓 생성(/tickets/new)과 기존 티켓 수정 모두 이 화면을 사용
/// 추후 폼 필드, 유효성 검사, Hive 저장 기능 추가 예정
class TicketFormScreen extends StatelessWidget {
  const TicketFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Center(
        child: Text('티켓 생성/수정 화면'),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_form_screen.dart
// 역할: 새 티켓 생성 및 기존 티켓 수정 폼 화면 뼈대.
//       추후 제목/설명/우선순위/담당자 폼 필드, validators.dart 연동, Hive 저장 구현 예정.
