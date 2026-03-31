import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Firebase Storage 이미지 업로드 서비스
///
/// 티켓 첨부 이미지를 Storage 'ticket_images/{ticketId}/' 경로에 저장합니다.
/// 웹(XFile bytes)과 모바일(File path) 양쪽을 지원합니다.
class StorageService {
  /// Firebase Storage 인스턴스
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── 업로드 ─────────────────────────────────────────────────────────────────

  /// XFile 목록을 Firebase Storage에 업로드하고 다운로드 URL 목록을 반환합니다.
  ///
  /// [ticketId] 업로드 경로에 포함될 티켓 ID (또는 임시 UID)
  /// [images]   image_picker에서 선택된 XFile 목록
  /// 반환값: 업로드된 각 이미지의 공개 다운로드 URL 목록
  Future<List<String>> uploadTicketImages({
    required String ticketId,
    required List<XFile> images,
  }) async {
    final urls = <String>[];

    for (final image in images) {
      try {
        // 파일명: 타임스탬프_원본파일명
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = _storage
            .ref()
            .child('ticket_images')
            .child(ticketId)
            .child(fileName);

        UploadTask task;

        if (kIsWeb) {
          // 웹: bytes로 업로드
          final bytes = await image.readAsBytes();
          final metadata = SettableMetadata(
            contentType: 'image/${_extFromName(image.name)}',
          );
          task = ref.putData(bytes, metadata);
        } else {
          // 모바일: File 경로로 업로드
          task = ref.putFile(File(image.path));
        }

        final snapshot = await task;
        final url = await snapshot.ref.getDownloadURL();
        urls.add(url);
      } on FirebaseException catch (e) {
        throw Exception(_translateError(e.code));
      } catch (e) {
        throw Exception('이미지 업로드 중 오류가 발생했습니다.');
      }
    }

    return urls;
  }

  /// Storage 경로의 파일을 삭제합니다.
  ///
  /// [url] Firebase Storage 다운로드 URL
  Future<void> deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      // 파일이 없으면 무시 (이미 삭제된 경우)
      if (e.code != 'object-not-found') {
        throw Exception(_translateError(e.code));
      }
    }
  }

  // ── 내부 유틸 ────────────────────────────────────────────────────────────

  /// 파일명에서 확장자를 추출해 MIME 서브타입으로 반환합니다.
  String _extFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    const map = {'jpg': 'jpeg', 'jpeg': 'jpeg', 'png': 'png', 'webp': 'webp'};
    return map[ext] ?? 'jpeg';
  }

  /// Firebase Storage 에러 코드를 한글 메시지로 변환합니다.
  String _translateError(String code) {
    switch (code) {
      case 'unauthorized':
        return '이미지 업로드 권한이 없습니다. 로그인 상태를 확인해주세요.';
      case 'quota-exceeded':
        return '스토리지 용량이 초과됐습니다.';
      case 'unauthenticated':
        return '로그인 후 이미지를 업로드할 수 있습니다.';
      default:
        return '이미지 업로드 중 오류가 발생했습니다. (코드: $code)';
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: storage_service.dart
// 역할: Firebase Storage 이미지 업로드/삭제 서비스.
//       uploadTicketImages: XFile 목록을 ticket_images/{ticketId}/ 경로에 저장 후 URL 반환.
//       deleteImage: 다운로드 URL로 Storage 파일 삭제.
//       웹(bytes)·모바일(File) 양쪽 지원.
// 연관 파일: ticket_form_screen.dart, ticket_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
