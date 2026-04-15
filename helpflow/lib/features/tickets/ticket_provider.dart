import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_provider.dart';
import '../../shared/models/ticket_model.dart';
import '../../shared/services/ticket_service.dart';
import '../../shared/services/storage_service.dart';

// ── TicketService 프로바이더 ─────────────────────────────────────────────────

/// TicketService 싱글턴 프로바이더
/// CRUD 메서드 호출 시 ref.read(ticketServiceProvider)로 접근
final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService();
});

/// StorageService 싱글턴 프로바이더
/// 이미지 업로드 시 ref.read(storageServiceProvider)로 접근
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// ── 전체 티켓 목록 Stream 프로바이더 ─────────────────────────────────────────

/// 전체 티켓 목록을 실시간으로 구독하는 StreamProvider
/// Firestore 변경 시 자동으로 UI 갱신됨 (createdAt 내림차순)
final ticketListStreamProvider = StreamProvider<List<TicketModel>>((ref) {
  final ticketService = ref.read(ticketServiceProvider);
  return ticketService.getTickets();
});

/// 현재 로그인 사용자의 티켓 목록만 구독하는 StreamProvider
/// reporterId가 현재 UID와 일치하는 티켓만 반환 (user 역할 전용)
final myTicketListStreamProvider = StreamProvider<List<TicketModel>>((ref) {
  final ticketService = ref.read(ticketServiceProvider);
  // 현재 로그인 사용자 UID 조회
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;

  if (uid == null) {
    // 로그아웃 상태: 빈 리스트 반환
    return Stream.value([]);
  }

  return ticketService.getTicketsByReporter(uid);
});

/// 현재 로그인 담당자(agent)에게 배정된 티켓 목록을 구독하는 StreamProvider
/// agentId가 현재 UID와 일치하는 티켓만 반환 (agent 역할 전용)
final myAssignedTicketListProvider = StreamProvider<List<TicketModel>>((ref) {
  final ticketService = ref.read(ticketServiceProvider);
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;

  if (uid == null) {
    return Stream.value([]);
  }

  return ticketService.getTicketsByAgent(uid);
});

// ── 티켓 목록 상태 관리 Notifier ──────────────────────────────────────────────

/// 티켓 CRUD 작업 상태를 관리하는 AsyncNotifier
///
/// build()에서 초기 티켓 목록을 로드합니다.
/// createTicket / updateTicket / deleteTicket 작업 후 state를 갱신합니다.
class TicketListNotifier extends AsyncNotifier<List<TicketModel>> {
  /// 초기 상태 빌드: Firestore에서 전체 티켓 목록 로드
  @override
  Future<List<TicketModel>> build() async {
    final ticketService = ref.read(ticketServiceProvider);
    // Stream의 첫 번째 값을 await해서 초기 리스트 반환
    return ticketService.getTickets().first;
  }

  // ── 생성 ───────────────────────────────────────────────────────────────────

  /// 새 티켓을 Firestore에 저장하고 state를 갱신합니다.
  ///
  /// [ticket] 저장할 티켓 모델 (id는 빈 문자열로 전달, Firestore가 자동 생성)
  /// 성공 시: state = AsyncData(갱신된 목록)
  /// 실패 시: state = AsyncError + rethrow
  Future<void> createTicket(TicketModel ticket) async {
    state = const AsyncLoading();
    final ticketService = ref.read(ticketServiceProvider);

    try {
      // Firestore에 저장 후 생성된 문서 ID 반환
      final newId = await ticketService.createTicket(ticket);
      // 저장된 티켓에 실제 ID 부여 후 현재 목록 앞에 추가
      final newTicket = ticket.copyWith(id: newId);
      final currentList = state.value ?? [];
      state = AsyncData([newTicket, ...currentList]);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ── 수정 ───────────────────────────────────────────────────────────────────

  /// 기존 티켓 정보를 업데이트하고 state를 갱신합니다.
  ///
  /// [ticket] 수정할 티켓 모델 (id로 Firestore 문서 특정)
  /// 성공 시: state = AsyncData(갱신된 목록)
  /// 실패 시: state = AsyncError + rethrow
  Future<void> updateTicket(TicketModel ticket) async {
    state = const AsyncLoading();
    final ticketService = ref.read(ticketServiceProvider);

    try {
      await ticketService.updateTicket(ticket);
      // 현재 목록에서 해당 id의 티켓만 교체
      final currentList = state.value ?? [];
      final updatedList = currentList.map((t) {
        return t.id == ticket.id ? ticket : t;
      }).toList();
      state = AsyncData(updatedList);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ── 삭제 ───────────────────────────────────────────────────────────────────

  /// 티켓을 Firestore에서 삭제하고 state를 갱신합니다.
  ///
  /// [id] 삭제할 티켓의 Firestore 문서 ID
  /// 성공 시: state = AsyncData(갱신된 목록)
  /// 실패 시: state = AsyncError + rethrow
  Future<void> deleteTicket(String id) async {
    state = const AsyncLoading();
    final ticketService = ref.read(ticketServiceProvider);

    try {
      await ticketService.deleteTicket(id);
      // 현재 목록에서 해당 id 제거
      final currentList = state.value ?? [];
      final updatedList = currentList.where((t) => t.id != id).toList();
      state = AsyncData(updatedList);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ── 상태 변경 ──────────────────────────────────────────────────────────────

  /// 티켓 상태만 빠르게 변경합니다 (전체 ticket 객체 없이도 호출 가능).
  ///
  /// [id] 상태를 변경할 티켓 ID
  /// [newStatus] 변경할 상태 값 (TicketStatus 상수 사용 권장)
  Future<void> changeTicketStatus(String id, String newStatus) async {
    final ticketService = ref.read(ticketServiceProvider);

    try {
      await ticketService.updateTicketStatus(id, newStatus);
      // state 내 해당 티켓의 status 필드만 갱신
      final currentList = state.value ?? [];
      final updatedList = currentList.map((t) {
        if (t.id != id) return t;
        return t.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }).toList();
      state = AsyncData(updatedList);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// TicketListNotifier 프로바이더
final ticketListProvider =
    AsyncNotifierProvider<TicketListNotifier, List<TicketModel>>(
  TicketListNotifier.new,
);

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_provider.dart
// 역할: Riverpod 기반 티켓 상태 관리.
//       ticketServiceProvider: TicketService 싱글턴 제공.
//       ticketListStreamProvider: 전체 티켓 실시간 Stream (admin/agent용).
//       myTicketListStreamProvider: 본인 티켓만 실시간 Stream (user용).
//       TicketListNotifier: createTicket / updateTicket / deleteTicket /
//         changeTicketStatus 제공. 에러 시 rethrow로 UI catch 블록 실행 가능.
// ─────────────────────────────────────────────────────────────────────────────
