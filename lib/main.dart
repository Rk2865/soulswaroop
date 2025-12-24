import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/main_home_page.dart';
import 'screens/settings_page.dart';
import 'screens/registration_page.dart';
import 'screens/profile_page.dart';
import 'screens/contact_us_page.dart';
import 'screens/about_page.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signOut();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soulswaroop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/main': (context) => const MainHomePage(),
        '/settings': (context) => const SettingsPage(),
        '/registration': (context) => const RegistrationPage(),
        '/profile': (context) => const ProfilePage(),
        '/contact': (context) => const ContactUsPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
