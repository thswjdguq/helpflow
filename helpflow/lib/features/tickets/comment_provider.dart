import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/comment_model.dart';
import '../../shared/services/comment_service.dart';

// ── CommentService 프로바이더 ─────────────────────────────────────────────────

/// CommentService 싱글턴 프로바이더
final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService();
});

// ── 댓글 목록 Stream 프로바이더 ───────────────────────────────────────────────

/// 특정 티켓의 댓글 목록을 실시간으로 구독하는 Family StreamProvider
///
/// ticketId를 키로 티켓별 댓글 스트림을 독립적으로 관리합니다.
/// 공개 댓글 + 내부 메모 모두 반환. UI에서 역할에 따라 필터링합니다.
final commentListProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, ticketId) {
  return ref.read(commentServiceProvider).getComments(ticketId);
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: comment_provider.dart
// 역할: 댓글 관련 Riverpod 프로바이더 정의.
//       commentServiceProvider: CommentService 싱글턴.
//       commentListProvider: ticketId별 댓글 실시간 스트림.
//         → 공개 댓글 + 내부 메모 모두 포함. UI에서 isInternal 기준 필터링.
// 연관 파일: comment_service.dart, comment_model.dart, ticket_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
