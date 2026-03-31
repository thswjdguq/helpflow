import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/design_system.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/tickets/ticket_provider.dart';
import '../../shared/models/ticket_model.dart';

/// 티켓 생성 화면
///
/// 입력 항목: 제목(필수, 2~100자), 설명(선택, 2000자 이하),
///           카테고리(드롭다운), 우선순위(드롭다운)
/// 제출 시: ticketListProvider.notifier.createTicket() → /tickets로 이동
class TicketFormScreen extends ConsumerStatefulWidget {
  const TicketFormScreen({super.key});

  @override
  ConsumerState<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends ConsumerState<TicketFormScreen> {
  /// 폼 유효성 검사용 GlobalKey
  final _formKey = GlobalKey<FormState>();

  /// 제목 입력 컨트롤러
  final _titleController = TextEditingController();

  /// 설명 입력 컨트롤러
  final _descriptionController = TextEditingController();

  /// 선택된 카테고리 (기본: 하드웨어)
  String _category = TicketCategory.hardware;

  /// 선택된 우선순위 (기본: 보통)
  String _priority = TicketPriority.medium;

  /// 제출 중 로딩 상태 (버튼 비활성화 용도)
  bool _isLoading = false;

  /// 선택된 이미지 파일 목록 (최대 3장)
  final List<XFile> _selectedImages = [];

  /// image_picker 인스턴스
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 갤러리에서 이미지 선택 (최대 3장 제한)
  Future<void> _pickImages() async {
    final remaining = 3 - _selectedImages.length;
    if (remaining <= 0) return;

    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;

    setState(() {
      _selectedImages.addAll(picked);
    });
  }

  /// 선택된 이미지 제거
  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  /// 폼 제출 처리
  /// 유효성 검사 → 이미지 업로드 → TicketModel 생성 → Firestore 저장 → /tickets로 이동
  Future<void> _submit() async {
    // 유효성 검사 실패 시 중단
    if (!_formKey.currentState!.validate()) return;

    // 로그인 사용자 정보 확인
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      // 이미지가 있으면 Storage 업로드 후 URL 수집
      List<String> imageUrls = const [];
      if (_selectedImages.isNotEmpty) {
        // 임시 ID로 업로드 (티켓 ID는 Firestore 저장 후 확정되므로 uid 사용)
        imageUrls = await ref.read(storageServiceProvider).uploadTicketImages(
              ticketId: 'tmp_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}',
              images: _selectedImages,
            );
      }

      final now = DateTime.now();
      final ticket = TicketModel(
        id: '', // Firestore가 자동 생성
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: TicketStatus.newTicket,
        priority: _priority,
        category: _category,
        reporterId: currentUser.uid,
        imageUrls: imageUrls,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(ticketListProvider.notifier).createTicket(ticket);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('티켓이 생성됐습니다')),
        );
        context.go(AppRoutes.tickets);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: HelpFlowColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 제목 입력 ───────────────────────────────────────────────
              Text(
                AppStrings.ticketFieldTitle,
                style: AppTextStyles.cardTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSm),
              TextFormField(
                controller: _titleController,
                validator: Validators.ticketTitle,
                maxLength: 100,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: '티켓 제목을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMd,
                    vertical: AppSizes.paddingSm,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingMd),

              // ── 설명 입력 ───────────────────────────────────────────────
              Text(
                AppStrings.ticketFieldDescription,
                style: AppTextStyles.cardTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSm),
              TextFormField(
                controller: _descriptionController,
                validator: Validators.ticketDescription,
                maxLines: 5,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: '문제 상황을 상세히 설명해주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMd,
                    vertical: AppSizes.paddingSm,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingMd),

              // ── 카테고리 + 우선순위 드롭다운 (가로 배치) ───────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DropdownField<String>(
                      label: '카테고리',
                      value: _category,
                      items: const [
                        DropdownMenuItem(
                          value: TicketCategory.hardware,
                          child: Text('하드웨어'),
                        ),
                        DropdownMenuItem(
                          value: TicketCategory.software,
                          child: Text('소프트웨어'),
                        ),
                        DropdownMenuItem(
                          value: TicketCategory.network,
                          child: Text('네트워크'),
                        ),
                        DropdownMenuItem(
                          value: TicketCategory.etc,
                          child: Text('기타'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMd),
                  Expanded(
                    child: _DropdownField<String>(
                      label: AppStrings.ticketFieldPriority,
                      value: _priority,
                      items: const [
                        DropdownMenuItem(
                          value: TicketPriority.low,
                          child: Text('낮음'),
                        ),
                        DropdownMenuItem(
                          value: TicketPriority.medium,
                          child: Text('보통'),
                        ),
                        DropdownMenuItem(
                          value: TicketPriority.high,
                          child: Text('높음'),
                        ),
                        DropdownMenuItem(
                          value: TicketPriority.critical,
                          child: Text('긴급'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingMd),

              // ── 이미지 첨부 (최대 3장) ──────────────────────────────────
              Text(
                '첨부 이미지 (선택, 최대 3장)',
                style: AppTextStyles.cardTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSm),
              // 선택된 이미지 미리보기 + 추가 버튼
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // 선택된 이미지 썸네일
                    ..._selectedImages.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSizes.paddingSm),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      entry.value.path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(entry.value.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            // 삭제 버튼
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => _removeImage(entry.key),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: HelpFlowColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // 이미지 추가 버튼 (3장 미만일 때만)
                    if (_selectedImages.length < 3)
                      GestureDetector(
                        onTap: _isLoading ? null : _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: theme.colorScheme.surfaceContainerLowest,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '사진 추가',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingXl),

              // ── 제출 버튼 ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: HelpFlowButtonStyles.filled,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('티켓 생성하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 드롭다운 필드 공통 위젯 ──────────────────────────────────────────────────

/// 레이블 + DropdownButtonFormField 조합 재사용 위젯
class _DropdownField<T> extends StatelessWidget {
  /// 레이블 텍스트
  final String label;

  /// 현재 선택된 값
  final T value;

  /// 드롭다운 항목 목록
  final List<DropdownMenuItem<T>> items;

  /// 값 변경 콜백
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.cardTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSm),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.paddingSm,
            ),
          ),
        ),
      ],
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_form_screen.dart
// 역할: 새 티켓 생성 폼 화면.
//       입력: 제목(2~100자, 필수), 설명(선택, 2000자 이하), 카테고리, 우선순위.
//       제출: ticketListProvider.notifier.createTicket() → /tickets로 이동.
//       에러: SnackBar로 한글 에러 메시지 표시.
//       _DropdownField: 레이블+드롭다운 공통 재사용 위젯.
// 연관 파일: ticket_provider.dart, ticket_model.dart, validators.dart, auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
