import 'dart:math';

import 'package:flutter/material.dart';

import '../../application/daily_goals_controller.dart';
import '../../application/learning_game_progress_controller.dart';

class MemoryMatchGamePage extends StatefulWidget {
  const MemoryMatchGamePage({
    required this.dailyGoalsController,
    required this.progressController,
    required this.isTurkish,
    super.key,
  });

  final DailyGoalsController dailyGoalsController;
  final LearningGameProgressController progressController;
  final bool isTurkish;

  @override
  State<MemoryMatchGamePage> createState() => _MemoryMatchGamePageState();
}

class _MemoryMatchGamePageState extends State<MemoryMatchGamePage> {
  late List<_MemoryCardData> _cards;

  final Set<int> _openedIndexes = <int>{};
  final Set<int> _matchedPairIds = <int>{};

  bool _isResolving = false;

  int _attempts = 0;
  int _score = 0;
  int _combo = 0;

  @override
  void initState() {
    super.initState();

    _createDeck();
  }

  int get _totalPairs => _cards.length ~/ 2;

  bool get _completed => _matchedPairIds.length == _totalPairs;

  void _createDeck() {
    final pairs =
        widget.isTurkish
            ? const [
              _MemoryPair(left: 'Fransa', right: 'Paris'),
              _MemoryPair(left: 'H₂O', right: 'Su'),
              _MemoryPair(left: '7 × 8', right: '56'),
              _MemoryPair(left: 'Dünya’nın uydusu', right: 'Ay'),
            ]
            : const [
              _MemoryPair(left: 'France', right: 'Paris'),
              _MemoryPair(left: 'H₂O', right: 'Water'),
              _MemoryPair(left: '7 × 8', right: '56'),
              _MemoryPair(left: 'Earth\'s moon', right: 'Moon'),
            ];

    _cards = <_MemoryCardData>[];

    for (var index = 0; index < pairs.length; index++) {
      final pair = pairs[index];

      _cards.add(_MemoryCardData(pairId: index, label: pair.left));

      _cards.add(_MemoryCardData(pairId: index, label: pair.right));
    }

    _cards.shuffle(Random());

    _openedIndexes.clear();
    _matchedPairIds.clear();

    _attempts = 0;
    _score = 0;
    _combo = 0;

    _isResolving = false;
  }

  Future<void> _handleCardTap(int index) async {
    if (_isResolving) {
      return;
    }

    if (_openedIndexes.contains(index)) {
      return;
    }

    final selectedCard = _cards[index];

    if (_matchedPairIds.contains(selectedCard.pairId)) {
      return;
    }

    setState(() {
      _openedIndexes.add(index);
    });

    if (_openedIndexes.length < 2) {
      return;
    }

    final openedIndexes = _openedIndexes.toList();

    final firstCard = _cards[openedIndexes[0]];
    final secondCard = _cards[openedIndexes[1]];

    setState(() {
      _attempts++;
      _isResolving = true;
    });

    if (firstCard.pairId == secondCard.pairId) {
      final nextCombo = _combo + 1;

      final scoreGain = 10 + ((nextCombo - 1) * 2);

      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (!mounted) {
        return;
      }

      setState(() {
        _matchedPairIds.add(firstCard.pairId);

        _combo = nextCombo;
        _score += scoreGain;

        _openedIndexes.clear();
        _isResolving = false;
      });

      await widget.progressController.submitScore(
        LearningGameType.memoryMatch,
        _score,
      );

      if (!mounted) {
        return;
      }

      if (_completed) {
        await _completeGame();
      }

      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) {
      return;
    }

    setState(() {
      _combo = 0;

      _openedIndexes.clear();
      _isResolving = false;
    });
  }

