import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/user_model.dart';
import 'user_service.dart';

// ── UserService 프로바이더 ─────────────────────────────────────────────────────

/// UserService 싱글턴 프로바이더
final userServiceProvider = Provider<UserService>((ref) => UserService());

// ── 전체 사용자 목록 스트림 프로바이더 ────────────────────────────────────────

/// 전체 사용자 목록 실시간 스트림 (admin 사용자 관리 화면용)
final userListProvider = StreamProvider<List<UserModel>>((ref) {
  final service = ref.read(userServiceProvider);
  return service.getUsers();
});

// ── 담당자 목록 스트림 프로바이더 ─────────────────────────────────────────────

/// role == 'agent'인 사용자 목록 실시간 스트림
/// 티켓 담당자 배정 드롭다운에서 사용
final agentListProvider = StreamProvider<List<UserModel>>((ref) {
  final service = ref.read(userServiceProvider);
  return service.getAgents();
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: user_provider.dart
// 역할: 사용자 관련 Riverpod 프로바이더 모음 (admin 전용 기능).
//       userServiceProvider: UserService 싱글턴.
//       userListProvider: 전체 사용자 실시간 스트림.
//       agentListProvider: 담당자(agent) 목록 실시간 스트림.
// 연관 파일: user_service.dart, user_management_screen.dart, ticket_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
