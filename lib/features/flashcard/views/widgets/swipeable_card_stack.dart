import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';
import 'package:mobile/features/flashcard/views/widgets/flashcard_widget.dart';

enum SwipeDirection { left, right }

class SwipeableCardStack extends StatefulWidget {
  final List<FlashcardModel> flashcards;
  final Function(int index) onPageChanged;
  final Function(int index, SwipeDirection direction)? onSwipe;
  final WidgetBuilder? finishBuilder;

  const SwipeableCardStack({
    super.key,
    required this.flashcards,
    required this.onPageChanged,
    this.onSwipe,
    this.finishBuilder,
  });

  @override
  State<SwipeableCardStack> createState() => SwipeableCardStackState();
}

class SwipeableCardStackState extends State<SwipeableCardStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  int _currentIndex = 0;
  bool _isFlipping = false;

  final double _swipeThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_animationController);

    _animationController.addListener(() {
      setState(() {
        _dragOffset = _animation.value;
        _dragAngle = _dragOffset.dx / 1000;
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // If animated off screen, increment index
        if (_dragOffset.dx.abs() > _swipeThreshold) {
          final direction = _dragOffset.dx > 0
              ? SwipeDirection.right
              : SwipeDirection.left;

          if (widget.onSwipe != null) {
            widget.onSwipe!(_currentIndex, direction);
          }

          setState(() {
            _currentIndex++;
            _dragOffset = Offset.zero;
            _dragAngle = 0;
          });
          widget.onPageChanged(_currentIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Exposed for external buttons
  void triggerSwipeRight() {
    if (_currentIndex >= widget.flashcards.length) return;
    _animateOffScreen(true);
  }

  void triggerSwipeLeft() {
    if (_currentIndex >= widget.flashcards.length) return;
    _animateOffScreen(false);
  }

  void _onPanStart(DragStartDetails details) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle =
          _dragOffset.dx / 1000; // Rotate slightly based on horizontal movement
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;

    // Swipe Right
    if (_dragOffset.dx > _swipeThreshold || velocity > 1000) {
      _animateOffScreen(true);
    }
    // Swipe Left
    else if (_dragOffset.dx < -_swipeThreshold || velocity < -1000) {
      _animateOffScreen(false);
    }
    // Snap back
    else {
      _animateSnapBack();
    }
  }

  void _animateOffScreen(bool isRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    _animation =
        Tween<Offset>(
          begin: _dragOffset,
          end: Offset(
            isRight ? screenWidth * 1.5 : -screenWidth * 1.5,
            _dragOffset.dy,
          ),
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward(from: 0);
  }

  void _animateSnapBack() {
    _animation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.flashcards.length) {
      if (widget.finishBuilder != null) {
        return widget.finishBuilder!(context);
      }
      return Center(
        child: Text(
          'Bạn đã hoàn thành tất cả từ vựng!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    // Render top 3 cards (for performance and perspective)
    List<Widget> cardStack = [];

    for (
      int i = min(widget.flashcards.length - 1, _currentIndex + 2);
      i >= _currentIndex;
      i--
    ) {
      final isTopCard = i == _currentIndex;
      final offsetFromTop = i - _currentIndex; // 0, 1, 2

      // Calculate scale and vertical offset for background cards
      final scale = isTopCard ? 1.0 : (1.0 - (offsetFromTop * 0.05));
      final topOffset = isTopCard ? 0.0 : (offsetFromTop * 10.0);

      Widget card = FlashcardWidget(
        flashcard: widget.flashcards[i],
        onFlip: isTopCard
            ? (isFlipping) {
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isFlipping = isFlipping;
                      });
                    }
                  });
                }
              }
            : null,
      );

      if (isTopCard) {
        // The top card follows the drag offset and rotation
        cardStack.add(
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Transform.translate(
                offset: _dragOffset,
                child: Transform.rotate(angle: _dragAngle, child: card),
              ),
            ),
          ),
        );
      } else {
        // Background cards have static offset and scale
        cardStack.add(
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isFlipping ? 0.0 : 1.0,
              child: Transform.translate(
                offset: Offset(0, topOffset),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomCenter,
                  child: AbsorbPointer(child: card),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(alignment: Alignment.center, children: cardStack);
  }
}
