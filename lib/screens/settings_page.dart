
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulswaroop/screens/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isBiometricEnabled = false;
  static const String _biometricEnabledKey = 'biometricEnabled';

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    });
  }

  Future<void> _setBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = value;
      prefs.setBool(_biometricEnabledKey, value);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Biometric lock enabled.' : 'Biometric lock disabled.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.white.withOpacity(0.1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  title: const Text('Biometric Lock', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Use your fingerprint or face to log in.', style: TextStyle(color: Colors.white70)),
                  value: _isBiometricEnabled,
                  onChanged: _setBiometricPreference,
                  activeColor: Colors.white,
                  secondary: const Icon(Icons.fingerprint, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: const Text('Change Password', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Update your password.', style: TextStyle(color: Colors.white70)),
                  leading: const Icon(Icons.lock_outline, color: Colors.white),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
