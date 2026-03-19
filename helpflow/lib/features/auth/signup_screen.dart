import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system.dart';
import '../../core/router/app_router.dart';
import 'auth_provider.dart';

/// 회원가입 화면
/// 이름/이메일/비밀번호 입력 후 Firebase Auth 계정 생성 처리
/// 토스 스타일: 흰 배경, 넓은 여백, radius 12
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  /// 폼 전체 유효성 검사용 키
  final _formKey = GlobalKey<FormState>();

  /// 이름 입력 컨트롤러
  final _nameController = TextEditingController();

  /// 이메일 입력 컨트롤러
  final _emailController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final _passwordController = TextEditingController();

  /// 회원가입 요청 중 여부
  bool _isLoading = false;

  /// 서버에서 받은 에러 메시지 (null이면 표시 안 함)
  String? _errorMessage;

  @override
  void dispose() {
    // 위젯 소멸 시 컨트롤러 메모리 해제
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 회원가입 버튼 클릭 처리
  /// 유효성 검사 → Riverpod signUp 호출 → 성공 시 라우터가 자동 리다이렉트
  Future<void> _handleSignup() async {
    // 폼 유효성 검사 실패 시 중단
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(currentUserProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    } catch (e) {
      // Exception: 접두사 제거 후 화면에 표시
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      // 위젯이 아직 살아있을 때만 상태 변경
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HelpFlowSpacing.xxxl),
          child: ConstrainedBox(
            // 최대 너비 제한 (웹에서 너무 넓어지지 않도록)
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SignupHeader(),
                const SizedBox(height: HelpFlowSpacing.xxxl),
                _SignupForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const SizedBox(height: HelpFlowSpacing.lg),
                // 에러 메시지: 있을 때만 표시
                if (_errorMessage != null) ...[
                  _SignupErrorMessage(message: _errorMessage!),
                  const SizedBox(height: HelpFlowSpacing.md),
                ],
                _SignupButton(
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: HelpFlowSpacing.md),
                _LoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 헤더 ───────────────────────────────────────────────────────────────────

/// 회원가입 화면 상단 헤더 위젯
class _SignupHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: HelpFlowColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.support_agent, color: Colors.white, size: 34),
        ),
        const SizedBox(height: HelpFlowSpacing.md),
        const Text('회원가입', style: HelpFlowTextStyles.headline2),
        const SizedBox(height: HelpFlowSpacing.xs),
        Text(
          'HelpFlow 계정을 만들어보세요',
          style: HelpFlowTextStyles.body2.copyWith(
            color: HelpFlowColors.gray500,
          ),
        ),
      ],
    );
  }
}

// ── 입력 폼 ────────────────────────────────────────────────────────────────

/// 회원가입 입력 폼 위젯
/// 이름 / 이메일 / 비밀번호 TextFormField 포함
class _SignupForm extends StatelessWidget {
  const _SignupForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // 이름 입력 필드
          TextFormField(
            controller: nameController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: '이름',
              hintText: '홍길동',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: HelpFlowSpacing.md),
          // 이메일 입력 필드
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'example@company.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요.';
              }
              if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(value.trim())) {
                return '올바른 이메일 형식이 아닙니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: HelpFlowSpacing.md),
          // 비밀번호 입력 필드 (obscureText로 마스킹)
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              hintText: '6자 이상 입력',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
              if (value.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// ── 에러 메시지 ────────────────────────────────────────────────────────────

/// 에러 메시지 표시 위젯
class _SignupErrorMessage extends StatelessWidget {
  const _SignupErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HelpFlowSpacing.lg,
        vertical: HelpFlowSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: HelpFlowColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: HelpFlowTextStyles.body2.copyWith(color: HelpFlowColors.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── 회원가입 버튼 ──────────────────────────────────────────────────────────

/// 회원가입 버튼 위젯
/// 로딩 중에는 스피너 표시, 버튼 비활성화
class _SignupButton extends StatelessWidget {
  const _SignupButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('회원가입'),
    );
  }
}

// ── 로그인 링크 ────────────────────────────────────────────────────────────

/// 로그인 화면 이동 링크 위젯
class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('이미 계정이 있으신가요?', style: HelpFlowTextStyles.body2),
        TextButton(
          // /login 경로로 이동
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('로그인'),
        ),
      ],
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: signup_screen.dart
// 역할: 이름/이메일/비밀번호 회원가입 화면.
//       _SignupScreenState._handleSignup()으로 currentUserProvider.signUp() 호출.
//       회원가입 성공 시 go_router redirect 콜백이 자동으로 /dashboard로 이동.
//       유효성 검사, 로딩 처리, 한글 에러 메시지 표시.
//       위젯 분리: _SignupHeader / _SignupForm / _SignupErrorMessage / _SignupButton / _LoginLink.
//       토스 스타일: 흰 배경(#FFFFFF), radius 12, 넓은 여백.
