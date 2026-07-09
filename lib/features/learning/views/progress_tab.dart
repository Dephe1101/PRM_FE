import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/features/flashcard/controllers/progress_controller.dart';
import 'package:mobile/features/flashcard/controllers/progress_filter_controller.dart';

class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(progressFilterControllerProvider);
    final filterNotifier = ref.read(progressFilterControllerProvider.notifier);
    final state = ref.watch(progressControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Thống kê học tập',
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.brandDark),
            onPressed: () {
              filterNotifier.initFilters();
              ref.read(progressControllerProvider.notifier).refreshProgress();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
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
                  child: _buildDropdown(
                    value: filterState.selectedLevelId,
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('Tất cả Levels'),
                      ),
                      ...filterState.levels.map(
                        (l) =>
                            DropdownMenuItem(value: l.id, child: Text(l.name)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        filterNotifier.setLevel(val);
                        ref
                            .read(progressControllerProvider.notifier)
                            .refreshProgress();
                      }
                    },
                    isLoading: filterState.isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: filterState.selectedTopicId,
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('Tất cả Topics'),
                      ),
                      ...filterState.topics.map(
                        (t) =>
                            DropdownMenuItem(value: t.id, child: Text(t.title)),
                      ),
                    ],
                    onChanged: filterState.selectedLevelId == 'All'
                        ? null
                        : (val) {
                            if (val != null) {
                              filterNotifier.setTopic(val);
                              ref
                                  .read(progressControllerProvider.notifier)
                                  .refreshProgress();
                            }
                          },
                    isLoading: false,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: state.when(
              data: (stats) {
                final totalWords = stats.totalLearning + stats.totalMastered;
                final masteredRatio = totalWords == 0
                    ? 0.0
                    : stats.totalMastered / totalWords;

                return RefreshIndicator(
                  onRefresh: () async => ref
                      .read(progressControllerProvider.notifier)
                      .refreshProgress(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMainCard(
                          stats.totalMastered,
                          totalWords,
                          masteredRatio,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                title: 'Đã thuộc',
                                value: stats.totalMastered.toString(),
                                icon: Icons.check_circle_outline,
                                color: AppColors.accentMastered,
                                bgColor: AppColors.accentMasteredTrack,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatBox(
                                title: 'Chưa thuộc',
                                value: stats.totalLearning.toString(),
                                icon: Icons.book_outlined,
                                color: AppColors.brandDark,
                                bgColor: AppColors.surfacePink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, st) => Center(
                child: ErrorRetryWidget(
                  errorMessage: 'Không thể tải dữ liệu thống kê.',
                  onRetry: () => ref
                      .read(progressControllerProvider.notifier)
                      .refreshProgress(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required bool isLoading,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: isLoading
          ? const SizedBox(height: 48, child: Center(child: SizedBox.shrink()))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                items: items,
                onChanged: onChanged,
                isExpanded: true,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
    );
  }

  Widget _buildMainCard(int mastered, int total, double ratio) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tiến độ của bạn',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 16,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentMastered,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(ratio * 100).toInt()}%',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 36,
                      color: AppColors.brandDark,
                    ),
                  ),
                  Text(
                    'Đã thuộc',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Bạn đã thuộc $mastered trên tổng số $total từ vựng đã tương tác.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(value, style: AppTextStyles.h2.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

