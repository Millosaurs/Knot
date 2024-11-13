import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knot/firebase_options.dart';
import 'package:knot/models/chat_user.dart'; // Import ChatUser class
import 'package:knot/pages/login_page.dart';
import 'package:knot/pages/signup_page.dart';
import 'package:knot/pages/home.dart';
import 'package:knot/pages/chat_page.dart';
import 'package:knot/pages/settings_page.dart';
import 'package:knot/pages/profile_setup.dart';
import 'package:knot/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KnotApp());
}

class KnotApp extends StatelessWidget {
  const KnotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            return HomePage(
                currentUserId:
                    currentUser.uid); // Pass currentUserId to HomeScreen
          }
          return const Center(child: Text('Error: User not found.'));
        },
        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          if (args.containsKey('selectedUser') &&
              args.containsKey('currentUser')) {
            final selectedUser = args['selectedUser'] as ChatUser;
            final currentUser = args['currentUser'] as User;

            return ChatPage(
              selectedUser: selectedUser,
              currentUser: currentUser,
            );
          }
          return const Center(child: Text('Error: Missing user data.'));
        },
        '/profile': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as String;
          return ProfilePage(userId: userId); // Pass userId to ProfilePage
        },
        '/settings': (context) => SettingsPage(),
        '/profile_setup': (context) => ProfilePageSetup(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // Ensure to pass currentUserId to HomeScreen
            return HomePage(currentUserId: snapshot.data!.uid);
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
