import 'dart:math';

import 'package:flutter/material.dart';

import '../../application/daily_goals_controller.dart';

class MemoryMatchGamePage extends StatefulWidget {
  const MemoryMatchGamePage({
    required this.dailyGoalsController,
    required this.isTurkish,
    super.key,
  });

  final DailyGoalsController dailyGoalsController;
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

  @override
  void initState() {
    super.initState();

    _createDeck();
  }

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
    _isResolving = false;
  }

  Future<void> _handleCardTap(int index) async {
    if (_isResolving ||
        _openedIndexes.contains(index) ||
        _matchedPairIds.contains(_cards[index].pairId)) {
      return;
    }

    setState(() {
      _openedIndexes.add(index);
    });

    if (_openedIndexes.length < 2) {
      return;
    }

    final opened = _openedIndexes.toList();

    final firstCard = _cards[opened[0]];
    final secondCard = _cards[opened[1]];

    setState(() {
      _attempts++;
      _isResolving = true;
    });

    if (firstCard.pairId == secondCard.pairId) {
      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (!mounted) {
        return;
      }

      setState(() {
        _matchedPairIds.add(firstCard.pairId);
        _openedIndexes.clear();
        _isResolving = false;
      });

      if (_matchedPairIds.length == _cards.length ~/ 2) {
        await _completeGame();
      }

      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) {
      return;
    }

    setState(() {
      _openedIndexes.clear();
      _isResolving = false;
    });
  }

  Future<void> _completeGame() async {
    await widget.dailyGoalsController.complete(DailyGoalType.quiz);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.isTurkish
                ? 'Tebrikler! Tüm bilgi kartlarını eşleştirdin. 🎉'
                : 'Great job! You matched every knowledge card. 🎉',
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
    final completed = _matchedPairIds.length == _cards.length ~/ 2;

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _GameInfo(
                      icon: Icons.check_circle_rounded,
                      text:
                          widget.isTurkish
                              ? '${_matchedPairIds.length}/4 eşleşme'
                              : '${_matchedPairIds.length}/4 matches',
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
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onTap: () {
                        _handleCardTap(index);
                      },
                    );
                  },
                ),
              ),
              if (completed)
                FilledButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(widget.isTurkish ? 'Tekrar oyna' : 'Play again'),
                ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color:
          revealed
              ? matched
                  ? colors.tertiaryContainer
                  : colors.primaryContainer
              : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: matched ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Center(
            key: ValueKey('$revealed-$label'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child:
                  revealed
                      ? Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      )
                      : const Icon(Icons.question_mark_rounded, size: 36),
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
