
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulswaroop/screens/login_page.dart';
import 'package:soulswaroop/screens/main_home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // User is logged in, so perform the biometric check.
            return const BiometricCheckScreen();
          }
          // User is not logged in
          return const LoginPage();
        }
        // Show a loading indicator while checking the auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class BiometricCheckScreen extends StatefulWidget {
  const BiometricCheckScreen({super.key});

  @override
  State<BiometricCheckScreen> createState() => _BiometricCheckScreenState();
}

class _BiometricCheckScreenState extends State<BiometricCheckScreen> {
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _performBiometricCheck();
  }

  Future<void> _performBiometricCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('biometricEnabled') ?? false;

    if (isBiometricEnabled) {
      final authenticated = await _authenticate();
      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
        });
      }
    } else {
      // Biometric lock is not enabled, grant access immediately
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
        });
      }
    }
  }

  Future<bool> _authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuthenticate) {
        // If biometrics are not available, bypass the check.
        return true;
      }

      return await auth.authenticate(
        localizedReason: 'Please authenticate to access Soulswaroop',
        options: const AuthenticationOptions(
          stickyAuth: true, // User has to explicitly cancel it
          biometricOnly: false, // Allows PIN/Pattern as well
        ),
      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated == true) {
      // Authentication successful or not required
      return const MainHomePage();
    }

    if (_isAuthenticated == false) {
      // Authentication failed, show a locked screen with a retry button
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Authentication Required',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Please unlock the app to continue.'),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _performBiometricCheck,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Still checking, show loading indicator
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
