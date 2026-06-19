import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    final authState = ref.watch(authControllerProvider);
    final hasError = authState.errorMessage != null && !authState.isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfacePink,
              AppColors.surface,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated Logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33F8C8DC),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.local_florist, size: 50, color: AppColors.brandDark),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Sakura Kanji',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.brandDark,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Học tiếng Nhật thật nhẹ nhàng',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            if (hasError) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  authState.errorMessage!,
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).getMe();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ] else ...[
              // Custom Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
              const SizedBox(height: 48),
            ],
          ],
        ),
      ),
    );
  }
}
