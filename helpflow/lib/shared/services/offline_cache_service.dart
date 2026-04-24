import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/ticket_model.dart';

// ── HelpFlow 오프라인 캐시 서비스 ────────────────────────────────────────────
// Hive를 사용해 티켓 목록을 로컬에 저장·조회한다.
// 네트워크 오프라인 상태에서도 마지막으로 불러온 데이터를 표시할 수 있도록 지원한다.
//
// 캐시 전략:
//   - 온라인: Firestore 스트림으로 데이터 수신 → 캐시 자동 갱신
//   - 오프라인: 캐시에서 마지막 저장 데이터 반환
//   - 만료: cachedAt 기준 24시간 초과 시 stale로 표시 (경고 표시용)
//
// Box 이름 규칙: 'hf_' 접두사로 앱 고유성 보장

/// OfflineCacheService 싱글턴 프로바이더
/// main.dart에서 ProviderScope.overrides를 통해 초기화된 인스턴스가 주입됩니다.
final offlineCacheServiceProvider = Provider<OfflineCacheService>(
  (ref) => throw UnimplementedError('main.dart에서 override 필요'),
);

/// Hive Box 이름 상수
class _BoxKeys {
  _BoxKeys._();
  static const String tickets = 'hf_tickets';
  static const String meta = 'hf_meta';
}

/// 캐시 메타데이터 키
class _MetaKeys {
  _MetaKeys._();
  static const String ticketsCachedAt = 'tickets_cached_at';
  static const String myTicketsCachedAt = 'my_tickets_cached_at';
}

/// 캐시 유효 시간 (24시간)
const Duration _cacheExpiry = Duration(hours: 24);

/// HelpFlow 티켓 오프라인 캐시 서비스
///
/// Hive Box를 통해 티켓 목록을 JSON 직렬화 후 로컬에 저장합니다.
/// 앱 시작 시 [init]을 호출해 Box를 열어야 합니다.
class OfflineCacheService {
  // ── Box 참조 ──────────────────────────────────────────────────────────────
  Box<String>? _ticketsBox;
  Box<String>? _metaBox;

  // ── 초기화 ────────────────────────────────────────────────────────────────

  /// Hive Box를 열어 캐시 서비스를 초기화합니다.
  ///
  /// main.dart에서 Hive.initFlutter() 이후에 호출해야 합니다.
  Future<void> init() async {
    _ticketsBox = await Hive.openBox<String>(_BoxKeys.tickets);
    _metaBox = await Hive.openBox<String>(_BoxKeys.meta);
  }

  // ── 전체 티켓 캐시 ────────────────────────────────────────────────────────

