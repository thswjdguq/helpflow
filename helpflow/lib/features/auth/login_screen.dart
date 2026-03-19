import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system.dart';
import '../../core/router/app_router.dart';
import 'auth_provider.dart';

/// 로그인 화면
/// 이메일/비밀번호 입력 후 Firebase Auth 로그인 처리
/// 토스 스타일: 흰 배경, 넓은 여백, radius 12
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// 폼 전체 유효성 검사용 키
  final _formKey = GlobalKey<FormState>();

  /// 이메일 입력 컨트롤러
  final _emailController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final _passwordController = TextEditingController();

  /// 로그인 요청 중 여부
  bool _isLoading = false;

  /// 서버에서 받은 에러 메시지 (null이면 표시 안 함)
  String? _errorMessage;

  @override
  void dispose() {
    // 위젯 소멸 시 컨트롤러 메모리 해제
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 로그인 버튼 클릭 처리
  /// 유효성 검사 → Riverpod signIn 호출 → 성공 시 라우터가 자동 리다이렉트
  Future<void> _handleLogin() async {
    // 폼 유효성 검사 실패 시 중단
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // signIn()은 실패 시 rethrow하므로 여기서 catch 가능
      await ref.read(currentUserProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // 성공 시 go_router redirect가 /dashboard로 자동 이동
    } catch (e) {
      // 'Exception: ' 접두사 제거 후 한글 메시지 추출
      final message = e.toString().replaceFirst('Exception: ', '');

      // 인라인 에러 메시지 업데이트
      if (mounted) {
        setState(() => _errorMessage = message);
      }

      // SnackBar로도 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: HelpFlowColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(HelpFlowSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      // 위젯이 살아있을 때만 로딩 종료 처리
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
                _LoginHeader(),
                const SizedBox(height: HelpFlowSpacing.xxxl),
                _LoginForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const SizedBox(height: HelpFlowSpacing.lg),
                // 에러 메시지: 있을 때만 표시
                if (_errorMessage != null) ...[
                  _ErrorMessage(message: _errorMessage!),
                  const SizedBox(height: HelpFlowSpacing.md),
                ],
                _LoginButton(
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: HelpFlowSpacing.md),
                _SignupLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 헤더 (로고 + 제목) ──────────────────────────────────────────────────────

/// 로그인 화면 상단 헤더 위젯
/// 앱 아이콘 + 이름 + 설명 표시
class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 앱 아이콘 역할 컨테이너
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
        const Text('HelpFlow', style: HelpFlowTextStyles.headline2),
        const SizedBox(height: HelpFlowSpacing.xs),
        Text(
          '헬프데스크 관리 시스템',
          style: HelpFlowTextStyles.body2.copyWith(
            color: HelpFlowColors.gray500,
          ),
        ),
      ],
    );
  }
}

// ── 이메일/비밀번호 폼 ─────────────────────────────────────────────────────

/// 로그인 입력 폼 위젯
/// 이메일 / 비밀번호 TextFormField 포함
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
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
              // 간단한 이메일 형식 검사
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
/// 연한 빨간 배경 + 에러 텍스트
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HelpFlowSpacing.lg,
        vertical: HelpFlowSpacing.sm,
      ),
      decoration: BoxDecoration(
        // 에러 컬러 10% 투명도 배경
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

// ── 로그인 버튼 ────────────────────────────────────────────────────────────

/// 로그인 버튼 위젯
/// 로딩 중에는 스피너 표시, 버튼 비활성화
class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      // 로딩 중이면 null 전달 → 버튼 비활성화
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
          : const Text('로그인'),
    );
  }
}

// ── 회원가입 링크 ──────────────────────────────────────────────────────────

/// 회원가입 화면 이동 링크 위젯
class _SignupLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('계정이 없으신가요?', style: HelpFlowTextStyles.body2),
        TextButton(
          // /signup 경로로 이동
          onPressed: () => context.go(AppRoutes.signup),
          child: const Text('회원가입'),
        ),
      ],
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: login_screen.dart
// 역할: 이메일/비밀번호 로그인 화면.
//       _LoginScreenState._handleLogin()으로 currentUserProvider.signIn() 호출.
//       로그인 성공 시 go_router redirect 콜백이 자동으로 /dashboard로 이동.
//       유효성 검사(이메일 형식, 비밀번호 6자 이상), 로딩 처리, 한글 에러 메시지 표시.
//       위젯 분리: _LoginHeader / _LoginForm / _ErrorMessage / _LoginButton / _SignupLink.
//       토스 스타일: 흰 배경(#FFFFFF), radius 12, 넓은 여백.
