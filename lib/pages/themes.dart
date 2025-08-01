import 'package:flutter/material.dart';
import 'package:flutter_memo_cards/pages/cards.dart';
import 'package:provider/provider.dart';
import '../viewmodels.dart';
import '../models.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context);

    // Check if a user is logged in
    if (vm.currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Themes')),
        body: const Center(
          child: Text('Please sign in to manage your themes.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo Themes'), // Changed title for clarity
        actions: [
          // You can add other actions here if needed
        ],
      ),
      body: StreamBuilder<List<ThemeModel>>(
        stream: vm.userThemesStream, // Listen to the real-time stream of themes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No themes yet! Tap the + button to add one.')); // No data message
          }

          final themes = snapshot.data!; // Your list of ThemeModel objects
          return ListView.builder(
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index]; // Get the ThemeModel
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Use withOpacity instead of withValues
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    trailing: const Icon(Icons.arrow_forward_ios),
                    title: Center(child: Text(theme.name)), // Access theme.name
                    onLongPress: () {
                      _showThemeOptionsBottomSheet(context, vm, theme); // Pass ThemeModel
                    },
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardsPage( // Navigate to the cards page
                          themeId: theme.id, // Pass the Firestore ID
                          themeName: theme.name, // Pass the name for display
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddThemeDialog(context, vm), // Use dialog for adding
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Helper Methods for Dialogs and Bottom Sheet ---

  void _showThemeOptionsBottomSheet(BuildContext context, MemoViewModel vm, ThemeModel theme) {
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
              title: const Text('Edit Theme'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _showEditThemeDialog(context, vm, theme); // Open edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Theme'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _showDeleteConfirmationDialog(context, vm, theme); // Open delete dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddThemeDialog(BuildContext context, MemoViewModel vm) {
    TextEditingController themeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Theme'),
          content: TextField(
            controller: themeController,
            decoration: const InputDecoration(labelText: 'Theme Name'), // Changed to labelText
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async { // Made async for Snackbar
                if (themeController.text.isNotEmpty) {
                  await vm.addTheme(themeController.text);
                  if (context.mounted) { // Check context before popping
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Theme "${themeController.text}" added successfully!')),
                     );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme name cannot be empty')),
                    );
                  }
                }
              },
              child: const Text('Add Theme'), // Changed text
            ),
          ],
        );
      },
    );
  }

  void _showEditThemeDialog(BuildContext context, MemoViewModel vm, ThemeModel theme) {
    TextEditingController themeController = TextEditingController(text: theme.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Theme Name'),
          content: TextField(
            controller: themeController,
            decoration: InputDecoration(labelText: theme.name), // Show current name as label
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async { // Made async for Snackbar
                final newName = themeController.text;
                if (newName.isNotEmpty && newName != theme.name) {
                  await vm.editTheme(theme, newName); // Pass ThemeModel
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Theme "${theme.name}" updated to "$newName" successfully!')),
                    );
                  }
                } else if (newName.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme name cannot be empty')),
                    );
                  }
                } else { // Name is same or empty, nothing to do
                  if (context.mounted) {
                    Navigator.pop(context); // Just close the dialog
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

  void _showDeleteConfirmationDialog(BuildContext context, MemoViewModel vm, ThemeModel theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Theme?'),
          content: Text('Are you sure you want to delete the theme "${theme.name}"? All cards within this theme will also be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async { // Made async for Snackbar
                await vm.removeTheme(theme); // Pass ThemeModel
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Theme "${theme.name}" deleted successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
