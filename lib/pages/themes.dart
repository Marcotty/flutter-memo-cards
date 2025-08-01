import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels.dart';
import 'cards.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MemoViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Memo Cards')),
      body: ListView(
        children: vm.themes
            .map(
              (theme) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    trailing: const Icon(Icons.arrow_forward_ios),
                    title: Center(child: Text(theme)),
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
                                title: const Text('Edit Theme'),
                                onTap: () async {
                                  final String newTheme = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditTheme(initialTheme: theme),
                                    ),
                                  );
                                  if (!context.mounted) {
                                    return; // Check if the context is still valid
                                  }
                                  if (newTheme.isNotEmpty) {
                                    vm.editTheme(theme, newTheme);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Theme name cannot be empty',
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
                                        '$theme updated to $newTheme successfully',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete Theme'),
                                onTap: () {
                                  vm.removeTheme(theme);
                                  Navigator.pop(
                                    context,
                                  ); // Close the bottom sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$theme deleted successfully',
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardsPage(selectedTheme: theme),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTheme = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => InputNewTheme()),
          );
          if (newTheme != null && newTheme.isNotEmpty) {
            vm.addTheme(newTheme);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditTheme extends InputNewTheme {
  EditTheme({super.key, required this.initialTheme}) : super();
  final String initialTheme;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Theme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: initialTheme),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class InputNewTheme extends StatelessWidget {
  InputNewTheme({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Theme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Theme Name'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text('Add Theme'),
            ),
          ],
        ),
      ),
    );
  }
}
