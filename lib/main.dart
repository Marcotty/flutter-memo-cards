import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels.dart';
import 'pages/themes.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MemoViewModel(),
      child: const MemoCardsApp(),
    ),
  );
}

class MemoCardsApp extends StatelessWidget {
  const MemoCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo Cards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorScheme.fromSeed(seedColor: Colors.green).inversePrimary,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}
//responsible for login/register
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4), // Use a theme-related icon
            tooltip: 'Toggle Theme',
            onPressed: () {
              // Implement theme change logic here
              // Example:
              // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThemesPage()),
                );
              },
              child: const Text('Go to Themes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the registration page
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}