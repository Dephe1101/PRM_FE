import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';

class TopicCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int currentProgress;
  final int maxProgress;
  final String status;
  final VoidCallback? onTap;

  const TopicCard({
    super.key,
    required this.title,
    required this.icon,
    required this.currentProgress,
    required this.maxProgress,
    required this.status,
    this.onTap,
  });

  Widget _buildStatusBadge() {
    String text;
    Color color;
    Color bgColor;

    if (status == 'MASTERED') {
      text = 'Đã thuộc';
      color = AppColors.accentMastered;
      bgColor = AppColors.accentMasteredTrack;
    } else if (status == 'LOCKED') {
      text = 'Đã khóa';
      color = AppColors.textSecondary;
      bgColor = AppColors.iconBackground;
    } else if (status == 'LEARNING') {
      text = 'Đang học';
      color = AppColors.brandDark;
      bgColor = AppColors.surfacePink;
    } else {
      text = 'Chưa học';
      color = AppColors.textSecondary;
      bgColor = AppColors.iconBackground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMastered = status == 'MASTERED' || (currentProgress >= maxProgress && maxProgress > 0);
    final isLocked = status == 'LOCKED';
    final progressRatio = maxProgress == 0
        ? 0.0
        : currentProgress / maxProgress;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.surface.withValues(alpha: 0.6) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLocked ? AppColors.border : AppColors.iconBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isLocked ? Icons.lock_outline : icon, 
                color: isLocked ? AppColors.textSecondary : AppColors.brandDark
              ),
            ),
            const SizedBox(width: 16),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.bodyText.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            _buildStatusBadge(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '$currentProgress/$maxProgress',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  if (!isLocked)
                    LinearProgressIndicator(
                      value: progressRatio,
                      backgroundColor: isMastered
                          ? AppColors.accentMasteredTrack
                          : AppColors.border,
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
      ),
    );
  }
}
