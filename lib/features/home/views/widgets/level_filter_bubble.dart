import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';

class LevelFilterBubble extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const LevelFilterBubble({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.iconBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.brandDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
