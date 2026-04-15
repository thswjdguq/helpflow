import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_model.dart';

/// Firestore 티켓 CRUD 서비스
///
/// Firestore 컬렉션 'tickets'와 직접 통신합니다.
/// 모든 에러는 한글 메시지로 변환해 throw합니다.
class TicketService {
  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 티켓 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _ticketsRef =>
      _firestore.collection('tickets');

  // ── 생성 ─────────────────────────────────────────────────────────────────

  /// 새 티켓을 Firestore에 저장합니다.
  ///
  /// [ticket] 저장할 티켓 모델. id 필드는 Firestore가 자동 생성합니다.
  /// 반환값: 생성된 티켓의 Firestore 문서 ID
  Future<String> createTicket(TicketModel ticket) async {
    try {
      final docRef = await _ticketsRef.add(ticket.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception(_translateFirebaseError(e.code, '티켓 생성'));
    } catch (e) {
      throw Exception('티켓 생성 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ── 조회 ─────────────────────────────────────────────────────────────────

  /// 전체 티켓 목록을 실시간 Stream으로 반환합니다.
  ///
  /// 최신 순(createdAt 내림차순)으로 정렬됩니다.
  Stream<List<TicketModel>> getTickets() {
    return _ticketsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 특정 보고자(reporterId)의 티켓 목록을 실시간 Stream으로 반환합니다.
  ///
  /// [reporterId] 조회할 사용자의 Firebase Auth UID
  Stream<List<TicketModel>> getTicketsByReporter(String reporterId) {
    return _ticketsRef
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 특정 담당자(agentId)에게 배정된 티켓 목록을 실시간 Stream으로 반환합니다.
  ///
  /// [agentId] 조회할 담당자의 Firebase Auth UID
  Stream<List<TicketModel>> getTicketsByAgent(String agentId) {
    return _ticketsRef
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 단일 티켓을 ID로 실시간 구독합니다.
  ///
  /// [id] 구독할 티켓의 Firestore 문서 ID
  /// 반환값: 변경될 때마다 새 값을 방출하는 Stream (문서 없으면 null 방출)
  Stream<TicketModel?> getTicketStream(String id) {
    return _ticketsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TicketModel.fromFirestore(doc);
    });
  }

  /// 단일 티켓을 ID로 조회합니다.
  ///
  /// [id] 조회할 티켓의 Firestore 문서 ID
  /// 반환값: 해당 티켓 모델, 존재하지 않으면 null
  Future<TicketModel?> getTicketById(String id) async {
    try {
      final doc = await _ticketsRef.doc(id).get();
      if (!doc.exists) return null;
      return TicketModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception(_translateFirebaseError(e.code, '티켓 조회'));
    } catch (e) {
      throw Exception('티켓 조회 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ── 수정 ─────────────────────────────────────────────────────────────────

  /// 기존 티켓 정보를 업데이트합니다.
  ///
  /// [ticket] 수정할 티켓 모델. id 필드로 Firestore 문서를 특정합니다.
  /// updatedAt은 현재 시각으로 자동 갱신됩니다.
  Future<void> updateTicket(TicketModel ticket) async {
    try {
      // updatedAt을 현재 시각으로 갱신한 Map 생성
      final data = ticket.copyWith(updatedAt: DateTime.now()).toMap();
      await _ticketsRef.doc(ticket.id).update(data);
    } on FirebaseException catch (e) {
      throw Exception(_translateFirebaseError(e.code, '티켓 수정'));
    } catch (e) {
      throw Exception('티켓 수정 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  /// 티켓 상태만 변경합니다.
  ///
  /// [id] 상태를 변경할 티켓 ID
  /// [status] 변경할 상태 값 (TicketStatus 상수 사용)
  Future<void> updateTicketStatus(String id, String status) async {
    try {
      await _ticketsRef.doc(id).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw Exception(_translateFirebaseError(e.code, '티켓 상태 변경'));
    } catch (e) {
      throw Exception('티켓 상태 변경 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ── 삭제 ─────────────────────────────────────────────────────────────────

  /// 티켓을 Firestore에서 삭제합니다.
  ///
  /// [id] 삭제할 티켓의 Firestore 문서 ID
  Future<void> deleteTicket(String id) async {
    try {
      await _ticketsRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception(_translateFirebaseError(e.code, '티켓 삭제'));
    } catch (e) {
      throw Exception('티켓 삭제 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ── 내부 유틸 ────────────────────────────────────────────────────────────

  /// Firebase 에러 코드를 한글 사용자 메시지로 변환합니다.
  ///
  /// [code] FirebaseException.code 값
  /// [operation] 에러가 발생한 작업명 (예: '티켓 생성')
  String _translateFirebaseError(String code, String operation) {
    switch (code) {
      case 'permission-denied':
        return '$operation 권한이 없습니다. 로그인 상태를 확인해주세요.';
      case 'not-found':
        return '해당 티켓을 찾을 수 없습니다.';
      case 'unavailable':
        return '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
      case 'deadline-exceeded':
        return '요청 시간이 초과됐습니다. 네트워크 상태를 확인해주세요.';
      default:
        return '$operation 중 오류가 발생했습니다. (코드: $code)';
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_service.dart
// 역할: Firestore 'tickets' 컬렉션에 대한 CRUD 서비스 레이어.
//       createTicket / getTickets / getTicketsByReporter / getTicketsByAgent /
//       getTicketStream / getTicketById /
//       updateTicket / updateTicketStatus / deleteTicket 메서드 제공.
//       getTickets / getTicketsByReporter / getTicketsByAgent / getTicketStream은
//       Stream 반환 (실시간). 모든 FirebaseException을 한글 메시지로 변환해 throw.
// ─────────────────────────────────────────────────────────────────────────────
