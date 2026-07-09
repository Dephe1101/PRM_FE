import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/pagination_widget.dart';
import 'package:mobile/features/flashcard/controllers/progress_words_controller.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';

class ProgressWordsScreen extends ConsumerStatefulWidget {
  final String type; // 'mastered' | 'learning'
  final String? levelId;
  final String? topicId;
  final String title;

  const ProgressWordsScreen({
    super.key,
    required this.type,
    required this.title,
    this.levelId,
    this.topicId,
  });

  @override
  ConsumerState<ProgressWordsScreen> createState() =>
      _ProgressWordsScreenState();
}

class _ProgressWordsScreenState extends ConsumerState<ProgressWordsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(progressWordsControllerProvider.notifier)
          .load(
            type: widget.type,
            levelId: widget.levelId,
            topicId: widget.topicId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressWordsControllerProvider);
    final isMastered = widget.type == 'mastered';

    final accentColor = isMastered
        ? AppColors.accentMastered
        : AppColors.brandDark;
    final bgColor = isMastered
        ? AppColors.accentMasteredTrack
        : AppColors.surfacePink;

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
          widget.title,
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _buildBody(state, accentColor, bgColor),
    );
  }

  Widget _buildBody(ProgressWordsState state, Color accent, Color bg) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(progressWordsControllerProvider.notifier)
                    .goToPage(state.currentPage);
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final docs = state.data.docs;
    final totalPages = state.data.totalPages;

    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.type == 'mastered'
                  ? Icons.emoji_events_outlined
                  : Icons.book_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có từ vựng nào',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppColors.surface,
          child: Row(
            children: [
              Icon(
                widget.type == 'mastered' ? Icons.check_circle : Icons.book,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tổng: ${state.data.total} từ vựng',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Trang ${state.currentPage}/${totalPages > 0 ? totalPages : 1}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        // Word list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index];
              final word = item.word;
              return ProgressWordCard(
                word: word,
                flashcard: item,
                accent: accent,
                bg: bg,
                isMastered: widget.type == 'mastered',
              );
            },
          ),
        ),
        // Pagination
        if (totalPages > 1)
          Container(
            color: AppColors.surface,
            child: PaginationWidget(
              currentPage: state.currentPage,
              totalPages: totalPages,
              onPageChanged: (page) {
                ref
                    .read(progressWordsControllerProvider.notifier)
                    .goToPage(page);
              },
            ),
          ),
      ],
    );
  }
}

class ProgressWordCard extends StatelessWidget {
  final WordModel word;
  final FlashcardModel flashcard;
  final Color accent;
  final Color bg;
  final bool isMastered;

  const ProgressWordCard({
    super.key,
    required this.word,
    required this.flashcard,
    required this.accent,
    required this.bg,
    required this.isMastered,
  });

  @override
  Widget build(BuildContext context) {
    final displayWord = word.kanji.isNotEmpty ? word.kanji : word.hiragana;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: accent.withValues(alpha: 0.15), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMastered ? Icons.check_circle_outline : Icons.book_outlined,
                color: accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Word info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayWord,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      if (word.kanji.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          word.hiragana,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.meaning,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (word.romaji.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      word.romaji,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (word.example.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '例: ',
                            style: AppTextStyles.caption.copyWith(
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              word.example,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // SRS info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SrsBadge(
                  stage: flashcard.progress.srsStage,
                  isMastered: isMastered,
                  accent: accent,
                ),
                const SizedBox(height: 4),
                Text(
                  '✓${flashcard.progress.correctCount} ✗${flashcard.progress.wrongCount}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
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

class _SrsBadge extends StatelessWidget {
  final int stage;
  final bool isMastered;
  final Color accent;

  const _SrsBadge({
    required this.stage,
    required this.isMastered,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isMastered ? 'Thuộc' : 'Đang học',
        style: TextStyle(
          color: accent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
