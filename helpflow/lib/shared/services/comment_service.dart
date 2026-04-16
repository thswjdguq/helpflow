import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

/// 티켓 댓글 Firestore CRUD 서비스
///
/// Firestore 경로: tickets/{ticketId}/comments
/// 서브컬렉션 구조를 사용해 티켓별 댓글을 독립적으로 관리합니다.
class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 특정 티켓의 댓글 서브컬렉션 참조
  CollectionReference<Map<String, dynamic>> _ref(String ticketId) =>
      _firestore.collection('tickets').doc(ticketId).collection('comments');

  // ── 조회 ─────────────────────────────────────────────────────────────────

  /// 특정 티켓의 댓글 목록을 실시간 Stream으로 반환합니다.
  ///
  /// 작성 시각 오름차순(오래된 것부터)으로 정렬됩니다.
  /// [ticketId] 댓글을 조회할 티켓의 Firestore 문서 ID
  Stream<List<CommentModel>> getComments(String ticketId) {
    return _ref(ticketId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromFirestore(d)).toList());
  }

  // ── 생성 ─────────────────────────────────────────────────────────────────

  /// 새 댓글을 Firestore에 저장합니다.
  ///
  /// [comment] 저장할 댓글 모델 (id는 빈 문자열, Firestore가 자동 생성)
  Future<void> addComment(CommentModel comment) async {
    try {
      await _ref(comment.ticketId).add(comment.toMap());
    } on FirebaseException catch (e) {
      throw Exception(_translateError(e.code, '댓글 등록'));
    } catch (e) {
      throw Exception('댓글 등록 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ── 삭제 ─────────────────────────────────────────────────────────────────

  /// 특정 댓글을 Firestore에서 삭제합니다.
  ///
  /// [ticketId] 댓글이 속한 티켓 ID
  /// [commentId] 삭제할 댓글의 Firestore 문서 ID
  Future<void> deleteComment(String ticketId, String commentId) async {
    try {
      await _ref(ticketId).doc(commentId).delete();
    } on FirebaseException catch (e) {
      throw Exception(_translateError(e.code, '댓글 삭제'));
    } catch (e) {
      throw Exception('댓글 삭제 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ── 내부 유틸 ────────────────────────────────────────────────────────────

  String _translateError(String code, String operation) {
    switch (code) {
      case 'permission-denied':
        return '$operation 권한이 없습니다.';
      case 'not-found':
        return '해당 댓글을 찾을 수 없습니다.';
      default:
        return '$operation 중 오류가 발생했습니다. (코드: $code)';
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: comment_service.dart
// 역할: tickets/{ticketId}/comments 서브컬렉션 CRUD 서비스.
//       getComments(): 실시간 스트림, 작성 시각 오름차순.
//       addComment(): 댓글 저장 (id는 Firestore 자동 생성).
//       deleteComment(): 특정 댓글 삭제.
//       모든 FirebaseException을 한글 메시지로 변환해 throw.
// 연관 파일: comment_model.dart, comment_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