  /// 전체 티켓 목록을 캐시에 저장합니다.
  ///
  /// [tickets] 저장할 티켓 목록 (admin/agent 용 전체 목록)
  Future<void> saveTickets(List<TicketModel> tickets) async {
    final box = _ticketsBox;
    final meta = _metaBox;
    if (box == null || meta == null) return;

    try {
      // 각 티켓을 JSON 문자열로 직렬화해 문서 ID를 키로 저장
      for (final ticket in tickets) {
        await box.put('all_${ticket.id}', _ticketToJson(ticket));
      }
      // 캐시 저장 시각 기록
      await meta.put(
        _MetaKeys.ticketsCachedAt,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // 캐시 저장 실패는 무시 (앱 동작에 영향 없음)
      // ignore: avoid_print
      print('[OfflineCache] 전체 티켓 저장 실패: $e');
    }
  }

  /// 캐시에서 전체 티켓 목록을 불러옵니다.
  ///
  /// 반환값: 캐시된 티켓 목록 (없거나 오류 시 빈 리스트)
  List<TicketModel> loadTickets() {
    final box = _ticketsBox;
    if (box == null) return [];

    try {
      final keys = box.keys.where((k) => (k as String).startsWith('all_'));
      return keys
          .map((k) => box.get(k as String))
          .whereType<String>()
          .map(_ticketFromJson)
          .whereType<TicketModel>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      // ignore: avoid_print
      print('[OfflineCache] 전체 티켓 로드 실패: $e');
      return [];
    }
  }

  // ── 내 티켓 캐시 (user 전용) ─────────────────────────────────────────────

  /// 현재 사용자의 티켓 목록을 캐시에 저장합니다.
  ///
  /// [tickets] 저장할 티켓 목록
  /// [uid] 현재 사용자 UID (키 분리용)
  Future<void> saveMyTickets(List<TicketModel> tickets, String uid) async {
    final box = _ticketsBox;
    final meta = _metaBox;
    if (box == null || meta == null) return;

    try {
      // 기존 내 티켓 캐시 제거 후 재저장
      final oldKeys =
          box.keys.where((k) => (k as String).startsWith('my_${uid}_'));
      for (final k in oldKeys.toList()) {
        await box.delete(k);
      }

      for (final ticket in tickets) {
        await box.put('my_${uid}_${ticket.id}', _ticketToJson(ticket));
      }
      await meta.put(
        _MetaKeys.myTicketsCachedAt,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[OfflineCache] 내 티켓 저장 실패: $e');
    }
  }

  /// 캐시에서 현재 사용자의 티켓 목록을 불러옵니다.
  ///
  /// [uid] 현재 사용자 UID
  List<TicketModel> loadMyTickets(String uid) {
    final box = _ticketsBox;
    if (box == null) return [];

    try {
      final prefix = 'my_${uid}_';
      final keys = box.keys.where((k) => (k as String).startsWith(prefix));
      return keys
          .map((k) => box.get(k as String))
          .whereType<String>()
          .map(_ticketFromJson)
          .whereType<TicketModel>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      // ignore: avoid_print
      print('[OfflineCache] 내 티켓 로드 실패: $e');
      return [];
    }
  }

  // ── 캐시 유효성 확인 ──────────────────────────────────────────────────────

  /// 전체 티켓 캐시가 유효한지 확인합니다 (24시간 이내).
  bool isTicketCacheValid() => _isCacheValid(_MetaKeys.ticketsCachedAt);

  /// 내 티켓 캐시가 유효한지 확인합니다 (24시간 이내).
  bool isMyTicketCacheValid() => _isCacheValid(_MetaKeys.myTicketsCachedAt);

  /// 마지막 전체 티켓 캐시 시각을 반환합니다.
  DateTime? get ticketsCachedAt => _getCachedAt(_MetaKeys.ticketsCachedAt);

  bool _isCacheValid(String metaKey) {
    final cachedAt = _getCachedAt(metaKey);
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt) < _cacheExpiry;
  }

  DateTime? _getCachedAt(String metaKey) {
    final meta = _metaBox;
    if (meta == null) return null;
    final raw = meta.get(metaKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ── 캐시 삭제 ────────────────────────────────────────────────────────────

  /// 모든 캐시를 삭제합니다 (로그아웃 시 호출).
  Future<void> clearAll() async {
    try {
      await _ticketsBox?.clear();
      await _metaBox?.clear();
    } catch (e) {
      // ignore: avoid_print
      print('[OfflineCache] 캐시 삭제 실패: $e');
    }
  }

  // ── 직렬화 유틸 ──────────────────────────────────────────────────────────

  /// TicketModel → JSON 문자열 변환
  String _ticketToJson(TicketModel ticket) {
    final map = {
      'id': ticket.id,
      'title': ticket.title,
      'description': ticket.description,
      'status': ticket.status,
      'priority': ticket.priority,
      'category': ticket.category,
      'reporterId': ticket.reporterId,
      'reporterName': ticket.reporterName,
      'agentId': ticket.agentId,
      'imageUrls': ticket.imageUrls,
      'createdAt': ticket.createdAt.toIso8601String(),
      'updatedAt': ticket.updatedAt.toIso8601String(),
    };
    return jsonEncode(map);
  }

  /// JSON 문자열 → TicketModel 변환 (파싱 실패 시 null 반환)
  TicketModel? _ticketFromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return TicketModel(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        status: map['status'] as String? ?? TicketStatus.newTicket,
        priority: map['priority'] as String? ?? TicketPriority.medium,
        category: map['category'] as String? ?? TicketCategory.etc,
        reporterId: map['reporterId'] as String? ?? '',
        reporterName: map['reporterName'] as String? ?? '',
        agentId: map['agentId'] as String?,
        imageUrls: List<String>.from(
          map['imageUrls'] as List<dynamic>? ?? [],
        ),
        createdAt: DateTime.tryParse(
              map['createdAt'] as String? ?? '',
            ) ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(
              map['updatedAt'] as String? ?? '',
            ) ??
            DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: offline_cache_service.dart
// 역할: Hive 기반 티켓 오프라인 캐시 서비스.
//       saveTickets / loadTickets: 전체 티켓 목록 저장/로드 (admin용).
//       saveMyTickets / loadMyTickets: 사용자별 티켓 캐시 (uid 키 분리).
//       isTicketCacheValid / isMyTicketCacheValid: 24시간 유효성 검사.
//       clearAll: 로그아웃 시 전체 캐시 삭제.
//       JSON 직렬화를 사용해 hive_generator 없이 동작 (코드 생성 불필요).
// 사용: main.dart에서 init() 호출, ticket_provider.dart에서 캐시 읽기/쓰기.
// ─────────────────────────────────────────────────────────────────────────────
