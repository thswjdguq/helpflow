import 'package:flutter/material.dart';

/// 티켓 목록 화면 (뼈대)
/// 추후 Hive DB 연동 및 필터/검색 기능 추가 예정
class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('티켓 목록 화면'),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_list_screen.dart
// 역할: 티켓 목록 화면 뼈대. 추후 Hive 연동, 필터/검색/정렬 기능 구현 예정.
