import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../tickets/ticket_provider.dart';
import '../../shared/models/ticket_model.dart';

/// 대시보드 통계 데이터 모델
///
/// ticketListStreamProvider에서 집계한 실시간 통계값 보관
class TicketStats {
  /// 전체 티켓 수
  final int total;

  /// 신규 티켓 수 (status: new)
  final int newCount;

  /// 처리 중 티켓 수 (status: in_progress)
  final int inProgress;

  /// 해결 완료 티켓 수 (status: resolved)
  final int resolved;

  /// 종료 티켓 수 (status: closed)
  final int closed;

  /// 긴급 우선순위 티켓 수 (priority: critical)
  final int critical;

  const TicketStats({
    required this.total,
    required this.newCount,
    required this.inProgress,
    required this.resolved,
    required this.closed,
    required this.critical,
  });

  /// 빈 통계 (로딩/에러 시 기본값)
  const TicketStats.empty()
      : total = 0,
        newCount = 0,
        inProgress = 0,
        resolved = 0,
        closed = 0,
        critical = 0;
}

// ── 통계 Provider ────────────────────────────────────────────────────────────

/// 전체 티켓을 실시간 집계한 TicketStats StreamProvider
///
/// ticketListStreamProvider를 구독해 상태·우선순위별 카운트를 계산합니다.
final ticketStatsProvider = StreamProvider<TicketStats>((ref) {
  final service = ref.read(ticketServiceProvider);
  return service.getTickets().map((tickets) {
    return TicketStats(
      total: tickets.length,
      newCount: tickets
          .where((t) => t.status == TicketStatus.newTicket)
          .length,
      inProgress: tickets
          .where((t) => t.status == TicketStatus.inProgress)
          .length,
      resolved: tickets
          .where((t) => t.status == TicketStatus.resolved)
          .length,
      closed: tickets
          .where((t) => t.status == TicketStatus.closed)
          .length,
      critical: tickets
          .where((t) => t.priority == TicketPriority.critical)
          .length,
    );
  });
});

// ── 최근 티켓 Provider ───────────────────────────────────────────────────────

/// 최근 5개 티켓을 실시간으로 반환하는 StreamProvider (admin 전용)
///
/// ticketListStreamProvider는 이미 createdAt 내림차순 정렬이므로
/// 앞에서 최대 5개만 슬라이싱합니다.
final recentTicketsProvider = StreamProvider<List<TicketModel>>((ref) {
  final service = ref.read(ticketServiceProvider);
  return service.getTickets().map((tickets) => tickets.take(5).toList());
});

// ── 담당자(agent) 전용 Provider ──────────────────────────────────────────────

/// 현재 로그인한 담당자의 배정 티켓 통계를 실시간 집계하는 StreamProvider
///
/// agentId가 현재 UID와 일치하는 티켓만 집계합니다.
final myAgentStatsProvider = StreamProvider<TicketStats>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const TicketStats.empty());

  final service = ref.read(ticketServiceProvider);
  return service.getTicketsByAgent(uid).map((tickets) {
    return TicketStats(
      total: tickets.length,
      newCount: tickets
          .where((t) => t.status == TicketStatus.newTicket)
          .length,
      inProgress: tickets
          .where((t) => t.status == TicketStatus.inProgress)
          .length,
      resolved: tickets
          .where((t) => t.status == TicketStatus.resolved)
          .length,
      closed: tickets
          .where((t) => t.status == TicketStatus.closed)
          .length,
      critical: tickets
          .where((t) => t.priority == TicketPriority.critical)
          .length,
    );
  });
});

/// 현재 로그인한 담당자의 배정 티켓 중 최근 5개를 반환하는 StreamProvider
final myAgentRecentTicketsProvider = StreamProvider<List<TicketModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);

  final service = ref.read(ticketServiceProvider);
  return service.getTicketsByAgent(uid)
      .map((tickets) => tickets.take(5).toList());
});

// ── 직원(user) 전용 Provider ─────────────────────────────────────────────────

/// 현재 로그인한 직원의 접수 티켓 통계를 실시간 집계하는 StreamProvider
///
/// reporterId가 현재 UID와 일치하는 티켓만 집계합니다.
final myUserStatsProvider = StreamProvider<TicketStats>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const TicketStats.empty());

  final service = ref.read(ticketServiceProvider);
  return service.getTicketsByReporter(uid).map((tickets) {
    return TicketStats(
      total: tickets.length,
      newCount: tickets
          .where((t) => t.status == TicketStatus.newTicket)
          .length,
      inProgress: tickets
          .where((t) => t.status == TicketStatus.inProgress)
          .length,
      resolved: tickets
          .where((t) => t.status == TicketStatus.resolved)
          .length,
      closed: tickets
          .where((t) => t.status == TicketStatus.closed)
          .length,
      critical: tickets
          .where((t) => t.priority == TicketPriority.critical)
          .length,
    );
  });
});

/// 현재 로그인한 직원의 접수 티켓 중 최근 5개를 반환하는 StreamProvider
final myUserRecentTicketsProvider = StreamProvider<List<TicketModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);

  final service = ref.read(ticketServiceProvider);
  return service.getTicketsByReporter(uid)
      .map((tickets) => tickets.take(5).toList());
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: dashboard_provider.dart
// 역할: 대시보드 실시간 통계 데이터 Provider 정의.
//       TicketStats: 전체/신규/처리중/해결됨/종료/긴급 카운트 모델.
//       ticketStatsProvider: 전체 티켓 집계 (admin).
//       recentTicketsProvider: 최근 5개 티켓 (admin).
//       myAgentStatsProvider: 담당자 배정 티켓 통계 (agent).
//       myAgentRecentTicketsProvider: 담당자 배정 최근 5개 (agent).
//       myUserStatsProvider: 직원 접수 티켓 통계 (user).
//       myUserRecentTicketsProvider: 직원 접수 최근 5개 (user).
// 연관 파일: ticket_provider.dart, ticket_service.dart, dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
