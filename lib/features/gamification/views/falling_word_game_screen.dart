import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/gamification/controllers/falling_word_controller.dart';
import 'package:mobile/features/gamification/models/game_session_model.dart';

class FallingWordGameScreen extends ConsumerStatefulWidget {
  final List<String> topicIds;

  const FallingWordGameScreen({super.key, required this.topicIds});

  @override
  ConsumerState<FallingWordGameScreen> createState() =>
      _FallingWordGameScreenState();
}

class _FallingWordGameScreenState extends ConsumerState<FallingWordGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Tốc độ rơi mặc định
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Rơi chạm đáy
        final state = ref.read(fallingWordControllerProvider);
        if (state.session != null && !state.isGameFinished) {
          final currentWord = state.session!.words[state.currentIndex];
          ref
              .read(fallingWordControllerProvider.notifier)
              .handleTimeout(currentWord.wordId);
        }
      }
    });

    // Bắt đầu gọi API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(fallingWordControllerProvider);
      ref
          .read(fallingWordControllerProvider.notifier)
          .startGame(widget.topicIds);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleOptionSelected(
    GameOptionModel option,
    GameWordModel currentWord,
  ) {
    ref
        .read(fallingWordControllerProvider.notifier)
        .handleAnswer(option.isCorrect, currentWord.wordId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fallingWordControllerProvider);

    // Chuyển trang Game Result nếu game xong
    ref.listen<FallingWordState>(fallingWordControllerProvider, (
      previous,
      next,
    ) {
      if (next.isGameFinished && next.submitResult != null) {
        // Hiển thị dialog kết thúc
        _showGameOverDialog(next.score, next.submitResult);
      }

      // Xử lý báo lỗi bằng SnackBar nếu có lỗi phát sinh sau khi vào game
      if (previous?.error == null &&
          next.error != null &&
          next.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
        // Nếu lỗi xảy ra khi đang submit thì back ra ngoài
        if (next.isGameFinished) {
          context.pop();
        }
      }

      // Nếu currentIndex thay đổi (chuyển sang từ mới) -> reset animation
      if (previous?.currentIndex != next.currentIndex && !next.isGameFinished) {
        _controller.reset();
        _controller.forward();
      }
    });

    if (state.isLoading && state.session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const SizedBox.shrink(),
      );
    }

    if (state.error != null && state.session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lỗi: ${state.error}',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.session == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    // Nếu vừa mới load xong API mà chưa start animation
    if (_previousIndex == -1 && !state.isGameFinished) {
      _previousIndex = 0;
      _controller.forward();
    }

    GameWordModel? currentWord;
    if (!state.isGameFinished &&
        state.currentIndex < state.session!.totalWords) {
      currentWord = state.session!.words[state.currentIndex];
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Falling Word',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Stats
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Điểm: ${state.score}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.brandDark.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Combo: ${state.currentCombo}',
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LinearProgressIndicator(
                value: state.session!.totalWords > 0
                    ? state.currentIndex / state.session!.totalWords
                    : 0,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.brandDark,
                ),
              ),
            ),

            // Game Area
            Expanded(
              child: state.isGameFinished
                  ? Center(
                      child: state.isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Đang lưu kết quả...',
                                  style: AppTextStyles.bodyText,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Ranh giới đáy
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                color: AppColors.error.withValues(alpha: 0.5),
                              ),
                            ),

                            // Falling Word
                            if (!state.isGameFinished && currentWord != null)
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final topPosition =
                                      _controller.value *
                                      (constraints.maxHeight - 80);
                                  return Positioned(
                                    top: topPosition,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentWord!.kanji.isNotEmpty
                                                  ? currentWord.kanji
                                                  : (currentWord.hiragana ??
                                                        ''),
                                              style: AppTextStyles.h1.copyWith(
                                                fontSize: 40,
                                              ),
                                            ),
                                            if (currentWord.kanji.isNotEmpty &&
                                                currentWord.hiragana != null)
                                              Text(
                                                currentWord.hiragana!,
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
            ),

            // Options Area
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child:
                  currentWord == null ||
                      currentWord.options == null ||
                      currentWord.options!.isEmpty
                  ? const SizedBox(height: 150)
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildOptionButton(
                                currentWord.options![0],
                                currentWord,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildOptionButton(
                                currentWord.options![1],
                                currentWord,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildOptionButton(
                                currentWord.options![2],
                                currentWord,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildOptionButton(
                                currentWord.options![3],
                                currentWord,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(GameOptionModel option, GameWordModel currentWord) {
    return InkWell(
      onTap: () => _handleOptionSelected(option, currentWord),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          option.text,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _showGameOverDialog(int score, Map<String, dynamic>? submitResult) {
    int coins = submitResult?['rewards']?['coinsEarned'] ?? 0;
    int xp = submitResult?['rewards']?['xpEarned'] ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Game Over',
            style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Điểm của bạn: $score', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 32,
                      ),
                      Text('+$coins', style: AppTextStyles.bodyText),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.star, color: Colors.blue, size: 32),
                      Text('+$xp', style: AppTextStyles.bodyText),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                  context.pop(); // Quay lại màn chọn topic
                },
                child: Text(
                  'Hoàn thành',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
