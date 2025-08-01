import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels.dart';
import 'pages/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
      clientId:
          '643524386263-jq5a8og58obvad8hl1qc1g150nbvt7fb.apps.googleusercontent.com',
    ),
  ]);
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
          backgroundColor: ColorScheme.fromSeed(
            seedColor: Colors.green,
          ).inversePrimary,
        ),

        // Primary color will affect many widgets, including default button colors
        primarySwatch:
            Colors.deepPurple, // Try a color that matches your brand!

        // This targets ElevatedButtons specifically (often used by FirebaseUI)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Button background

            foregroundColor: Colors.white, // Button text color

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ), // Rounded corners for buttons
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ), // Button padding

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ), // Text style
          ),
        ),

        // You can also adjust input field decorations
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

          filled: true,

          fillColor: Colors.grey[200],
        ),

        // And other elements like text styles
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),

          bodyMedium: TextStyle(color: Colors.black54),

          headlineSmall: TextStyle(color: Colors.deepPurple),
        ),
      ),
      home: const AuthGate(),
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
                FirebaseAuth.instance.signOut(); // Simple sign out
              },

              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // If the user is not logged in, show the SignInScreen

        if (!snapshot.hasData) {
          return SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),

                child: AspectRatio(
                  aspectRatio: 1,

                  child: Image.asset('assets/logo.png'),
                ),
              );
            },
            footerBuilder: (context, action) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),

                  child: Text(
                    'By signing in, you agree to our terms and conditions.',

                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },

            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                // User just signed in, navigate to home screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Welcome, ${state.user?.displayName}!'),
                  ),
                );
                //Navigator.pushReplacementNamed(context, '/home');
              }),

              AuthStateChangeAction<AuthFailed>((context, state) {
                // Handle specific authentication failures

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Authentication failed: Check credentials'),
                  ),
                );
              }),
            ],
          );
          // This is the magic!
        }

        // Otherwise, show your application's home screen

        return const ThemesPage(); // Your app's main content
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome!')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text('You are signed in!'),

            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Simple sign out
              },

              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
