import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_memo_cards/models.dart';
import 'package:flutter_memo_cards/viewmodels.dart';

class QuizzPage extends StatelessWidget {
  final List<FullCardModel> cards;
  const QuizzPage({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return _QuizzPageBody(cards: cards);
  }
}

class _QuizzPageBody extends StatefulWidget {
  final List<FullCardModel> cards;
  const _QuizzPageBody({required this.cards});

  @override
  State<_QuizzPageBody> createState() => _QuizzPageBodyState();
}

class _QuizzPageBodyState extends State<_QuizzPageBody> with SingleTickerProviderStateMixin {
  late int _currentCardIndex;
  late List<int> _reviewedIndexes;
  final Random _random = Random();
  bool _cardRevealed = false;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _reviewedIndexes = [];
    _currentCardIndex = _getRandomCardIndex();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getRandomCardIndex() {
    if (_reviewedIndexes.length == widget.cards.length) {
      return -1;
    }
    int newIndex;
    do {
      newIndex = _random.nextInt(widget.cards.length);
    } while (_reviewedIndexes.contains(newIndex));
    return newIndex;
  }

  void _markCardKnown(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context, listen: false);
    final card = widget.cards[_currentCardIndex];
    vm.setCardKnown(card.themeId, card.id, true); // Pass themeId and cardId
    setState(() {
      _reviewedIndexes.add(_currentCardIndex);
      _cardRevealed = false;
      _controller.reset();
      _currentCardIndex = _getRandomCardIndex();
    });
  }

  void _markCardNotKnown(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context, listen: false);
    final card = widget.cards[_currentCardIndex];
    vm.setCardKnown(card.themeId, card.id, false); // Pass themeId and cardId
    setState(() {
      _reviewedIndexes.add(_currentCardIndex);
      _cardRevealed = false;
      _controller.reset();
      _currentCardIndex = _getRandomCardIndex();
    });
  }

  void _flipCard() {
    if (_isFlipping || _cardRevealed) return;
    setState(() {
      _isFlipping = true;
    });
    _controller.forward().then((_) {
      setState(() {
        _cardRevealed = true;
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context);
    if (vm.currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Please sign in to view cards.')),
      );
    }

    if (_currentCardIndex == -1) {
      // Use StreamBuilder for not known count
      return StreamBuilder<int>(
        stream: vm.getNotKnownCardCountForThemeStream(widget.cards.first.themeId),
        builder: (context, snapshot) {
          final notKnownCount = snapshot.data ?? 0;
          final knownCount = widget.cards.length - notKnownCount;
          final totalCount = widget.cards.length;
          final scorePercent = totalCount == 0 ? 0 : (knownCount / totalCount) * 100;
          final scoreColor = scorePercent > 50
              ? Colors.green
              : Colors.deepPurple;

          return Scaffold(
            appBar: AppBar(title: const Text('Quiz Complete')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Quiz Complete',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 22, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Score: '),
                        TextSpan(
                          text: '$knownCount',
                          style: TextStyle(
                            fontSize: 22,
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '/$totalCount cards are known!',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      textStyle: const TextStyle(fontSize: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final card = widget.cards[_currentCardIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * pi;
                  final isFront = angle < pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: SingleChildScrollView(
                              child: isFront
                                  ? Text(
                                      card.subject,
                                      style: const TextStyle(fontSize: 24),
                                      textAlign: TextAlign.center,
                                    )
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(pi),
                                      child: Text(
                                        card.answer,
                                        style: const TextStyle(fontSize: 24, color: Colors.deepPurple),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _cardRevealed ? () => _markCardKnown(context) : null,
                      icon: const Icon(Icons.check, color: Colors.white, size: 32),
                      label: const Text(
                        'I Know It!',
                        style: TextStyle(fontSize: 22),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _cardRevealed ? () => _markCardNotKnown(context) : null,
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      label: const Text(
                        'Not Yet',
                        style: TextStyle(fontSize: 22),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}