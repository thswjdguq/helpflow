import 'package:flutter/material.dart';

// ── 스켈레톤 로딩 위젯 ─────────────────────────────────────────────────────────
// 토스 스타일 shimmer 애니메이션 없이 부드러운 fade 박동 효과로 구현.
// 데이터 로딩 중 콘텐츠 레이아웃을 미리 보여줘 레이아웃 시프트(CLS)를 방지한다.
//
// 사용법:
//   SkeletonBox(width: 120, height: 16)  // 텍스트 줄 1개
//   SkeletonTicketCard()                 // 티켓 목록 카드 1개
//   SkeletonTicketList(count: 3)         // 티켓 목록 3개

/// 기본 스켈레톤 박스 — 지정한 크기의 회색 박동 직사각형
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    // 1.2초 주기로 0.3 ↔ 0.7 사이를 부드럽게 왕복 (박동 효과)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8EAED);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// 티켓 카드 1개 스켈레톤
///
/// 실제 _TicketCard 레이아웃을 모방해 로딩 중 레이아웃 안정성을 보장
class SkeletonTicketCard extends StatelessWidget {
  const SkeletonTicketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 상태·우선순위 배지 + 날짜
            Row(
              children: [
                const SkeletonBox(width: 44, height: 22, borderRadius: 4),
                const SizedBox(width: 6),
                const SkeletonBox(width: 36, height: 22, borderRadius: 4),
                const Spacer(),
                const SkeletonBox(width: 50, height: 14),
              ],
            ),
            const SizedBox(height: 10),

            // 제목
            const SkeletonBox(width: double.infinity, height: 16),
            const SizedBox(height: 6),
            const SkeletonBox(width: 200, height: 16),
            const SizedBox(height: 8),

            // 설명
            const SkeletonBox(width: double.infinity, height: 14),
            const SizedBox(height: 4),
            const SkeletonBox(width: 160, height: 14),
            const SizedBox(height: 10),

            // 카테고리
            const SkeletonBox(width: 80, height: 14),
          ],
        ),
      ),
    );
  }
}

/// 티켓 목록 스켈레톤 (여러 카드)
///
/// [count] 표시할 카드 수 (기본 4)
class SkeletonTicketList extends StatelessWidget {
  final int count;

  const SkeletonTicketList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => const SkeletonTicketCard(),
    );
  }
}

/// 대시보드 통계 카드 스켈레톤 1개
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 영역
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFE8EAED),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // 수치 + 레이블
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(width: 40, height: 24),
                SizedBox(height: 6),
                SkeletonBox(width: 60, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 대시보드 통계 카드 그리드 스켈레톤
class SkeletonStatGrid extends StatelessWidget {
  final int count;

  const SkeletonStatGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(count, (_) => const SkeletonStatCard()),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: skeleton_loader.dart
// 역할: 토스 스타일 스켈레톤 로딩 위젯 모음.
//       SkeletonBox: 기본 박동(pulse) 애니메이션 직사각형.
//       SkeletonTicketCard: 티켓 카드 1개 레이아웃 모방 스켈레톤.
//       SkeletonTicketList: 티켓 목록용 스켈레톤 (count개).
//       SkeletonStatCard: 대시보드 통계 카드 스켈레톤.
//       SkeletonStatGrid: 통계 카드 그리드 스켈레톤.
//       AnimationController + opacity 변화로 shimmer 없이 박동 효과 구현.
// 사용: ticket_list_screen.dart, dashboard_screen.dart 로딩 상태에서 호출.
// ─────────────────────────────────────────────────────────────────────────────
