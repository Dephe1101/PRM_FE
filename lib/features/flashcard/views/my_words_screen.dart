import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/features/flashcard/controllers/bookmark_controller.dart';

import 'package:mobile/features/flashcard/controllers/bookmark_filter_controller.dart';

class MyWordsScreen extends ConsumerWidget {
  const MyWordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkControllerProvider);
    final filterState = ref.watch(bookmarkFilterProvider);
    final filterNotifier = ref.read(bookmarkFilterProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brandDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Words',
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filterState.selectedLevelId,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                        dropdownColor: AppColors.surface,
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả Levels'),
                          ),
                          ...filterState.levels.map((level) => DropdownMenuItem(
                            value: level.id,
                            child: Text(level.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          )),
                        ],
                        onChanged: filterNotifier.selectLevel,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: filterState.isLoading
                        ? const SizedBox(
                            height: 48,
                            child: Center(child: SizedBox.shrink()),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: filterState.selectedTopicId,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.textSecondary,
                              ),
                              dropdownColor: AppColors.surface,
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Tất cả Topics'),
                                ),
                                ...filterState.topics.map((topic) => DropdownMenuItem(
                                  value: topic.id,
                                  child: Text(topic.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                )),
                              ],
                              onChanged: filterState.selectedLevelId == null
                                  ? null
                                  : filterNotifier.selectTopic,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
        data: (flashcards) {
          if (flashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa lưu từ vựng nào.',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: flashcards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final flashcard = flashcards[index];
              final word = flashcard.word;
              final progress = flashcard.progress;

              final displayChar = word.kanji.isNotEmpty ? word.kanji : word.hiragana;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
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
                    // Kanji Box
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        displayChar,
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 32,
                          color: AppColors.brandDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.hiragana,
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            word.meaning,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfacePink,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  word.levelName ?? 'N/A',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action
                    IconButton(
                      icon: const Icon(Icons.bookmark, color: AppColors.warning),
                      onPressed: () {
                        ref.read(bookmarkControllerProvider.notifier).toggleBookmark(word.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Center(
          child: ErrorRetryWidget(
            errorMessage: 'Lỗi: $e',
            onRetry: () => ref.invalidate(bookmarkControllerProvider),
          ),
        ),
        ),
      ),
          ],
        ),
      floatingActionButton: state.maybeWhen(
        data: (flashcards) {
          if (flashcards.isEmpty) return null;
          return FloatingActionButton.extended(
            onPressed: () {
              context.push('/flashcard/bookmarks?topicName=Từ đã lưu');
            },
            backgroundColor: AppColors.brandDark,
            icon: const Icon(Icons.style, color: Colors.white),
            label: Text(
              'Học Flashcard',
              style: AppTextStyles.buttonText.copyWith(color: Colors.white),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}
