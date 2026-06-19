import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/learning/controllers/topic_list_controller.dart';
import 'widgets/level_filter_bubble.dart';
import 'widgets/topic_card.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';

class StudyTab extends ConsumerStatefulWidget {
  const StudyTab({super.key});

  @override
  ConsumerState<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends ConsumerState<StudyTab> {
  @override
  Widget build(BuildContext context) {
    final topicListState = ref.watch(topicListControllerProvider);
    final activeLevelId = topicListState.selectedLevelId;

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
                  'Học Từ Vựng',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.brandDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.brandDark,
                  ),
                  tooltip: 'Tải lại',
                  onPressed: () {
                    ref
                        .read(topicListControllerProvider.notifier)
                        .fetchLevels();
                    if (activeLevelId != null) {
                      ref
                          .read(topicListControllerProvider.notifier)
                          .fetchTopics(activeLevelId);
                    }
                  },
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

                  // Level Filter
                  if (topicListState.error != null &&
                      topicListState.levels.isEmpty)
                    ErrorRetryWidget(
                      errorMessage: 'Lỗi tải dữ liệu: ${topicListState.error}',
                      onRetry: () => ref
                          .read(topicListControllerProvider.notifier)
                          .fetchLevels(),
                    )
                  else if (topicListState.levels.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topicListState.levels.length,
                        itemBuilder: (context, index) {
                          final level = topicListState.levels[index];
                          final isActive = activeLevelId == level.id;
                          // Tạo badge text
                          String badgeText = level.name.length >= 2
                              ? level.name.substring(0, 2).toUpperCase()
                              : level.name;
                          if (level.name.contains('N5')) badgeText = 'N5';
                          if (level.name.contains('N4')) badgeText = 'N4';
                          if (level.name.contains('N3')) badgeText = 'N3';
                          if (level.name.contains('N2')) badgeText = 'N2';
                          if (level.name.contains('N1')) badgeText = 'N1';

                          return LevelFilterBubble(
                            text: badgeText,
                            isActive: isActive,
                            onTap: () {
                              ref
                                  .read(topicListControllerProvider.notifier)
                                  .setLevel(level.id);
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),

                  // My Words Action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(RouteConstants.myWords),
                          icon: const Icon(Icons.bookmark, size: 20),
                          label: const Text('My Words'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandDark,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Topic List
                  if (activeLevelId == null)
                    const SizedBox.shrink()
                  else if (topicListState.error != null &&
                      topicListState.topics.isEmpty)
                    ErrorRetryWidget(
                      errorMessage: 'Lỗi tải topics: ${topicListState.error}',
                      onRetry: () => ref
                          .read(topicListControllerProvider.notifier)
                          .fetchTopics(activeLevelId),
                    )
                  else if (topicListState.topics.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'Chưa có chủ đề nào.',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: topicListState.topics.map((topic) {
                        return TopicCard(
                          title: topic.title,
                          icon: Icons.menu_book,
                          currentProgress: topic.masteredWords,
                          maxProgress: topic.totalWords,
                          status: topic.status ?? 'NOT_LEARNED',
                          onTap: () {
                            context.push(
                              RouteConstants.topicDetail.replaceFirst(
                                ':topicId',
                                topic.id,
                              ),
                            );
                          },
                        );
                      }).toList(),
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
