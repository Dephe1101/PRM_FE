import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_text_styles.dart';
import 'package:mobile/features/gamification/controllers/falling_word_controller.dart';
import 'package:mobile/features/gamification/models/game_session_model.dart';

class FallingWordGameScreen extends ConsumerStatefulWidget {
  final List<String> topicIds;
  final GameDifficulty difficulty;

  const FallingWordGameScreen({
    super.key,
    required this.topicIds,
    this.difficulty = GameDifficulty.easy,
  });

  @override
  ConsumerState<FallingWordGameScreen> createState() =>
      _FallingWordGameScreenState();
}

class _FallingWordGameScreenState extends ConsumerState<FallingWordGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scoreEffectController;
  int _previousIndex = -1;
  bool _hasStarted = false;
  int _lastAddedPoints = 0;

  // Path coordinates for Hell mode
  double _startX = 0;
  double _startY = 0;
  double _endX = 0;
  double _endY = 0;
  bool _pathGenerated = false;

  @override
  void initState() {
    super.initState();
    final isHell = widget.difficulty == GameDifficulty.hell;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: isHell ? 5 : 8),
    );

    _scoreEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final state = ref.read(fallingWordControllerProvider);
        if (state.session != null && !state.isGameFinished && !state.isAnswering) {
          final currentWord = state.session!.words[state.currentIndex];
          ref
              .read(fallingWordControllerProvider.notifier)
              .handleTimeout(currentWord.wordId);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(fallingWordControllerProvider);
      ref
          .read(fallingWordControllerProvider.notifier)
          .startGame(widget.topicIds, difficulty: widget.difficulty);
    });
  }

  void _generateHellPath(Size size) {
    final random = math.Random();
    int side = random.nextInt(4);
    
    switch (side) {
      case 0: // Top to Bottom
        _startX = random.nextDouble() * size.width;
        _startY = -50;
        _endX = random.nextDouble() * size.width;
        _endY = size.height + 50;
        break;
      case 1: // Bottom to Top
        _startX = random.nextDouble() * size.width;
        _startY = size.height + 50;
        _endX = random.nextDouble() * size.width;
        _endY = -50;
        break;
      case 2: // Left to Right
        _startX = -50;
        _startY = random.nextDouble() * size.height;
        _endX = size.width + 50;
        _endY = random.nextDouble() * size.height;
        break;
      case 3: // Right to Left
        _startX = size.width + 50;
        _startY = random.nextDouble() * size.height;
        _endX = -50;
        _endY = random.nextDouble() * size.height;
        break;
    }
    _pathGenerated = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scoreEffectController.dispose();
    super.dispose();
  }

  void _handleOptionSelected(GameOptionModel option, GameWordModel currentWord, int index) {
    ref.read(fallingWordControllerProvider.notifier).handleAnswer(
      option.isCorrect, 
      currentWord.wordId, 
      optionIndex: index
    );
  }

  void _restartGame() {
    setState(() {
      _hasStarted = false;
      _previousIndex = -1;
      _pathGenerated = false;
    });
    ref.invalidate(fallingWordControllerProvider);
    ref.read(fallingWordControllerProvider.notifier).startGame(
      widget.topicIds, 
      difficulty: widget.difficulty
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fallingWordControllerProvider);

    ref.listen<FallingWordState>(fallingWordControllerProvider, (previous, next) {
      if (next.isGameFinished && next.submitResult != null) {
        _showGameOverDialog(next.score, next.submitResult);
      }

      if (next.isAnswering) {
        _controller.stop();
        if (next.isLastAnswerCorrect == true) {
          _lastAddedPoints = (next.currentCombo > 0 && next.currentCombo % 5 == 0) ? 200 : 100;
          _scoreEffectController.forward(from: 0);
        }
      }

      if (previous?.currentIndex != next.currentIndex && !next.isGameFinished && _hasStarted) {
        setState(() => _pathGenerated = false);
        _controller.reset();
        _controller.forward();
      }
    });

    if (state.isLoading && state.session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.session == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: ${state.error}', style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('Quay lại')),
            ],
          ),
        ),
      );
    }

    if (state.session == null) return const Scaffold();

    if (_previousIndex == -1 && !state.isGameFinished && _hasStarted) {
      _previousIndex = 0;
      _controller.forward();
    }

    GameWordModel? currentWord;
    if (!state.isGameFinished && state.currentIndex < state.session!.totalWords) {
      currentWord = state.session!.words[state.currentIndex];
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Unified Header Bar
            _buildHeader(state),
            // Progress Bar
            LinearProgressIndicator(
              value: state.session!.totalWords > 0 ? state.currentIndex / state.session!.totalWords : 0,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandDark),
              minHeight: 4,
            ),
            // Game Area
            Expanded(
              child: !_hasStarted 
                ? _buildStartScreen() 
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (widget.difficulty == GameDifficulty.hell && !_pathGenerated) {
                        _generateHellPath(Size(constraints.maxWidth, constraints.maxHeight));
                      }
                      return Stack(
                        children: [
                          if (currentWord != null)
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                double left, top, rotation = 0;
                                if (widget.difficulty == GameDifficulty.hell) {
                                  left = _startX + (_endX - _startX) * _controller.value - 75;
                                  top = _startY + (_endY - _startY) * _controller.value;
                                  rotation = _controller.value * 2 * math.pi;
                                } else {
                                  top = _controller.value * (constraints.maxHeight - 100);
                                  left = 0;
                                }
                                return Positioned(
                                  top: top,
                                  left: widget.difficulty == GameDifficulty.hell ? left : 0,
                                  right: widget.difficulty == GameDifficulty.hell ? null : 0,
                                  child: Transform.rotate(
                                    angle: rotation,
                                    child: Center(child: _buildWordCard(currentWord!, state)),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
            ),
            // Options Area
            _buildOptionsArea(currentWord, state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FallingWordState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.brandDark),
            onPressed: () => context.pop(),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Điểm: ${state.score}', style: AppTextStyles.h3.copyWith(color: AppColors.primary, fontSize: 16)),
                    Text('Tổng: ${state.totalPoints}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                Positioned(
                  left: 60,
                  top: -10,
                  child: FadeTransition(
                    opacity: _scoreEffectController,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(_scoreEffectController),
                      child: Text('+$_lastAddedPoints', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                const SizedBox(width: 4),
                Text('${state.currentCombo}', style: AppTextStyles.h2.copyWith(color: Colors.orange, fontSize: 24)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(alignment: Alignment.centerRight, child: _buildHintIcon(state)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.difficulty == GameDifficulty.hell ? 'CHẾ ĐỘ ĐỊA NGỤC' : 'CHẾ ĐỘ DỄ',
              style: AppTextStyles.h1.copyWith(color: widget.difficulty == GameDifficulty.hell ? AppColors.error : AppColors.brandDark)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { setState(() => _hasStarted = true); _controller.forward(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandDark, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text('BẮT ĐẦU', style: AppTextStyles.buttonText.copyWith(color: Colors.white, fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(GameWordModel word, FallingWordState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: state.isAnswering ? (state.isLastAnswerCorrect == true ? Colors.green.shade100 : Colors.red.shade100) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: state.isAnswering ? (state.isLastAnswerCorrect == true ? Colors.green : Colors.red) : AppColors.border, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(word.kanji.isNotEmpty ? word.kanji : (word.hiragana ?? ''), style: AppTextStyles.h1.copyWith(fontSize: 32)),
          if (word.kanji.isNotEmpty && word.hiragana != null)
            Text(word.hiragana!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOptionsArea(GameWordModel? currentWord, FallingWordState state) {
    if (currentWord == null || currentWord.options == null) return const SizedBox(height: 100);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: math.min(currentWord.options!.length, 4),
        itemBuilder: (context, index) {
          return _buildOptionButton(currentWord.options![index], currentWord, index, state);
        },
      ),
    );
  }

  Widget _buildOptionButton(GameOptionModel option, GameWordModel currentWord, int index, FallingWordState state) {
    final isSelected = state.selectedOptionIndex == index;
    final isCorrect = option.isCorrect;
    final showFeedback = state.isAnswering;
    Color bgColor = AppColors.background, borderColor = AppColors.border, textColor = AppColors.textPrimary;

    if (showFeedback) {
      if (isSelected) {
        bgColor = isCorrect ? Colors.green.shade100 : Colors.red.shade100;
        borderColor = isCorrect ? Colors.green : Colors.red;
        textColor = isCorrect ? Colors.green.shade900 : Colors.red.shade900;
      } else if (isCorrect) {
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.withValues(alpha: 0.5);
      }
    } else if (state.isHintUsed && isCorrect) {
      bgColor = Colors.amber.shade50; borderColor = Colors.amber; textColor = Colors.amber.shade900;
    }

    return InkWell(
      onTap: state.isAnswering ? null : () => _handleOptionSelected(option, currentWord, index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: isSelected ? 2 : 1)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(option.text, style: AppTextStyles.h3.copyWith(color: textColor, fontSize: 14), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _buildHintIcon(FallingWordState state) {
    return GestureDetector(
      onTap: () {
        if (state.isAnswering || state.isHintUsed) return;
        if (state.hintCount > 0) ref.read(fallingWordControllerProvider.notifier).useHint();
        else _showBuyHintDialog(context, ref);
      },
      child: Stack(clipBehavior: Clip.none, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: (state.hintCount > 0 || state.isHintUsed) ? Colors.amber : AppColors.border, width: 2)),
          child: Icon(Icons.lightbulb, color: (state.hintCount > 0 || state.isHintUsed) ? Colors.amber : Colors.grey, size: 24)),
        Positioned(top: -4, right: -4, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: state.hintCount > 0 ? Colors.amber : Colors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          child: Text('${state.hintCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
      ]),
    );
  }

  void _showBuyHintDialog(BuildContext context, WidgetRef ref) {
    _controller.stop();
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      title: const Text('Mua gợi ý'), content: const Text('Dùng 700 điểm để đổi 2 lần gợi ý?'),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); if (!ref.read(fallingWordControllerProvider).isAnswering) _controller.forward(); }, child: const Text('Hủy')),
        TextButton(onPressed: () { ref.read(fallingWordControllerProvider.notifier).buyHints(); Navigator.pop(context); if (!ref.read(fallingWordControllerProvider).isAnswering) _controller.forward(); }, child: const Text('Mua')),
      ],
    ));
  }

  void _showGameOverDialog(int score, Map<String, dynamic>? submitResult) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Game Over', style: AppTextStyles.h2.copyWith(color: AppColors.brandDark), textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Điểm của bạn: $score', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildRewardIcon(Icons.monetization_on, Colors.amber, submitResult?['rewards']?['coinsEarned'] ?? 0),
          _buildRewardIcon(Icons.star, Colors.blue, submitResult?['rewards']?['xpEarned'] ?? 0),
        ]),
      ]),
      actions: [
        Row(children: [
          Expanded(child: TextButton(onPressed: () { Navigator.pop(context); context.pop(); }, child: const Text('Xong'))),
          Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); _restartGame(); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandDark), child: const Text('Chơi lại', style: TextStyle(color: Colors.white)))),
        ]),
      ],
    ));
  }

  Widget _buildRewardIcon(IconData icon, Color color, int value) {
    return Column(children: [Icon(icon, color: color, size: 32), Text('+$value', style: AppTextStyles.bodyText)]);
  }
}
