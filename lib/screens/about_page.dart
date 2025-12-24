import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(context, 'App Information'),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, 'App', 'SoulSwaroop'),
                    _buildInfoRow(context, 'Version', '1.0 (Build 01)'),
                    _buildInfoRow(context, 'Developer', 'Team SoulSwaroop'),
                    const Divider(height: 32, thickness: 1, color: Colors.white24),
                    _buildHeader(context, 'Purpose'),
                    const SizedBox(height: 8),
                    const Text(
                      'This app is designed to support emotional well-being through AI-powered guidance, mood tracking and personalized mental wellness tools.',
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                      textAlign: TextAlign.justify,
                    ),
                    const Divider(height: 32, thickness: 1, color: Colors.white24),
                    _buildHeader(context, 'Permissions'),
                    const SizedBox(height: 8),
                    const Text(
                      'Requires storage access for saving notes and audio, notification access for reminders and internet access for AI-based personalized responses.',
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
