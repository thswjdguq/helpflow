import 'package:cloud_firestore/cloud_firestore.dart';

/// 티켓 상태 상수 모음
/// new: 신규 접수
/// in_progress: 처리 중
/// resolved: 해결 완료
/// closed: 종료
class TicketStatus {
  TicketStatus._();

  static const String newTicket = 'new';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String closed = 'closed';

  /// 상태 코드 → 표시용 한글 레이블
  static String label(String status) {
    switch (status) {
      case newTicket:
        return '신규';
      case inProgress:
        return '처리 중';
      case resolved:
        return '해결 완료';
      case closed:
        return '종료';
      default:
        return '알 수 없음';
    }
  }
}

/// 티켓 우선순위 상수 모음
/// low: 낮음
/// medium: 보통
/// high: 높음
/// critical: 긴급
class TicketPriority {
  TicketPriority._();

  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String critical = 'critical';

  /// 우선순위 코드 → 표시용 한글 레이블
  static String label(String priority) {
    switch (priority) {
      case low:
        return '낮음';
      case medium:
        return '보통';
      case high:
        return '높음';
      case critical:
        return '긴급';
      default:
        return '알 수 없음';
    }
  }
}

/// 티켓 카테고리 상수 모음
/// hardware: 하드웨어
/// software: 소프트웨어
/// network: 네트워크
/// etc: 기타
class TicketCategory {
  TicketCategory._();

  static const String hardware = 'hardware';
  static const String software = 'software';
  static const String network = 'network';
  static const String etc = 'etc';

  /// 카테고리 코드 → 표시용 한글 레이블
  static String label(String category) {
    switch (category) {
      case hardware:
        return '하드웨어';
      case software:
        return '소프트웨어';
      case network:
        return '네트워크';
      case etc:
        return '기타';
      default:
        return '알 수 없음';
    }
  }
}

/// HelpFlow IT 헬프데스크 티켓 데이터 모델
///
/// Firestore 컬렉션: 'tickets'
/// 티켓 생성부터 종료까지 전체 생명주기를 관리합니다.
class TicketModel {
  /// Firestore 문서 ID (자동 생성)
  final String id;

  /// 티켓 제목
  final String title;

  /// 티켓 상세 설명
  final String description;

  /// 처리 상태: 'new' / 'in_progress' / 'resolved' / 'closed'
  final String status;

  /// 우선순위: 'low' / 'medium' / 'high' / 'critical'
  final String priority;

  /// 카테고리: 'hardware' / 'software' / 'network' / 'etc'
  final String category;

  /// 티켓을 접수한 사용자의 Firebase Auth UID
  final String reporterId;

  /// 담당 상담원 UID (배정 전에는 null)
  final String? agentId;

  /// 첨부 이미지 URL 목록 (Firebase Storage URL)
  final List<String> imageUrls;

  /// 티켓 생성 시각
  final DateTime createdAt;

  /// 티켓 최종 수정 시각
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.reporterId,
    this.agentId,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore DocumentSnapshot에서 TicketModel 생성 (역직렬화)
  ///
  /// [doc] Firestore DocumentSnapshot
  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TicketModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? TicketStatus.newTicket,
      priority: data['priority'] as String? ?? TicketPriority.medium,
      category: data['category'] as String? ?? TicketCategory.etc,
      reporterId: data['reporterId'] as String? ?? '',
      agentId: data['agentId'] as String?,
      // List<dynamic> → List<String> 안전 변환
      imageUrls: List<String>.from(data['imageUrls'] as List<dynamic>? ?? []),
      // Firestore Timestamp → DateTime 변환
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// TicketModel을 Firestore 저장용 Map으로 변환 (직렬화)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category': category,
      'reporterId': reporterId,
      'agentId': agentId,
      'imageUrls': imageUrls,
      // DateTime → Firestore Timestamp 변환
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 일부 필드만 변경한 새 인스턴스 반환 (불변 객체 패턴)
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? category,
    String? reporterId,
    String? agentId,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      reporterId: reporterId ?? this.reporterId,
      agentId: agentId ?? this.agentId,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TicketModel(id: $id, title: $title, status: $status, priority: $priority)';
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_model.dart
// 역할: IT 헬프데스크 티켓 데이터 모델 정의.
//       TicketStatus / TicketPriority / TicketCategory 상수 클래스로
//       허용 값을 타입 안전하게 관리 (한글 레이블 변환 포함).
//       fromFirestore()로 Firestore 문서 역직렬화, toMap()으로 직렬화.
//       copyWith()로 불변 객체 업데이트 패턴 지원.
// ─────────────────────────────────────────────────────────────────────────────
