import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/features/flashcard/controllers/topic_flashcard_controller.dart';
import 'package:mobile/features/flashcard/controllers/review_controller.dart';
import 'package:mobile/features/flashcard/views/widgets/swipeable_card_stack.dart';

class DailyReviewScreen extends ConsumerStatefulWidget {
  const DailyReviewScreen({super.key});

  @override
  ConsumerState<DailyReviewScreen> createState() => _DailyReviewScreenState();
}

class _DailyReviewScreenState extends ConsumerState<DailyReviewScreen> {
  final GlobalKey<SwipeableCardStackState> _cardStackKey = GlobalKey<SwipeableCardStackState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewControllerProvider);
    // Dùng ref.listen thay vì ref.watch để giữ Provider sống mà KHÔNG làm rebuild lại UI
    ref.listen(batchFlashcardActionProvider, (_, __) {});

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
          'Daily Review',
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: state.when(
        data: (flashcards) {
          if (flashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: AppColors.success.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn đã hoàn thành\ntất cả bài ôn tập hôm nay!',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDark,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Quay về'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '${flashcards.length} thẻ cần ôn tập',
                    style: AppTextStyles.h3.copyWith(color: AppColors.brandDark),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SwipeableCardStack(
                      key: _cardStackKey,
                      flashcards: flashcards,
                      onPageChanged: (index) {},
                      onSwipe: (index, direction) {
                        final wordId = flashcards[index].word.id;
                        ref
                            .read(batchFlashcardActionProvider.notifier)
                            .recordSwipe(wordId, direction);
                      },
                      finishBuilder: (context) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 80, color: AppColors.success.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'Bạn đã hoàn thành\ntất cả thẻ ôn tập hôm nay!',
                                style: AppTextStyles.h3,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () async {
                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(child: SizedBox.shrink()),
                                  );
                                  
                                  final success = await ref
                                      .read(batchFlashcardActionProvider.notifier)
                                      .submitBatch();
                                      
                                  if (context.mounted) {
                                    Navigator.of(context).pop(); // dismiss loading
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Lưu kết quả ôn tập thành công!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      context.pop(); // Go back
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Có lỗi xảy ra khi lưu kết quả!'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandDark,
                                  foregroundColor: AppColors.surface,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Lưu kết quả & Hoàn thành', style: AppTextStyles.h3.copyWith(color: AppColors.surface)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0, top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.close,
                        color: AppColors.error,
                        onTap: () {
                          _cardStackKey.currentState?.triggerSwipeLeft();
                        },
                      ),
                      const SizedBox(width: 48),
                      _buildActionButton(
                        icon: Icons.check,
                        color: AppColors.success,
                        onTap: () {
                          _cardStackKey.currentState?.triggerSwipeRight();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (e, st) => Center(
          child: ErrorRetryWidget(
            errorMessage: 'Lỗi: $e',
            onRetry: () => ref.invalidate(reviewControllerProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
