import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/core/widgets/primary_button.dart';

class WordDetailDialog extends StatelessWidget {
  final WordModel word;

  const WordDetailDialog({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    String levelDisplay = word.levelName ?? word.levelId ?? 'No Level';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Tags
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      levelDisplay,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      word.topicName ?? 'No Topic',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentMastered,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Big Kanji / Hiragana
              if (word.kanji.isNotEmpty) ...[
                Text(
                  word.kanji,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 48,
                    color: AppColors.brandDark,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                word.hiragana,
                style: AppTextStyles.h3.copyWith(
                  color: word.kanji.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.brandDark,
                  fontSize: word.kanji.isNotEmpty ? 20 : 40,
                ),
                textAlign: TextAlign.center,
              ),

              if (word.romaji.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  word.romaji,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 24),

              // Meaning
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ý nghĩa',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.meaning,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Ví dụ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.example.isNotEmpty ? word.example : 'Không có',
                      style: AppTextStyles.bodyText.copyWith(
                        fontStyle: word.example.isNotEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: word.example.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Audio URL',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.audioUrl.isNotEmpty ? word.audioUrl : 'Không có',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: word.audioUrl.isNotEmpty
                            ? AppColors.brandDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Đóng',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
