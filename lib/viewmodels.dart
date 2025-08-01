import 'package:flutter/material.dart';
import 'models.dart';

class MemoViewModel extends ChangeNotifier {
  final List<String> _themes = [];
  final Map<String, List<FullCard>> _cardsByTheme = {};

  MemoViewModel() {
    // Default themes
    _themes.addAll(['History', 'Sciences']);

    // Default cards for History
    _cardsByTheme['History'] = [
      FullCard(
        theme: 'History',
        title: 'Moon Landing',
        description: 'Apollo 11 landed on the Moon in 1969.',
      ),
      FullCard(
        theme: 'History',
        title: 'Fall of Berlin Wall',
        description: 'The Berlin Wall fell in 1989, ending the Cold War.',
      ),
    ];

    // Default cards for Sciences
    _cardsByTheme['Sciences'] = [
      FullCard(
        theme: 'Sciences',
        title: 'Discovery of DNA',
        description: 'Watson and Crick discovered the DNA structure in 1953.',
      ),
      FullCard(
        theme: 'Sciences',
        title: 'Theory of Relativity',
        description: 'Einstein published the theory of relativity in 1905.',
      ),
    ];
  }

  List<String> get themes => List.unmodifiable(_themes);

  List<FullCard> cardsForTheme(String theme) =>
      List.unmodifiable(_cardsByTheme[theme] ?? []);

  void addTheme(String theme) {
    if (!_themes.contains(theme)) {
      _themes.add(theme);
      notifyListeners();
    }
  }

  void editTheme(String oldTheme, String newTheme) {
    final index = _themes.indexOf(oldTheme);
    if (index != -1 && newTheme.isNotEmpty) {
      _themes[index] = newTheme;
      final cards = _cardsByTheme.remove(oldTheme);
      if (cards != null) {
        _cardsByTheme[newTheme] = cards;
      }
      notifyListeners();
    }
  }
  
  void removeTheme(String theme) {
    _themes.remove(theme);
    _cardsByTheme.remove(theme);
    notifyListeners();
  }

  void addCard(String theme, FullCard card) {
    _cardsByTheme.putIfAbsent(theme, () => []);
    _cardsByTheme[theme]!.add(card);
    notifyListeners();
  }

  void editCard(FullCard oldCard, FullCard newCard) {
    final cards = _cardsByTheme[oldCard.theme];
    if (cards != null) {
      final index = cards.indexOf(oldCard);
      if (index != -1 && newCard.isNotEmpty) {
        cards[index] = newCard;
        notifyListeners();
      }
    }
  }

  void removeCard(FullCard card) {
    final cards = _cardsByTheme[card.theme];
    if (cards != null) {
      cards.remove(card);
      notifyListeners();
    }
  }
}