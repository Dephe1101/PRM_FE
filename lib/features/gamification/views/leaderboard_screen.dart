import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/empty_filter_prompt.dart';
import 'package:mobile/features/gamification/controllers/game_leaderboard_controller.dart';
import 'package:mobile/features/gamification/controllers/all_topic_filter_controller.dart';
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
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    // Top 3 Podium Chart
                    if (entries.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildPodium(entries),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                    ],
                    // Full list
                    ...entries.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLeaderboardItem(e.value, e.key),
                      ),
                    ),
                  ],
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

  Widget _buildPodium(List<LeaderboardEntryModel> entries) {
    final top3 = entries.take(3).toList();

    // Reorder: 2nd, 1st, 3rd (podium visual order)
    final List<LeaderboardEntryModel?> podiumOrder = [
      top3.length > 1 ? top3[1] : null, // left: 2nd
      top3.isNotEmpty ? top3[0] : null,  // center: 1st
      top3.length > 2 ? top3[2] : null,  // right: 3rd
    ];
    final podiumHeights = [100.0, 130.0, 80.0];
    final podiumColors = [
      Colors.grey.shade300,
      const Color(0xFFFFD700),
      const Color(0xFFCD7F32),
    ];
    final rankLabels = ['2', '1', '3'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Top 3 Người Chơi',
            style: AppTextStyles.h3.copyWith(color: AppColors.brandDark),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final entry = podiumOrder[i];
              if (entry == null) return const Expanded(child: SizedBox());
              return Expanded(
                child: _buildPodiumItem(
                  entry: entry,
                  rank: int.parse(rankLabels[i]),
                  barHeight: podiumHeights[i],
                  barColor: podiumColors[i],
                  isFirst: i == 1,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required LeaderboardEntryModel entry,
    required int rank,
    required double barHeight,
    required Color barColor,
    required bool isFirst,
  }) {
    final initials = entry.username.isNotEmpty
        ? entry.username.substring(0, 1).toUpperCase()
        : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 22))
        else
          const SizedBox(height: 28),
        const SizedBox(height: 4),
        // Avatar
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: isFirst ? 30 : 24,
              backgroundColor: barColor.withValues(alpha: 0.3),
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.bold,
                  fontSize: isFirst ? 22 : 18,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: barColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Name
        Text(
          entry.username,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Score
        Text(
          NumberFormat('#,###').format(entry.score),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.brandDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Podium bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [barColor, barColor.withValues(alpha: 0.6)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: barColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, LeaderboardFilterState filter) {
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
                  .map((l) => DropdownMenuItem(
                        value: l.id,
                        child: Text(l.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(allTopicFilterProvider.notifier).setLevel(val);
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
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
                            return Center(child: Text('Lỗi: ${topicState.error}'));
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
                                title: Text(topic.title, style: AppTextStyles.bodyText),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            ref
                                .read(leaderboardFilterProvider.notifier)
                                .setTopicIds(List.from(localSelected));
                            Navigator.pop(ctx);
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
            backgroundColor: AppColors.primary.withValues(alpha: 0.5),
            child: Text(
              entry.username.isNotEmpty ? entry.username.substring(0, 1).toUpperCase() : '?',
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
