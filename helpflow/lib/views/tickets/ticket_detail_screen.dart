import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// 티켓 상세 화면 (뼈대)
/// ticketId를 받아 해당 티켓의 상세 정보를 표시
/// 추후 Hive DB 연동 및 댓글/히스토리 기능 추가 예정
class TicketDetailScreen extends StatelessWidget {
  /// 표시할 티켓의 고유 ID (URL 경로 파라미터에서 전달)
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Center(
        child: Text('티켓 상세 화면 (ID: $ticketId)'),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_detail_screen.dart
// 역할: 티켓 상세 화면 뼈대. ticketId를 파라미터로 받음.
//       추후 Hive 연동, 댓글, 상태 변경, 히스토리 기능 구현 예정.
