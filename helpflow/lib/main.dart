import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'shared/services/offline_cache_service.dart';

/// 앱 진입점
/// Hive 초기화 → Firebase 초기화 → ProviderScope → App 실행
Future<void> main() async {
  // Flutter 엔진 바인딩 초기화 (async main에서 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 로컬 DB 초기화
  await Hive.initFlutter();

  // 오프라인 캐시 서비스 초기화 (Hive Box 열기)
  final cacheService = OfflineCacheService();
  await cacheService.init();

  // Firebase 초기화
  // firebase_options.dart가 플레이스홀더인 경우 예외를 잡고 계속 진행
  // → 로그인 시도 시 에러 메시지로 안내됨
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // 개발 중 플레이스홀더 상태에서는 무시하고 앱 실행 계속
    // 실제 배포 전 flutterfire configure 실행 필요
    debugPrint('[Firebase] 초기화 실패 (플레이스홀더 상태): $e');
  }

  // ProviderScope로 전체 앱을 감싸서 Riverpod 상태 관리 활성화
  // offlineCacheServiceProvider를 override해 초기화된 인스턴스 주입
  runApp(
    ProviderScope(
      overrides: [
        offlineCacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const App(),
    ),
  );
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: main.dart
// 역할: 앱 진입점.
//       Hive.initFlutter()로 로컬 DB 초기화.
//       OfflineCacheService.init()으로 Hive Box 열기.
//       Firebase.initializeApp()으로 Firebase 초기화
//         (플레이스홀더 상태에서 실패해도 앱은 계속 실행).
//       ProviderScope overrides로 초기화된 OfflineCacheService 주입.
//       ProviderScope로 Riverpod 활성화 후 App 위젯 실행.
