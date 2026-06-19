import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';

class FlashcardWidget extends ConsumerStatefulWidget {
  final FlashcardModel flashcard;
  final ValueChanged<bool>? onFlip;

  const FlashcardWidget({super.key, required this.flashcard, this.onFlip});

  @override
  ConsumerState<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends ConsumerState<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.flashcard.progress.isBookmarked;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        widget.onFlip?.call(false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcard.word.id != widget.flashcard.word.id) {
      _isFront = true;
      _controller.value = 0;
      _isBookmarked = widget.flashcard.progress.isBookmarked;
    }
  }

  Future<void> _toggleBookmark() async {
    // Optimistic UI update
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    try {
      final repository = ref.read(flashcardRepositoryProvider);
      final result = await repository.toggleBookmark(widget.flashcard.word.id);
      if (!mounted) return;
      setState(() {
        _isBookmarked = result;
      });
    } catch (e) {
      if (!mounted) return;
      // Revert on failure
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu từ vựng')));
    }
  }

  void _flipCard() {
    widget.onFlip?.call(true);
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isBack = angle > pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildCardContainer(Widget child) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000), // Slightly darker shadow
              blurRadius: 20, // Softer blur
              offset: Offset(0, 8), // Larger offset
            ),
          ],
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
            Padding(padding: const EdgeInsets.all(24), child: child),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked
                      ? AppColors.warning
                      : AppColors.textSecondary,
                  size: 32,
                ),
                onPressed: _toggleBookmark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront() {
    final word = widget.flashcard.word;
    final displayChar = word.kanji.isNotEmpty ? word.kanji : word.hiragana;

    return _buildCardContainer(
      Center(
        child: Text(
          displayChar,
          style: AppTextStyles.heading1.copyWith(
            fontSize: 80,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBack() {
    final word = widget.flashcard.word;
    final progress = widget.flashcard.progress;
    final displayKanji = word.kanji.isNotEmpty ? word.kanji : word.hiragana;

    String nextReviewDateStr = 'Chưa học';
    if (progress.nextReviewAt != null) {
      nextReviewDateStr = DateFormat(
        'MMM dd, yyyy HH:mm',
      ).format(progress.nextReviewAt!.toLocal());
    }

    return _buildCardContainer(
      Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center contents
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            word.meaning,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${word.hiragana} ${word.romaji}',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            displayKanji,
            style: AppTextStyles.heading1.copyWith(
              fontSize: 80,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),
          if (word.example.isNotEmpty) ...[
            Text(
              word.example,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'Không có ví dụ.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentMastered.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AppColors.brandDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stage ${progress.srsStage}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                nextReviewDateStr,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
