import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/admin/controllers/level_controller.dart';
import 'package:mobile/features/admin/controllers/topic_controller.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/features/admin/views/widgets/topic_crud_dialog.dart';
import 'package:mobile/features/admin/views/widgets/topic_import_dialog.dart';
import 'package:mobile/features/admin/views/widgets/topic_detail_dialog.dart';
import 'package:mobile/core/services/excel_service.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class SelectedLevelFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? levelId) {
    state = levelId;
  }
}

final selectedLevelFilterProvider =
    NotifierProvider<SelectedLevelFilterNotifier, String?>(() {
      return SelectedLevelFilterNotifier();
    });

class TopicsTab extends ConsumerWidget {
  const TopicsTab({super.key});

  void _showCrudDialog(
    BuildContext context,
    WidgetRef ref, {
    TopicModel? topic,
  }) {
    final levelsState = ref.read(levelControllerProvider);
    final selectedLevelId = ref.read(selectedLevelFilterProvider);

    levelsState.whenData((levels) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TopicCrudDialog(
          initialData: topic,
          selectedLevelId: selectedLevelId,
          levels: levels,
          onSubmit: (data) async {
            if (topic == null) {
              await ref
                  .read(topicControllerProvider.notifier)
                  .createTopic(
                    levelId: data['levelId'],
                    title: data['title'],
                    orderIndex: data['orderIndex'],
                  );
            } else {
              await ref
                  .read(topicControllerProvider.notifier)
                  .updateTopic(
                    id: topic.id,
                    title: data['title'],
                    orderIndex: data['orderIndex'],
                  );
            }
          },
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TopicModel topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa chủ đề "${topic.title}"?\nHành động này cũng sẽ xóa tất cả các từ vựng bên trong nó.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(topicControllerProvider.notifier)
                    .deleteTopic(topic.id);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Xóa chủ đề thành công'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                final errorMessage = e is AppException
                    ? e.message
                    : 'Đã xảy ra lỗi không xác định';
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopicDetailDialog(BuildContext context, TopicModel topic) {
    showDialog(
      context: context,
      builder: (context) => TopicDetailDialog(topic: topic),
    );
  }

  void _showGlobalImportDialog(BuildContext context, WidgetRef ref) {
    final levelsState = ref.read(levelControllerProvider);
    final selectedLevelId = ref.read(selectedLevelFilterProvider);
    final topics = ref.read(topicControllerProvider).value;

    levelsState.whenData((levels) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TopicImportDialog(
          levels: levels,
          allTopics: topics,
          initialLevelId: selectedLevelId,
          onImport:
              ({
                topicId,
                required levelId,
                required title,
                required words,
              }) async {
                await ref
                    .read(topicControllerProvider.notifier)
                    .importTopic(
                      topicId: topicId ?? '',
                      levelId: levelId,
                      title: title,
                      words: words,
                    );
              },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsState = ref.watch(levelControllerProvider);
    final selectedLevelId = ref.watch(selectedLevelFilterProvider);
    final topicsState = ref.watch(topicControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: AppColors.brandDark,
        foregroundColor: AppColors.surface,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add, color: AppColors.brandDark),
            backgroundColor: AppColors.surface,
            label: 'Thêm Topic mới',
            labelStyle: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
            ),
            onTap: () => _showCrudDialog(context, ref),
          ),
          SpeedDialChild(
            child: const Icon(Icons.upload_file, color: AppColors.brandDark),
            backgroundColor: AppColors.surface,
            label: 'Import Excel',
            labelStyle: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
            ),
            onTap: () => _showGlobalImportDialog(context, ref),
          ),
          SpeedDialChild(
            child: const Icon(Icons.download, color: AppColors.brandDark),
            backgroundColor: AppColors.surface,
            label: 'Tải File Mẫu',
            labelStyle: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
            ),
            onTap: () async {
              final path = await ExcelService.downloadTemplate();
              if (context.mounted) {
                if (path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã lưu file mẫu tại:\n$path'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lỗi khi lưu file mẫu.'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quản lý Chủ đề', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý các chủ đề học và tiến độ chung.',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(
                  label: 'All Levels',
                  isActive: selectedLevelId == null,
                  onTap: () {
                    ref
                        .read(selectedLevelFilterProvider.notifier)
                        .setFilter(null);
                    ref.invalidate(topicControllerProvider);
                  },
                ),
                ...levelsState.maybeWhen(
                  data: (levels) => levels
                      .map(
                        (level) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _buildChip(
                            label: level.name,
                            isActive: selectedLevelId == level.id,
                            onTap: () {
                              ref
                                  .read(selectedLevelFilterProvider.notifier)
                                  .setFilter(level.id);
                              ref.invalidate(topicControllerProvider);
                            },
                          ),
                        ),
                      )
                      .toList(),
                  orElse: () => [],
                ),
              ],
            ),
          ),
          // Topics List
          ...topicsState.when(
            data: (topics) {
              if (topics.isEmpty) {
                return [const Center(child: Text('No topics found'))];
              }

              // Group topics by levelId
              final groupedTopics = <String, List<TopicModel>>{};
              for (final t in topics) {
                groupedTopics.putIfAbsent(t.levelId, () => []).add(t);
              }

              final List<Widget> widgets = [];
              groupedTopics.forEach((levelId, levelTopics) {
                // Get level name
                String levelName = 'Unknown Level';
                levelsState.maybeWhen(
                  data: (levels) {
                    try {
                      levelName = levels
                          .firstWhere((l) => l.id == levelId)
                          .name;
                    } catch (_) {
                      // fallback to populated levelName if available
                      levelName =
                          levelTopics.first.levelName ?? 'Unknown Level';
                    }
                  },
                  orElse: () {},
                );

                widgets.add(const SizedBox(height: 32));
                widgets.add(_buildCategoryHeader(levelName));
                widgets.add(const SizedBox(height: 16));

                for (final topic in levelTopics) {
                  widgets.add(_buildTopicCard(context, ref, topic));
                  widgets.add(const SizedBox(height: 16));
                }
              });

              widgets.add(const SizedBox(height: 80)); // Padding for FAB
              return widgets;
            },
            loading: () => [const SizedBox.shrink()],
            error: (e, _) => [
              ErrorRetryWidget(
                errorMessage: 'Lỗi tải chủ đề: $e',
                onRetry: () => ref.invalidate(topicControllerProvider),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.surfacePink
              : AppColors.border.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyText.copyWith(
            color: isActive ? AppColors.brandDark : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: AppTextStyles.h3.copyWith(color: AppColors.brandDark),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    WidgetRef ref,
    TopicModel topic,
  ) {
    return InkWell(
      onTap: () => _showTopicDetailDialog(context, topic),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surfacePink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.book_outlined,
                    color: AppColors.brandDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.title, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Topic #${topic.orderIndex}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showCrudDialog(context, ref, topic: topic);
                    } else if (value == 'delete') {
                      _confirmDelete(context, ref, topic);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: AppColors.brandDark,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Global Mastery',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.brandDark,
                  ),
                ),
                Text(
                  '0%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.brandDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: AppColors.tertiary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.brandDark,
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}