  Future<void> _completeGame() async {
    await widget.dailyGoalsController.complete(DailyGoalType.quiz);

    await widget.progressController.submitScore(
      LearningGameType.memoryMatch,
      _score,
    );

    if (!mounted) {
      return;
    }

    final bestScore = widget.progressController.bestScoreFor(
      LearningGameType.memoryMatch,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Text(
            widget.isTurkish
                ? '🎉 Tamamlandı! Skor: $_score • Rekor: $bestScore'
                : '🎉 Complete! Score: $_score • Best: $bestScore',
          ),
        ),
      );
  }

  void _restartGame() {
    setState(() {
      _createDeck();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTurkish ? 'Hafıza Eşleştirme' : 'Memory Match'),
        actions: [
          IconButton(
            tooltip: widget.isTurkish ? 'Yeniden başlat' : 'Restart',
            onPressed: _restartGame,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.progressController,
          builder: (context, _) {
            final bestScore = widget.progressController.bestScoreFor(
              LearningGameType.memoryMatch,
            );

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _GameInfo(
                                icon: Icons.check_circle_rounded,
                                text:
                                    widget.isTurkish
                                        ? '${_matchedPairIds.length}/$_totalPairs eşleşme'
                                        : '${_matchedPairIds.length}/$_totalPairs matches',
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _GameInfo(
                                icon: Icons.touch_app_rounded,
                                text:
                                    widget.isTurkish
                                        ? '$_attempts deneme'
                                        : '$_attempts attempts',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _GameInfo(
                                icon: Icons.stars_rounded,
                                text:
                                    widget.isTurkish
                                        ? 'Skor $_score'
                                        : 'Score $_score',
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _GameInfo(
                                icon: Icons.emoji_events_rounded,
                                text:
                                    widget.isTurkish
                                        ? 'Rekor $bestScore'
                                        : 'Best $bestScore',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _combo > 1
                                    ? colors.tertiaryContainer
                                    : colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 18,
                                color:
                                    _combo > 1
                                        ? colors.onTertiaryContainer
                                        : colors.onSurfaceVariant,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                'Combo x$_combo',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _combo > 1
                                          ? colors.onTertiaryContainer
                                          : colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: GridView.builder(
                      itemCount: _cards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                          ),
                      itemBuilder: (context, index) {
                        final card = _cards[index];

                        final revealed =
                            _openedIndexes.contains(index) ||
                            _matchedPairIds.contains(card.pairId);

                        final matched = _matchedPairIds.contains(card.pairId);

                        return _MemoryCard(
                          label: card.label,
                          revealed: revealed,
                          matched: matched,
                          onTap: () async {
                            await _handleCardTap(index);
                          },
                        );
                      },
                    ),
                  ),

                  if (_completed) ...[
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 34)),

                          const SizedBox(height: 6),

                          Text(
                            widget.isTurkish
                                ? 'Tüm kartları eşleştirdin!'
                                : 'You matched every card!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            widget.isTurkish
                                ? 'Skor $_score • $_attempts deneme'
                                : 'Score $_score • $_attempts attempts',
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          FilledButton.icon(
                            onPressed: _restartGame,
                            icon: const Icon(Icons.replay_rounded),
                            label: Text(
                              widget.isTurkish ? 'Tekrar oyna' : 'Play again',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameInfo extends StatelessWidget {
  const _GameInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: colors.onSecondaryContainer),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.label,
    required this.revealed,
    required this.matched,
    required this.onTap,
  });

  final String label;
  final bool revealed;
  final bool matched;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor =
        matched
            ? colors.tertiaryContainer
            : revealed
            ? colors.primaryContainer
            : colors.surfaceContainerHighest;

    final foregroundColor =
        matched
            ? colors.onTertiaryContainer
            : revealed
            ? colors.onPrimaryContainer
            : colors.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            matched
                ? null
                : () async {
                  await onTap();
                },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Center(
            key: ValueKey('$revealed-$matched-$label'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child:
                  revealed
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (matched) ...[
                            Icon(
                              Icons.check_circle_rounded,
                              color: foregroundColor,
                              size: 20,
                            ),

                            const SizedBox(height: 6),
                          ],

                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                      : Icon(
                        Icons.question_mark_rounded,
                        size: 36,
                        color: foregroundColor,
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryPair {
  const _MemoryPair({required this.left, required this.right});

  final String left;
  final String right;
}

class _MemoryCardData {
  const _MemoryCardData({required this.pairId, required this.label});

  final int pairId;
  final String label;
}
