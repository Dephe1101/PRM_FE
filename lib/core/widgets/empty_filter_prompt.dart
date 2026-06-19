import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';

class EmptyFilterPrompt extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyFilterPrompt({
    super.key,
    this.title = 'Vui lòng chọn chủ đề',
    this.subtitle = 'Bạn cần chọn ít nhất 1 chủ đề để xem dữ liệu',
    this.icon = Icons.filter_alt_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.surfacePink,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.brandDark,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.brandDark.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
