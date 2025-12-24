import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If no user is logged in, show a message and a back button
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF667eea),
        ),
        body: const Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white.withOpacity(0.1),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            // Fetch the user's document from the 'users' collection using their UID
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, snapshot) {
              // While waiting for data, show a loading spinner
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              // If an error occurs, show an error message
              if (snapshot.hasError) {
                return Center(child: Text('An error occurred: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              // If the document doesn't exist, show a message
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('User details not found.', style: TextStyle(color: Colors.white)));
              }

              // If data is successfully fetched, display it
              final userData = snapshot.data!.data();
              final String firstName = userData?['firstName'] ?? 'N/A';
              final String lastName = userData?['lastName'] ?? '';
              final String gender = userData?['gender'] ?? 'N/A';
              final String mobileNumber = userData?['mobile'] ?? 'N/A';
              final String email = user.email ?? 'N/A';

              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _showUpdatePhotoDialog(context, user.uid, userData?['photoUrl']),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: userData?['photoUrl'] != null && (userData!['photoUrl'] as String).isNotEmpty
                                  ? NetworkImage(userData['photoUrl'])
                                  : null,
                              child: (userData?['photoUrl'] == null || (userData!['photoUrl'] as String).isEmpty)
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showUpdatePhotoDialog(context, user.uid, userData?['photoUrl']),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Color(0xFF667eea), size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileItem(
                    icon: Icons.person,
                    title: 'Name',
                    subtitle: '$firstName $lastName',
                  ),
                  _buildProfileItem(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: email,
                  ),
                  _buildProfileItem(
                    icon: Icons.person_outline,
                    title: 'Gender',
                    subtitle: gender,
                  ),
                  _buildProfileItem(
                    icon: Icons.phone,
                    title: 'Mobile Number',
                    subtitle: mobileNumber,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
  Future<void> _showUpdatePhotoDialog(BuildContext context, String uid, String? currentUrl) async {
    final TextEditingController urlController = TextEditingController(text: currentUrl ?? '');
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile Picture'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/image.png',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'photoUrl': urlController.text.trim(),
                  });
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating photo: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}