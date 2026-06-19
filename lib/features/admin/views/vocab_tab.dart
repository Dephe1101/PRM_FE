import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/pagination_widget.dart';
import 'package:mobile/features/admin/controllers/level_controller.dart';
import 'package:mobile/features/admin/controllers/topic_controller.dart';
import 'package:mobile/features/admin/views/topics_tab.dart'; // Add this for selectedLevelFilterProvider
import 'package:mobile/features/admin/controllers/word_controller.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/features/admin/views/widgets/word_crud_dialog.dart';
import 'package:mobile/features/admin/views/widgets/word_detail_dialog.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';

import 'package:mobile/core/utils/debouncer.dart';

class VocabTab extends ConsumerStatefulWidget {
  const VocabTab({super.key});

  @override
  ConsumerState<VocabTab> createState() => _VocabTabState();
}

class _VocabTabState extends ConsumerState<VocabTab> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _debouncer.run(() {
      ref.read(wordFilterProvider.notifier).setSearch(query.trim());
      ref.invalidate(wordControllerProvider);
    });
  }

  void _showCrudDialog(BuildContext context, {WordModel? word}) {
    final topicsState = ref.read(topicControllerProvider);
    final levelsState = ref.read(levelControllerProvider);
    final filterState = ref.read(wordFilterProvider);

    topicsState.whenData((topics) {
      levelsState.whenData((levels) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WordCrudDialog(
            initialData: word,
            topics: topics,
            levels: levels,
            defaultTopicId: filterState.topicId,
            onSubmit: (data) async {
              if (word == null) {
                await ref
                    .read(wordControllerProvider.notifier)
                    .createWord(data);
              } else {
                await ref
                    .read(wordControllerProvider.notifier)
                    .updateWord(word.id, data);
              }
            },
          ),
        );
      });
    });
  }

  void _confirmDelete(BuildContext context, WordModel word) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa từ vựng "${word.hiragana}"?'),
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
                    .read(wordControllerProvider.notifier)
                    .deleteWord(word.id);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Xóa từ vựng thành công'),
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
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelsState = ref.watch(levelControllerProvider);
    final topicsState = ref.watch(topicControllerProvider);
    final wordsState = ref.watch(wordControllerProvider);
    final filterState = ref.watch(wordFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'words_fab',
        onPressed: () => _showCrudDialog(context),
        backgroundColor: AppColors.brandDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.surface, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Text('Quản lý Từ vựng', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Quản lý danh sách từ vựng trong hệ thống.',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search Kanji, Romaji, ...',
                      hintStyle: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: levelsState.maybeWhen(
                  data: (levels) => DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey(filterState.levelId),
                      initialValue: filterState.levelId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Lọc theo Level',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Levels'),
                        ),
                        ...levels.map(
                          (level) => DropdownMenuItem(
                            value: level.id,
                            child: Text(
                              level.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref
                            .read(selectedLevelFilterProvider.notifier)
                            .setFilter(value);
                        ref.read(wordFilterProvider.notifier).setLevel(value);
                        ref.invalidate(topicControllerProvider);
                        ref.invalidate(wordControllerProvider);
                      },
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: topicsState.maybeWhen(
                  data: (topics) => DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey(filterState.topicId),
                      initialValue: filterState.topicId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Lọc theo Topic',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Topics'),
                        ),
                        ...topics.map(
                          (topic) => DropdownMenuItem(
                            value: topic.id,
                            child: Text(
                              topic.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(wordFilterProvider.notifier).setTopic(value);
                        ref.invalidate(wordControllerProvider);
                      },
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Words List
          ...wordsState.when(
            data: (paginatedResponse) {
              final words = paginatedResponse.docs;
              if (words.isEmpty) {
                return [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Không có từ vựng nào thỏa mãn điều kiện lọc.',
                      ),
                    ),
                  ),
                ];
              }

              final List<Widget> widgets = [];
              for (final word in words) {
                widgets.add(_buildKanjiCard(context, word));
                widgets.add(const SizedBox(height: 12));
              }

              // Pagination Widget
              widgets.add(
                PaginationWidget(
                  currentPage: paginatedResponse.page,
                  totalPages: paginatedResponse.totalPages,
                  onPageChanged: (page) {
                    ref.read(wordFilterProvider.notifier).setPage(page);
                    ref.invalidate(wordControllerProvider);
                  },
                ),
              );

              widgets.add(const SizedBox(height: 80)); // Padding for FAB
              return widgets;
            },
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [
              ErrorRetryWidget(
                errorMessage: 'Lỗi tải từ vựng: $e',
                onRetry: () => ref.invalidate(wordControllerProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiCard(BuildContext context, WordModel word) {
    String levelDisplay = word.levelName ?? word.levelId ?? 'No Level';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => WordDetailDialog(word: word),
        );
      },
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Kanji Box
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word.kanji.isNotEmpty ? word.kanji : word.hiragana,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 36,
                    color: AppColors.brandDark,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(word.hiragana, style: AppTextStyles.h3),
                      if (word.romaji.isNotEmpty)
                        Text(
                          word.romaji,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.meaning,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfacePink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            levelDisplay,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(
                              alpha: 0.2,
                            ), // Light Green
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            word.topicName ?? 'No Topic',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentMastered,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') {
                  _showCrudDialog(context, word: word);
                } else if (value == 'delete') {
                  _confirmDelete(context, word);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.brandDark, size: 20),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
