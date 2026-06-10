import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/validators/auth_validators.dart';
import 'package:mobile/core/widgets/custom_text_field.dart';
import 'package:mobile/core/widgets/primary_button.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'widgets/auth_background.dart';
import 'widgets/social_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && ref.read(authControllerProvider).isLoggedIn) {
      context.go(RouteConstants.home); // Chuyển hướng nếu thành công
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Xử lý báo lỗi bằng SnackBar
    ref.listen(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }

      // Thông báo Đăng nhập thành công
      if (next.isLoggedIn && previous?.isLoggedIn != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công! Chào mừng bạn.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_florist, size: 40, color: AppColors.brandDark),
          ),
          const SizedBox(height: 24),
          Text(
            'Chào mừng trở lại',
            style: AppTextStyles.heading1.copyWith(color: AppColors.brandDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Hành trình học tiếng Nhật của bạn tiếp tục',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Form Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'Email',
                    hint: 'ban@vidu.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Mật khẩu',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator: AuthValidators.password,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Quên mật khẩu?',
                        style: AppTextStyles.caption.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Đăng nhập',
                    icon: Icons.arrow_forward,
                    isLoading: authState.isLoading,
                    onPressed: _onLogin,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'hoặc',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SocialButton(
                        text: 'Google',
                        icon: const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      SocialButton(
                        text: 'Apple',
                        icon: const Icon(Icons.apple, color: AppColors.textPrimary, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chưa có tài khoản? ',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => context.push(RouteConstants.register),
                child: Text(
                  'Đăng ký ngay',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
