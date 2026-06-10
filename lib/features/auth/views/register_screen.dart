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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && ref.read(authControllerProvider).isLoggedIn) {
      context.go(RouteConstants.home); // Chuyển hướng sau khi thành công
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }

      // Thông báo Đăng ký thành công
      if (next.isLoggedIn && previous?.isLoggedIn != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Chào mừng bạn đến với Sakura Kanji.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // Icon Sakura Pink
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary, 
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_florist, size: 32, color: AppColors.brandDark),
          ),
          const SizedBox(height: 24),
          Text(
            'Bắt đầu hành trình\nKanji',
            style: AppTextStyles.heading1.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sakura Kanji - Học tiếng Nhật thật nhẹ nhàng',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Form Box
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
                    label: 'Họ và tên',
                    hint: 'Nguyễn Văn A',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: AuthValidators.username,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Email',
                    hint: 'email@example.com',
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
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Đăng ký',
                    icon: Icons.arrow_forward,
                    isLoading: authState.isLoading,
                    onPressed: _onRegister,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Hoặc tiếp tục với',
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
                        icon: const Icon(Icons.apple, color: AppColors.textLight, size: 20),
                        isFilled: true,
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
                'Đã có tài khoản? ',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => context.go(RouteConstants.login),
                child: Text(
                  'Đăng nhập',
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
