import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

/// 앱 진입점
/// Hive 초기화 및 ProviderScope 설정 후 앱 실행
Future<void> main() async {
  // Flutter 바인딩 초기화 (async main에서 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 로컬 DB 초기화
  await Hive.initFlutter();

  // TODO: TicketModel Hive 어댑터 등록 (2주차 모델 구현 후 활성화)
  // Hive.registerAdapter(TicketModelAdapter());

  // ProviderScope로 전체 앱을 감싸서 Riverpod 상태 관리 활성화
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: main.dart
// 역할: 앱 진입점. Hive.initFlutter()로 로컬 DB 초기화,
//       ProviderScope로 Riverpod 활성화, App 위젯 실행.
//       TicketModel 어댑터 등록은 2주차 모델 구현 후 활성화 예정.
