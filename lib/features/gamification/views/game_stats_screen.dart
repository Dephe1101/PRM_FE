import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/core/widgets/empty_filter_prompt.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/features/gamification/controllers/game_stats_controller.dart';
import 'package:mobile/features/gamification/controllers/word_stats_controller.dart';
import 'package:mobile/features/flashcard/controllers/progress_words_controller.dart';
import 'package:mobile/features/flashcard/views/progress_words_screen.dart';
import 'package:mobile/features/flashcard/models/flashcard_stats_model.dart';
import 'package:mobile/core/widgets/pagination_widget.dart';

class GameStatsScreen extends ConsumerStatefulWidget {
  const GameStatsScreen({super.key});

  @override
  ConsumerState<GameStatsScreen> createState() => _GameStatsScreenState();
}

class _GameStatsScreenState extends ConsumerState<GameStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedWordType = 'learning';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FlashcardStatsModel?>(
      wordStatsControllerProvider.select((s) => s.stats),
      (prev, next) {
        if (next != null) {
          final wordState = ref.read(wordStatsControllerProvider);
          ref
              .read(progressWordsControllerProvider.notifier)
              .load(
                type: _selectedWordType,
                levelId: wordState.selectedLevelId,
                topicId: wordState.selectedTopicId,
              );
        }
      },
    );

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
          'Thống kê của bạn',
          style: AppTextStyles.h2.copyWith(color: AppColors.brandDark),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.brandDark,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Game'),
            Tab(text: 'Từ vựng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGameStatsTab(), _buildWordStatsTab()],
      ),
    );
  }

  Widget _buildGameStatsTab() {
    final gameState = ref.watch(gameStatsControllerProvider);

    return Column(
      children: [
        // Game Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: _buildDropdown<String>(
                  value: gameState.selectedLevelId,
                  items: gameState.levels
                      .map(
                        (l) => DropdownMenuItem(
                          value: l.id,
                          child: Text(l.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(gameStatsControllerProvider.notifier)
                          .setLevel(val);
                    }
                  },
                  hint: 'Chọn Level',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _showTopicMultiSelect(context, gameState),
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
                          gameState.selectedTopicIds.isEmpty
                              ? 'Chọn Topics'
                              : 'Đã chọn (${gameState.selectedTopicIds.length}/5)',
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
        ),
        // Game Content
        Expanded(child: _buildGameStatsContent(gameState)),
      ],
    );
  }

  void _showTopicMultiSelect(BuildContext context, GameStatsState gameState) {
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
                                  ref
                                      .read(
                                        gameStatsControllerProvider.notifier,
                                      )
                                      .clearTopics();
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
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
                    builder: (context, ref, child) {
                      final currentState = ref.watch(
                        gameStatsControllerProvider,
                      );
                      if (currentState.topics.isEmpty) {
                        return const Center(child: Text('Không có chủ đề nào'));
                      }
                      return ListView.builder(
                        itemCount: currentState.topics.length,
                        itemBuilder: (context, index) {
                          final topic = currentState.topics[index];
                          final isSelected = currentState.selectedTopicIds
                              .contains(topic.id);
                          final canSelectMore =
                              currentState.selectedTopicIds.length < 5;

                          return CheckboxListTile(
                            title: Text(
                              topic.title,
                              style: AppTextStyles.bodyText,
                            ),
                            value: isSelected,
                            onChanged: (isSelected || canSelectMore)
                                ? (bool? value) {
                                    ref
                                        .read(
                                          gameStatsControllerProvider.notifier,
                                        )
                                        .toggleTopic(topic.id);
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

  Widget _buildGameStatsContent(GameStatsState gameState) {
    if (gameState.error != null) {
      return Center(
        child: ErrorRetryWidget(
          errorMessage: gameState.error!,
          onRetry: () => ref
              .read(gameStatsControllerProvider.notifier)
              .fetchStats(gameState.selectedTopicIds),
        ),
      );
    }

    final stats = gameState.stats;
    if (gameState.selectedTopicIds.isEmpty) {
      return const EmptyFilterPrompt();
    }
    if (stats == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildStatCard(
              'Số ván',
              '${stats.totalGames}',
              Icons.games_rounded,
              AppColors.brandDark,
              'Tổng số ván game đã chơi',
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'TB Điểm',
              '${stats.avgScore}',
              Icons.analytics_rounded,
              AppColors.success,
              'Điểm số trung bình',
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Kỷ lục',
              '${stats.bestScore}',
              Icons.emoji_events_rounded,
              Colors.amber.shade600,
              'Điểm số cao nhất',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordStatsTab() {
    final wordState = ref.watch(wordStatsControllerProvider);

    return Column(
      children: [
        // Word Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: _buildDropdown<String>(
                  value: wordState.selectedLevelId,
                  items: wordState.levels
                      .map(
                        (l) => DropdownMenuItem(
                          value: l.id,
                          child: Text(l.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(wordStatsControllerProvider.notifier)
                          .setLevel(val);
                    }
                  },
                  hint: 'Chọn Level',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<String>(
                  value: wordState.selectedTopicId,
                  items: wordState.topics
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.title, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(wordStatsControllerProvider.notifier)
                          .setTopic(val);
                    }
                  },
                  hint: 'Chọn Chủ đề',
                ),
              ),
            ],
          ),
        ),
        // Word Content
        Expanded(child: _buildWordStatsContent(wordState)),
      ],
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

  Widget _buildWordStatsContent(WordStatsState wordState) {
    if (wordState.error != null) {
      return Center(
        child: ErrorRetryWidget(
          errorMessage: wordState.error!,
          onRetry: () => ref
              .read(wordStatsControllerProvider.notifier)
              .fetchStats(wordState.selectedTopicId!),
        ),
      );
    }

    final stats = wordState.stats;
    if (stats == null) {
      return const Center(child: Text('Vui lòng chọn chủ đề'));
    }

    if (stats.status == 'NOT_LEARNED') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa học chủ đề này',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy hoàn thành bài học để xem thống kê',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedWordType = 'learning');
                    ref
                        .read(progressWordsControllerProvider.notifier)
                        .load(
                          type: 'learning',
                          levelId: wordState.selectedLevelId,
                          topicId: wordState.selectedTopicId,
                        );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.brandDark.withValues(
                        alpha: _selectedWordType == 'learning' ? 0.2 : 0.05,
                      ),
                      border: Border.all(
                        color: _selectedWordType == 'learning'
                            ? AppColors.brandDark
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${stats.totalLearning}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.brandDark,
                          ),
                        ),
                        Text('Đang học', style: AppTextStyles.bodyText),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedWordType = 'mastered');
                    ref
                        .read(progressWordsControllerProvider.notifier)
                        .load(
                          type: 'mastered',
                          levelId: wordState.selectedLevelId,
                          topicId: wordState.selectedTopicId,
                        );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(
                        alpha: _selectedWordType == 'mastered' ? 0.2 : 0.05,
                      ),
                      border: Border.all(
                        color: _selectedWordType == 'mastered'
                            ? AppColors.success
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${stats.totalMastered}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                        Text('Đã thuộc', style: AppTextStyles.bodyText),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildProgressWordsList()),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressWordsList() {
    final state = ref.watch(progressWordsControllerProvider);
    final isMastered = _selectedWordType == 'mastered';
    final accentColor = isMastered
        ? AppColors.accentMastered
        : AppColors.brandDark;
    final bgColor = isMastered
        ? AppColors.accentMasteredTrack
        : AppColors.surfacePink;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text('Có lỗi xảy ra', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(progressWordsControllerProvider.notifier)
                  .goToPage(state.currentPage),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final docs = state.data.docs;
    final totalPages = state.data.totalPages;

    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMastered ? Icons.emoji_events_outlined : Icons.book_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có từ vựng nào',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index];
              return ProgressWordCard(
                word: item.word,
                flashcard: item,
                accent: accentColor,
                bg: bgColor,
                isMastered: isMastered,
              );
            },
          ),
        ),
        if (totalPages > 1)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: PaginationWidget(
              currentPage: state.currentPage,
              totalPages: totalPages,
              onPageChanged: (page) {
                ref
                    .read(progressWordsControllerProvider.notifier)
                    .goToPage(page);
              },
            ),
          ),
      ],
    );
  }
}
