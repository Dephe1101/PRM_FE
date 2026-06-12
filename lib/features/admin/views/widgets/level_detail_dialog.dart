import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/admin/repositories/topic_repository.dart';
import 'package:mobile/core/widgets/primary_button.dart';

class LevelDetailDialog extends ConsumerStatefulWidget {
  final LevelModel level;

  const LevelDetailDialog({super.key, required this.level});

  @override
  ConsumerState<LevelDetailDialog> createState() => _LevelDetailDialogState();
}

class _LevelDetailDialogState extends ConsumerState<LevelDetailDialog> {
  late Future<List<TopicModel>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = ref
        .read(topicRepositoryProvider)
        .getTopicsByLevel(widget.level.id);
  }

  @override
  Widget build(BuildContext context) {
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
                      color: widget.level.isActive
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.surfacePink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.level.isActive ? 'Active' : 'Inactive',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.level.isActive
                            ? AppColors.accentMastered
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name
              Text(
                widget.level.name,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 36,
                  color: AppColors.brandDark,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 24),

              // Details
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.level.description.isNotEmpty) ...[
                      Text(
                        'Mô tả',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.level.description,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      'Thứ tự hiển thị',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.level.orderIndex.toString(),
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    FutureBuilder<List<TopicModel>>(
                      future: _topicsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.hasError) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lỗi tải danh sách chủ đề.',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _topicsFuture = ref
                                        .read(topicRepositoryProvider)
                                        .getTopicsByLevel(widget.level.id);
                                  });
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Thử lại'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.brandDark,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          );
                        }
                        final topics = snapshot.data ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Các Topic thuộc Level',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (topics.isEmpty)
                              Text(
                                'Chưa có topic nào.',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: topics.map((t) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          AppColors.surfacePink,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: AppColors.surfacePink,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      t.title,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.brandDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        );
                      },
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
