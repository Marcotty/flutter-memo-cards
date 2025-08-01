import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels.dart';
import '../models.dart';
import 'quizz.dart';

class CardsPage extends StatelessWidget {
  // We now pass themeId and themeName from ThemeListScreen
  final String themeId;
  final String themeName; // Used for the AppBar title
  const CardsPage({super.key, required this.themeId, required this.themeName});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context);
    // Check if a user is logged in
    if (vm.currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(themeName)),
        body: const Center(child: Text('Please sign in to view cards.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(themeName), // Display the theme name
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: StreamBuilder<List<FullCardModel>>(
              stream: vm.cardsForThemeStream(
                themeId,
              ), // Stream the cards for the Quiz button
              builder: (context, snapshot) {
                final cardsForQuiz = snapshot.data ?? [];
                return IconButton(
                  icon: const Icon(Icons.quiz),
                  tooltip: 'Start Quiz',
                  // Only enable the quiz button if there are cards
                  onPressed: cardsForQuiz.isNotEmpty
                      ? () {
                          // Navigate to quiz page, passing the actual FullCardModel list
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuizzPage(cards: cardsForQuiz),
                            ),
                          );
                        }
                      : null, // Disable button
                );
              },
            ),
          ),
        ],
      ),

      body: StreamBuilder<List<FullCardModel>>(
        stream: vm.cardsForThemeStream(
          themeId,
        ), // Listen to the real-time stream of cards
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Show loading
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            ); // Show error
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No cards in this theme yet! Add one.'),
            ); // No data message
          }
          final cards = snapshot.data!; // Your list of FullCardModel objects
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index]; // Get the FullCardModel
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(card.title),
                  subtitle: Text(card.description),
                  onLongPress: () {
                    _showCardOptionsBottomSheet(
                      context,
                      vm,
                      card,
                    ); // Pass FullCardModel
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddCardDialog(context, vm, themeId), // Use dialog for adding
        child: const Icon(Icons.add),
      ),
    );
  }
  // --- Helper Methods for Dialogs and Bottom Sheet ---
  void _showCardOptionsBottomSheet(
    BuildContext context,
    MemoViewModel vm,
    FullCardModel card,
  ) {
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
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _showEditCardDialog(context, vm, card); // Open edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Card'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _showDeleteConfirmationDialog(
                  context,
                  vm,
                  card,
                ); // Open delete dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCardDialog(
    BuildContext context,
    MemoViewModel vm,
    String themeId,
  ) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Card Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Card Description',
                ),
                maxLines: 3,
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
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  await vm.addCard(
                    themeId,
                    titleController.text,
                    descriptionController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Card "${titleController.text}" added successfully!',
                        ),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Card details cannot be empty'),
                      ),
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

  void _showEditCardDialog(
    BuildContext context,
    MemoViewModel vm,
    FullCardModel card,
  ) {
    TextEditingController titleController = TextEditingController(
      text: card.title,
    );
    TextEditingController descriptionController = TextEditingController(
      text: card.description,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Card Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Card Description',
                ),
                maxLines: 3,
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
                final newTitle = titleController.text;
                final newDescription = descriptionController.text;
                if (newTitle.isNotEmpty &&
                    newDescription.isNotEmpty &&
                    (newTitle != card.title ||
                        newDescription != card.description)) {
                  await vm.editCard(card, newTitle, newDescription);
                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Card "${card.title}" updated to "$newTitle" successfully!',
                        ),
                      ),
                    );
                  }
                } else if (newTitle.isEmpty || newDescription.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Card details cannot be empty'),
                      ),
                    );
                  }
                } else {
                  // No changes or empty, just close
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    MemoViewModel vm,
    FullCardModel card,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Card?'),
          content: Text(
            'Are you sure you want to delete the card "${card.title}"?',
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                await vm.removeCard(card);

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Card "${card.title}" deleted successfully!',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
