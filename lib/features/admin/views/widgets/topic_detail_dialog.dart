import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/core/models/paginated_response.dart';
import 'package:mobile/features/admin/repositories/word_repository.dart';
import 'package:mobile/core/widgets/primary_button.dart';

class TopicDetailDialog extends ConsumerStatefulWidget {
  final TopicModel topic;

  const TopicDetailDialog({super.key, required this.topic});

  @override
  ConsumerState<TopicDetailDialog> createState() => _TopicDetailDialogState();
}

class _TopicDetailDialogState extends ConsumerState<TopicDetailDialog> {
  late Future<PaginatedResponse<WordModel>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _wordsFuture = ref
        .read(wordRepositoryProvider)
        .getAllWords(topicId: widget.topic.id, limit: 100);
  }

  @override
  Widget build(BuildContext context) {
    String levelDisplay = widget.topic.levelName ?? widget.topic.levelId;
    if (levelDisplay.isEmpty) levelDisplay = 'No Level';

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
                ],
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                widget.topic.title,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 32,
                  color: AppColors.brandDark,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 24),

              // Details
              FutureBuilder<PaginatedResponse<WordModel>>(
                future: _wordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'Lỗi khi tải từ vựng.',
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _wordsFuture = ref
                                    .read(wordRepositoryProvider)
                                    .getAllWords(
                                      topicId: widget.topic.id,
                                      limit: 100,
                                    );
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Thử lại'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.brandDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final totalDocs = snapshot.data?.totalDocs ?? 0;
                  final words = snapshot.data?.docs ?? [];

                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng số từ vựng',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalDocs từ',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentMastered,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Thứ tự hiển thị',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.topic.orderIndex.toString(),
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Words Table
                        if (totalDocs > 0) ...[
                          Text(
                            'Danh sách từ vựng',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    AppColors.tertiary,
                                  ),
                                  columnSpacing: 24,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Kanji',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Hiragana',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Ý nghĩa',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Ví dụ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Audio URL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: words.map((w) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(w.kanji)),
                                        DataCell(Text(w.hiragana)),
                                        DataCell(Text(w.meaning)),
                                        DataCell(
                                          Text(
                                            w.example.isNotEmpty
                                                ? w.example
                                                : '-',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            w.audioUrl.isNotEmpty
                                                ? w.audioUrl
                                                : '-',
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

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
