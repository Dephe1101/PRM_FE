import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/empty_filter_prompt.dart';
import 'package:mobile/features/gamification/controllers/game_leaderboard_controller.dart';
import 'package:mobile/features/gamification/controllers/game_filter_controller.dart';
import 'package:mobile/features/gamification/models/leaderboard_entry_model.dart';
import 'package:intl/intl.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameLeaderboardControllerProvider);
    final filter = ref.watch(leaderboardFilterProvider);

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
          'Bảng Xếp Hạng',
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
              data: (entries) {
                if (filter.topicIds.isEmpty) {
                  return const EmptyFilterPrompt();
                }

                if (entries.isEmpty) {
                  return const Center(
                    child: Text('Chưa có dữ liệu xếp hạng'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildLeaderboardItem(entry, index);
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => Center(
                child: ErrorRetryWidget(
                  errorMessage: 'Lỗi: $e',
                  onRetry: () => ref
                      .read(gameLeaderboardControllerProvider.notifier)
                      .refreshLeaderboard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, LeaderboardFilterState filter) {
    final gameFilterState = ref.watch(gameFilterControllerProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown<String>(
              value: gameFilterState.selectedLevelId,
              items: gameFilterState.levels
                  .map((l) => DropdownMenuItem(
                        value: l.id,
                        child: Text(l.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(gameFilterControllerProvider.notifier).setLevel(val);
                  ref.read(leaderboardFilterProvider.notifier).setTopicIds([]);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
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

  void _showTopicBottomSheet(BuildContext context, WidgetRef ref, List<String> currentTopicIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                          Consumer(
                            builder: (context, ref, child) {
                              return IconButton(
                                onPressed: () {
                                  ref.read(gameFilterControllerProvider.notifier).clearTopics();
                                },
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                tooltip: 'Xóa tất cả',
                              );
                            },
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
                      final filterState = sheetRef.watch(gameFilterControllerProvider);
                      if (filterState.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (filterState.error != null) {
                        return Center(child: Text('Lỗi: \${filterState.error}'));
                      }
                      if (filterState.topics.isEmpty) {
                        return const Center(child: Text('Không có chủ đề nào'));
                      }
                      return ListView.builder(
                        itemCount: filterState.topics.length,
                        itemBuilder: (context, index) {
                          final topic = filterState.topics[index];
                          final isSelected = filterState.selectedTopicIds.contains(topic.id);
                          final canSelectMore = filterState.selectedTopicIds.length < 5;

                          return CheckboxListTile(
                            title: Text(topic.title, style: AppTextStyles.bodyText),
                            value: isSelected,
                            onChanged: (isSelected || canSelectMore)
                                ? (bool? value) {
                                    sheetRef.read(gameFilterControllerProvider.notifier).toggleTopic(topic.id);
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final selected = ref.read(gameFilterControllerProvider).selectedTopicIds;
                        ref.read(leaderboardFilterProvider.notifier).setTopicIds(selected);
                        context.pop();
                      },
                      child: Text(
                        'Áp dụng',
                        style: AppTextStyles.buttonText.copyWith(color: Colors.white),
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
  }

  Widget _buildLeaderboardItem(LeaderboardEntryModel entry, int index) {
    final rank = index + 1;
    Color rankColor = AppColors.textSecondary;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = Colors.grey.shade400;
    if (rank == 3) rankColor = Colors.brown.shade300;

    return Container(
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
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: AppTextStyles.h2.copyWith(color: rankColor),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: AppColors.brandDark.withValues(alpha: 0.1),
            child: Text(
              entry.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.brandDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.username,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            NumberFormat('#,###').format(entry.score),
            style: AppTextStyles.h3.copyWith(color: AppColors.brandDark),
          ),
        ],
      ),
    );
  }
}
