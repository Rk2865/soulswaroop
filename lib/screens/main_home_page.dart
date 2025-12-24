import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soul_mirror_page.dart';
import 'mind_garden_page.dart';
import 'essence_page.dart';
import '../widgets/animated_tab_bar.dart';
import 'settings_page.dart'; // Import the settings page
import 'profile_page.dart'; // Import the profile page
import 'chatbot_page.dart'; // Import the chatbot page

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  final List<AnimatedTabData> _tabs = const [
    AnimatedTabData(text: 'Soul Mirror', icon: Icons.psychology),
    AnimatedTabData(text: 'Mind Garden', icon: Icons.spa),
    AnimatedTabData(text: 'Essence', icon: Icons.auto_awesome),
  ];

  final List<Widget> _pages = const [
    SoulMirrorPage(),
    MindGardenPage(),
    EssencePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'SoulSwaroop',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseAuth.instance.currentUser != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots()
                : null,
            builder: (context, snapshot) {
              String userName = 'Soulswaroop User';
              String? photoUrl;
              
              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final firstName = data['firstName'] ?? '';
                final lastName = data['lastName'] ?? '';
                if (firstName.isNotEmpty) {
                  userName = '$firstName $lastName'.trim();
                }
                photoUrl = data['photoUrl'];
              }

              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                   Container(
                    padding: const EdgeInsets.only(top: 50, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: (photoUrl == null || photoUrl.isEmpty)
                                ? const Icon(Icons.person, size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    text: 'Profile',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    text: 'Account Privacy',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    text: 'Settings',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.3)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.contact_phone_outlined,
                    text: 'Contact Us',
                    onTap: () => Navigator.pushNamed(context, '/contact'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.rate_review_outlined,
                    text: 'Rate Us',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    text: 'About',
                    onTap: () => Navigator.pushNamed(context, '/about'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.3)),
                  ),
                  _buildDrawerItem(
                    icon: Icons.exit_to_app,
                    text: 'Sign Out',
                    color: Colors.white, // Keeping white to match theme, red might be too jarring on gradient
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated tab bar
              AnimatedTabBar(
                selectedIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                tabs: _tabs,
              ),
              // Tab content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_currentIndex),
                    child: _pages[_currentIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()));
              },
              backgroundColor: const Color(0xFF667eea),
              child: const Icon(Icons.smart_toy),
            )
          : null,
    );
  }
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        hoverColor: Colors.white.withOpacity(0.2),
      ),
    );
  }
}
