import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_memo_cards/models.dart';

class QuizzPage extends StatefulWidget {
  final List<FullCard> cards;

  const QuizzPage({Key? key, required this.cards}) : super(key: key);

  @override
  _QuizzPageState createState() => _QuizzPageState();
}

class _QuizzPageState extends State<QuizzPage> {
  late int _currentCardIndex;
  Set<int> _knownCards = {};
  Set<int> _notKnownCards = {};
  Random _random = Random();
  bool _cardRevealed = false;

  @override
  void initState() {
    super.initState();
    _currentCardIndex = _getRandomCardIndex();
  }

  int _getRandomCardIndex() {
    if (_knownCards.length + _notKnownCards.length == widget.cards.length) {
      // Quiz is complete, return -1 or handle completion
      return -1;
    }
    int newIndex;
    do {
      newIndex = _random.nextInt(widget.cards.length);
    } while (_knownCards.contains(newIndex) || _notKnownCards.contains(newIndex));
    return newIndex;
  }

  void _markCardKnown() {
    setState(() {
      _knownCards.add(_currentCardIndex);
      _cardRevealed = false; // Reset card revealed state
      _currentCardIndex = _getRandomCardIndex();
    });
  }

  void _markCardNotKnown() {
    setState(() {
      _notKnownCards.add(_currentCardIndex);
      _cardRevealed = false; // Reset card revealed state
      _currentCardIndex = _getRandomCardIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentCardIndex == -1) {
      final score = _knownCards.length / widget.cards.length * 100;
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Complete')),
        body: Center(child: Text('You have reviewed all the cards!\nYour score: ${score.toStringAsFixed(2)}%')),
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
              onTap: () {
                setState(() {
                  _cardRevealed = !_cardRevealed;
                });
              },
              child: SizedBox(
                width: 300, // Fixed width
                height: 200, // Fixed height
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Flexible( // Use Flexible to allow text to wrap
                        child: Text(
                          _cardRevealed ? card.description : card.title,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _cardRevealed ? _markCardKnown : null,
                  icon: const Icon(Icons.check, color: Colors.green),
                  tooltip: 'I Know It!',
                ),
                IconButton(
                  onPressed: _cardRevealed ? _markCardNotKnown : null,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Not Yet',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}