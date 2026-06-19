import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/features/gamification/controllers/game_filter_controller.dart';

class GameTab extends ConsumerWidget {
  const GameTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(gameFilterControllerProvider);
    final filterNotifier = ref.read(gameFilterControllerProvider.notifier);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Trò chơi',
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
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.brandDark),
            onPressed: () => _showGameMenuModal(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLevelDropdown(ref, filterState),
                const SizedBox(height: 12),
                _buildMultiSelectField(context, ref, filterState),
                _buildSelectedTopics(filterState),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.brandDark.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.videogame_asset,
                          size: 80,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Falling Word',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kiểm tra phản xạ và trí nhớ của bạn\nvới các từ vựng đang rơi!',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandDark,
                            disabledBackgroundColor: AppColors.border,
                            disabledForegroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: filterState.selectedTopicIds.isEmpty
                              ? null
                              : () {
                                  final topicIdsParam = filterState
                                      .selectedTopicIds
                                      .join(',');
                                  context.push(
                                    '/falling-word?topicIds=$topicIdsParam',
                                  );
                                },
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          label: Text(
                            'Bắt đầu chơi',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Tùy chọn', style: AppTextStyles.h2),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppColors.success),
                ),
                title: Text('Thống kê của bạn', style: AppTextStyles.bodyText),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteConstants.gameStats);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.leaderboard_rounded, color: Colors.amber.shade600),
                ),
                title: Text('Bảng Xếp Hạng', style: AppTextStyles.bodyText),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteConstants.leaderboard);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.brandDark),
                ),
                title: Text('Lịch sử chơi game', style: AppTextStyles.bodyText),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteConstants.gameHistory);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelDropdown(WidgetRef ref, GameFilterState state) {
    final filterNotifier = ref.read(gameFilterControllerProvider.notifier);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: state.isLoading && state.levels.isEmpty
          ? const SizedBox(height: 48, child: Center(child: SizedBox.shrink()))
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.selectedLevelId,
                isExpanded: true,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textPrimary,
                ),
                hint: Text(
                  'Chọn Level',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tất cả Levels'),
                  ),
                  ...state.levels.map(
                    (l) => DropdownMenuItem(value: l.id, child: Text(l.name)),
                  ),
                ],
                onChanged: (val) => filterNotifier.setLevel(val),
              ),
            ),
    );
  }

  Widget _buildMultiSelectField(
    BuildContext context,
    WidgetRef ref,
    GameFilterState state,
  ) {
    String displayText = 'Chọn Topics';
    if (state.selectedTopicIds.isNotEmpty) {
      if (state.selectedTopicIds.length == state.topics.length) {
        displayText = 'Đã chọn tất cả Topics';
      } else {
        displayText = 'Đã chọn ${state.selectedTopicIds.length} Topics';
      }
    }

    return InkWell(
      onTap: state.isLoading
          ? null
          : () => _showMultiSelectModal(context, ref, state),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: state.isLoading
            ? const Center(
                child: SizedBox.shrink(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayText,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSelectedTopics(GameFilterState state) {
    if (state.selectedTopicIds.isEmpty) return const SizedBox.shrink();

    final selectedTopics = state.topics
        .where((t) => state.selectedTopicIds.contains(t.id))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: selectedTopics.map((topic) {
          return Chip(
            label: Text(
              topic.title,
              style: AppTextStyles.caption.copyWith(color: AppColors.brandDark),
            ),
            backgroundColor: AppColors.brandDark.withValues(alpha: 0.1),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showMultiSelectModal(
    BuildContext context,
    WidgetRef ref,
    GameFilterState state,
  ) {
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
              ],
            ),
          ),
        );
      },
    );
  }
}
