import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels.dart';
import '../models.dart';
import 'quizz.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key, required this.selectedTheme});
  final String selectedTheme;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context);
    final cards = vm.cardsForTheme(selectedTheme);
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedTheme),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: IconButton(
              icon: const Icon(Icons.quiz),
              tooltip: 'Start Quiz',
              onPressed: () {
                // Navigate to quiz page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizzPage(cards: cards),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: cards
            .map((card) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                    title: Text(card.title),
                    subtitle: Text(card.description),
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        enableDrag: true,
                        elevation: 10.0,
                        builder: (context) {
                          return Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit Card'),
                                onTap: () async {
                                  final FullCard newCard = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditCard(initialCard: card),
                                    ),
                                  );
                                  if (!context.mounted) {
                                    return; // Check if the context is still valid
                                  }
                                  if (newCard.isNotEmpty) {
                                    vm.editCard(card, newCard);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Card details cannot be empty',
                                        ),
                                      ),
                                    );
                                  }
                                  Navigator.pop(
                                    context,
                                  ); // Close the bottom sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${card.title} updated to ${newCard.title} successfully',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete Card'),
                                onTap: () {
                                  vm.removeCard(card);
                                  Navigator.pop(
                                    context,
                                  ); // Close the bottom sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${card.title} deleted successfully',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
            ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InputNewCard(selectedTheme: selectedTheme),
            ),
          );
          if (newCard != null) {
            vm.addCard(selectedTheme, newCard);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditCard extends StatelessWidget {
  const EditCard({super.key, required this.initialCard});

  final FullCard initialCard;

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: initialCard.title);
    final TextEditingController descController =
        TextEditingController(text: initialCard.description);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Card')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Card Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Card Description'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  FullCard(
                    theme: initialCard.theme,
                    title: titleController.text,
                    description: descController.text,
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class InputNewCard extends StatelessWidget {
  InputNewCard({super.key, required this.selectedTheme});

  final String selectedTheme;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Card Name'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Card Description'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, FullCard(
                  theme: selectedTheme,
                  title: _titleController.text,
                  description: _descController.text,
                ));
              },
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }
}