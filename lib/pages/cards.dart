import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels.dart';
import '../models.dart';
import 'quizz.dart';

class CardsPage extends StatelessWidget {
  final String themeId;
  final String themeName;
  const CardsPage({super.key, required this.themeId, required this.themeName});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context);
    if (vm.currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(themeName)),
        body: const Center(child: Text('Please sign in to view cards.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(themeName)),
      body: StreamBuilder<List<FullCardModel>>(
        stream: vm.cardsForThemeStream(themeId),
        builder: (context, snapshot) {
          final allCards = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 64),
              // All Cards Card
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListCardsScreen(
                          themeId: themeId,
                          filter: CardFilter.all,
                          title: 'List the ${allCards.length} cards',
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 72,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${allCards.length}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' Cards',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Known and Unknown Cards Row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 72,
                        child: ListTile(
                          title: const Text('Known Cards'),
                          trailing: StreamBuilder<int>(
                            stream: vm.getKnownCardCountForThemeStream(themeId),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListCardsScreen(
                                  themeId: themeId,
                                  filter: CardFilter.known,
                                  title: 'Known Cards',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: SizedBox(
                        height: 72,
                        child: ListTile(
                          title: const Text('Unknown Cards'),
                          trailing: StreamBuilder<int>(
                            stream: vm.getNotKnownCardCountForThemeStream(themeId),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurpleAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListCardsScreen(
                                  themeId: themeId,
                                  filter: CardFilter.unknown,
                                  title: 'Unknown Cards',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              // Start Quiz Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 4.0,
                child: SizedBox(
                  height: 144,
                  child: ListTile(
                    title: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Start Quizz'),
                          const SizedBox(width: 16),
                          const Icon(Icons.quiz),
                        ],
                      ),
                    ),
                    minTileHeight: 60,
                    textColor: Colors.deepPurpleAccent,
                    onTap: allCards.isNotEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizzPage(cards: allCards),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ListCardsScreen widget
class ListCardsScreen extends StatelessWidget {
  final String themeId;
  final CardFilter filter;
  final String title;
  const ListCardsScreen({super.key, required this.themeId, required this.filter, required this.title});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<FullCardModel>>(
        stream: vm.cardsForThemeStream(themeId),
        builder: (context, snapshot) {
          final cards = snapshot.data ?? [];
          final filteredCards = filter == CardFilter.known
              ? cards.where((c) => c.isKnown).toList()
              : filter == CardFilter.unknown
                  ? cards.where((c) => !c.isKnown).toList()
                  : cards;
          if (filteredCards.isEmpty) {
            return const Center(child: Text('No cards to show.'));
          }
          return ListView.builder(
            itemCount: filteredCards.length,
            itemBuilder: (context, index) {
              final card = filteredCards[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(card.subject),
                  subtitle: Text(card.answer),
                  trailing: card.isKnown
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.close, color: Colors.red),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final subjectController = TextEditingController(text: card.subject);
                        final answerController = TextEditingController(text: card.answer);
                        return AlertDialog(
                          title: const Text('Edit Card'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: subjectController,
                                decoration: const InputDecoration(labelText: 'Subject'),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: answerController,
                                decoration: const InputDecoration(labelText: 'Answer'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (subjectController.text.isNotEmpty && answerController.text.isNotEmpty) {
                                  await vm.editCard(
                                    card,
                                    subjectController.text,
                                    answerController.text,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Card updated!')),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Subject and answer cannot be empty')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCardDialog(context, vm, themeId, filter == CardFilter.known ? true : false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, MemoViewModel vm, String themeId, bool isKnown) {
    final subjectController = TextEditingController();
    final answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.isNotEmpty && answerController.text.isNotEmpty) {
                  await vm.addCard(themeId, subjectController.text, answerController.text, isKnown);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card added!')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Subject and answer cannot be empty')),
                    );
                  }
                }
              },
              child: const Text('Add Card'),
            ),
          ],
        );
      },
    );
  }
}
