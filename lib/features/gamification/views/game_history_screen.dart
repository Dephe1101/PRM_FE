import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/pagination_widget.dart';
import 'package:mobile/core/widgets/empty_filter_prompt.dart';
import 'package:mobile/features/gamification/controllers/game_history_controller.dart';
import 'package:mobile/features/gamification/controllers/game_history_detail_controller.dart';
import 'package:mobile/features/gamification/controllers/all_topic_filter_controller.dart';
import 'package:mobile/features/gamification/models/game_history_item_model.dart';
import 'package:intl/intl.dart';

class GameHistoryScreen extends ConsumerStatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  ConsumerState<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends ConsumerState<GameHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameHistoryControllerProvider);
    final filter = ref.watch(gameHistoryFilterProvider);

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
          'Lịch Sử Chơi',
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(context, ref, filter),
          Expanded(
            child: state.when(
              data: (data) {
                if (filter.topicIds.isEmpty) {
                  return const EmptyFilterPrompt();
                }

                if (data.docs.isEmpty) {
                  return const Center(child: Text('Chưa có lịch sử chơi game'));
                }

                final int totalPages = (data.totalDocs / 5).ceil();

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref
                            .read(gameHistoryControllerProvider.notifier)
                            .refreshHistory(),
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: data.docs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = data.docs[index];
                            return _buildHistoryItem(context, item);
                          },
                        ),
                      ),
                    ),
                    PaginationWidget(
                      currentPage: data.page,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        ref
                            .read(gameHistoryControllerProvider.notifier)
                            .goToPage(page);
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => Center(
                child: ErrorRetryWidget(
                  errorMessage: 'Lỗi: $e',
                  onRetry: () => ref
                      .read(gameHistoryControllerProvider.notifier)
                      .refreshHistory(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    GameHistoryFilterState filter,
  ) {
    final allTopicState = ref.watch(allTopicFilterProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown<String>(
              value: allTopicState.selectedLevelId,
              items: allTopicState.levels
                  .map(
                    (l) => DropdownMenuItem(
                      value: l.id,
                      child: Text(l.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(allTopicFilterProvider.notifier).setLevel(val);
                  ref.read(gameHistoryFilterProvider.notifier).setTopicIds([]);
                }
              },
              hint: 'Chọn Level',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _showTopicBottomSheet(context, ref, filter.topicIds),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filter.topicIds.isEmpty
                          ? 'Chọn Topics'
                          : 'Đã chọn (${filter.topicIds.length})',
                      style: AppTextStyles.bodyText,
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.any((item) => item.value == value) ? value : null,
          isExpanded: true,
          hint: Text(hint, style: AppTextStyles.bodyText),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showTopicBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<String> currentTopicIds,
  ) {
    // Local selection state for this bottom sheet session
    final localSelected = List<String>.from(currentTopicIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Material(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Chọn chủ đề (Max 5)', style: AppTextStyles.h2),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setModalState(() => localSelected.clear());
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                tooltip: 'Xóa tất cả',
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Consumer(
                        builder: (context, sheetRef, child) {
                          final topicState = sheetRef.watch(allTopicFilterProvider);
                          if (topicState.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (topicState.error != null) {
                            return Center(
                              child: Text('Lỗi: ${topicState.error}'),
                            );
                          }
                          if (topicState.topics.isEmpty) {
                            return const Center(child: Text('Không có chủ đề nào'));
                          }
                          return ListView.builder(
                            itemCount: topicState.topics.length,
                            itemBuilder: (context, index) {
                              final topic = topicState.topics[index];
                              final isSelected = localSelected.contains(topic.id);
                              final canSelectMore = localSelected.length < 5;

                              return CheckboxListTile(
                                title: Text(
                                  topic.title,
                                  style: AppTextStyles.bodyText,
                                ),
                                value: isSelected,
                                onChanged: (isSelected || canSelectMore)
                                    ? (bool? value) {
                                        setModalState(() {
                                          if (isSelected) {
                                            localSelected.remove(topic.id);
                                          } else {
                                            localSelected.add(topic.id);
                                          }
                                        });
                                      }
                                    : null,
                                activeColor: AppColors.brandDark,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(gameHistoryFilterProvider.notifier)
                                .setTopicIds(List.from(localSelected));
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            'Áp dụng',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, GameHistoryItemModel item) {
    final formattedDate = item.endTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(item.endTime!)
        : 'Unknown';

    return InkWell(
      onTap: () => _showDetailBottomSheet(context, item.sessionId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.gameType == 'FALLING_WORDS' ? 'Từ rơi' : 'Trắc nghiệm',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandDark,
                  ),
                ),
                Text(
                  formattedDate,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  'Điểm số',
                  NumberFormat('#,###').format(item.score),
                  Icons.star_rounded,
                  Colors.amber,
                ),
                _buildStat(
                  'Combo',
                  '${item.maxCombo}',
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                ),
                _buildStat(
                  'Xu',
                  '+${item.coinsEarned}',
                  Icons.monetization_on_rounded,
                  Colors.yellow.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, String sessionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final detailAsync = ref.watch(
                  gameHistoryDetailControllerProvider(sessionId),
                );

                return detailAsync.when(
                  data: (detail) {
                    final playDuration = detail.endTime != null
                        ? detail.endTime!.difference(detail.startTime).inSeconds
                        : 0;

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Chi tiết Ván Game',
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow(
                          'Chế độ',
                          detail.gameType == 'FALLING_WORDS'
                              ? 'Từ rơi'
                              : 'Trắc nghiệm',
                        ),
                        _buildDetailRow(
                          'Trạng thái',
                          detail.status == 'completed'
                              ? 'Hoàn thành'
                              : 'Đã hủy',
                        ),
                        _buildDetailRow('Thời gian chơi', '$playDuration giây'),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              'Điểm số',
                              NumberFormat('#,###').format(detail.score),
                              Icons.star_rounded,
                              Colors.amber,
                            ),
                            _buildStat(
                              'Combo',
                              '${detail.maxCombo}',
                              Icons.local_fire_department_rounded,
                              Colors.orange,
                            ),
                            _buildStat(
                              'Xu',
                              '+${detail.coinsEarned}',
                              Icons.monetization_on_rounded,
                              Colors.yellow.shade700,
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        Text('Chủ đề đã chơi', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: detail.includedTopics
                              .map(
                                (t) => Chip(
                                  label: Text(
                                    t.title,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.brandDark,
                                    ),
                                  ),
                                  backgroundColor: AppColors.brandDark
                                      .withValues(alpha: 0.1),
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => Center(child: Text('Lỗi: $e')),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
