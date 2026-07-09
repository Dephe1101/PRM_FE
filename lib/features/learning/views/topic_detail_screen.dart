import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/features/learning/controllers/topic_detail_controller.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';

class _StudyTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final _studyTabProvider = NotifierProvider.autoDispose<_StudyTabNotifier, int>(() {
  return _StudyTabNotifier();
});

class TopicDetailScreen extends ConsumerWidget {
  final String topicId;

  const TopicDetailScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(topicDetailControllerProvider(topicId));
    final bookmarkedState = ref.watch(topicBookmarkedFlashcardsProvider(topicId));
    final selectedTab = ref.watch(_studyTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brandDark),
          onPressed: () => context.pop(),
        ),
        title: state.when(
          data: (data) => Text(
            data['data']['title'] ?? 'Chi tiết chủ đề',
            style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
          ),
          loading: () => const Text('Đang tải...'),
          error: (_, _) => const Text('Lỗi'),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: state.when(
        data: (response) {
          final allWords = response['data']['words'] as List<dynamic>? ?? [];
          final topicName = response['data']['title'] ?? 'Flashcard';

          return Column(
            children: [
              // Segmented Control (Tabs)
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        context,
                        title: 'Toàn bộ',
                        isSelected: selectedTab == 0,
                        onTap: () => ref.read(_studyTabProvider.notifier).setTab(0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTabButton(
                        context,
                        title: 'Đã lưu',
                        isSelected: selectedTab == 1,
                        onTap: () => ref.read(_studyTabProvider.notifier).setTab(1),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selectedTab == 0
                    ? _buildAllWordsList(allWords)
                    : bookmarkedState.when(
                        data: (flashcards) => _buildBookmarkedWordsList(flashcards),
                        loading: () => const Center(child: SizedBox.shrink()),
                        error: (e, st) => Center(
                          child: ErrorRetryWidget(
                            errorMessage: 'Lỗi tải từ đã lưu: $e',
                            onRetry: () => ref.invalidate(topicBookmarkedFlashcardsProvider(topicId)),
                          ),
                        ),
                      ),
              ),
              // Nút Học Flashcard to bự ở dưới cùng
              Builder(
                builder: (context) {
                  final bool hasWordsToStudy = selectedTab == 0
                      ? allWords.isNotEmpty
                      : bookmarkedState.maybeWhen(
                          data: (flashcards) => flashcards.isNotEmpty,
                          orElse: () => false,
                        );

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: hasWordsToStudy
                          ? () {
                              // Chuyển hướng sang màn hình Flashcard
                              if (selectedTab == 1) {
                                // Truyền thêm param cho bookmarks
                                context.push(
                                  Uri(
                                    path: '/flashcard/bookmarks',
                                    queryParameters: {'topicName': topicName, 'filterTopicId': topicId},
                                  ).toString(),
                                );
                              } else {
                                context.push(
                                  Uri(
                                    path: RouteConstants.flashcard.replaceFirst(':topicId', topicId),
                                    queryParameters: {'topicName': topicName},
                                  ).toString(),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandDark,
                        foregroundColor: AppColors.surface,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.textSecondary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        selectedTab == 0 ? 'Bắt đầu học Flashcard' : 'Ôn tập từ đã lưu',
                        style: AppTextStyles.h3.copyWith(
                          color: hasWordsToStudy ? AppColors.surface : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Center(
          child: ErrorRetryWidget(
            errorMessage: 'Lỗi tải chi tiết: $e',
            onRetry: () => ref.invalidate(topicDetailControllerProvider(topicId)),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, {required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandDark : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.brandDark : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAllWordsList(List<dynamic> words) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          'Chủ đề này chưa có từ vựng nào.',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: words.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = words[index];
        return _buildWordItem(
          kanji: word['kanji'],
          hiragana: word['hiragana'],
          meaning: word['meaning'],
        );
      },
    );
  }

  Widget _buildBookmarkedWordsList(List<FlashcardModel> flashcards) {
    if (flashcards.isEmpty) {
      return Center(
        child: Text(
          'Chưa có từ nào được lưu trong chủ đề này.',
          style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: flashcards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = flashcards[index].word;
        return _buildWordItem(
          kanji: word.kanji,
          hiragana: word.hiragana,
          meaning: word.meaning,
        );
      },
    );
  }

  Widget _buildWordItem({String? kanji, String? hiragana, String? meaning}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kanji?.isNotEmpty == true ? kanji! : (hiragana ?? ''),
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  hiragana ?? '',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meaning ?? '',
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
