import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';

class TopicCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int currentProgress;
  final int maxProgress;

  const TopicCard({
    super.key,
    required this.title,
    required this.icon,
    required this.currentProgress,
    required this.maxProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isMastered = currentProgress >= maxProgress && maxProgress > 0;
    final progressRatio = maxProgress == 0 ? 0.0 : currentProgress / maxProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.brandDark),
          ),
          const SizedBox(width: 16),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isMastered)
                      const Icon(Icons.check_circle_outline, color: AppColors.accentMastered, size: 20)
                    else
                      Text(
                        '$currentProgress/$maxProgress',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress Bar
                LinearProgressIndicator(
                  value: progressRatio,
                  backgroundColor: isMastered ? AppColors.accentMasteredTrack : AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMastered ? AppColors.accentMastered : AppColors.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
