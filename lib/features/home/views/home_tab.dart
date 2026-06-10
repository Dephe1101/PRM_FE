import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'widgets/level_filter_bubble.dart';
import 'widgets/streak_badge.dart';
import 'widgets/topic_card.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  String _activeLevel = 'N5';

  final List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final userName = user?.username ?? 'Guest';

    return SafeArea(
      child: Column(
        children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
                Text(
                  'Sakura Kanji',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.brandDark,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile') {
                      // Todo: Chuyển hướng sang màn hình Profile
                    } else if (value == 'logout') {
                      ref.read(authControllerProvider.notifier).logout();
                    }
                  },
                  offset: const Offset(0, 52),
                  elevation: 3,
                  shadowColor: const Color(0x22000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  color: AppColors.surface,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=11',
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.iconBackground,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: AppColors.brandDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Hồ sơ cá nhân',
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(
                        color: AppColors.surfacePink,
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              size: 18,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Đăng xuất',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Header: Greeting & Streak
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(userName, style: AppTextStyles.heading1),
                        ],
                      ),
                      const StreakBadge(streakCount: 12),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Level Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _levels.length,
                      itemBuilder: (context, index) {
                        final level = _levels[index];
                        return LevelFilterBubble(
                          text: level,
                          isActive: _activeLevel == level,
                          onTap: () {
                            setState(() {
                              _activeLevel = level;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mock Topic List
                  const TopicCard(
                    title: 'Family & People',
                    icon: Icons.family_restroom,
                    currentProgress: 24,
                    maxProgress: 40,
                  ),
                  const TopicCard(
                    title: 'Work & Office',
                    icon: Icons.work_outline,
                    currentProgress: 35,
                    maxProgress: 35, // Mastered
                  ),
                  const TopicCard(
                    title: 'Food & Dining',
                    icon: Icons.restaurant,
                    currentProgress: 0,
                    maxProgress: 35,
                  ),
                  const TopicCard(
                    title: 'Transportation',
                    icon: Icons.directions_bus_outlined,
                    currentProgress: 10,
                    maxProgress: 20,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
