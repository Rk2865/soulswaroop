
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MindGardenPage extends StatefulWidget {
  const MindGardenPage({super.key});

  @override
  State<MindGardenPage> createState() => _MindGardenPageState();
}

class _MindGardenPageState extends State<MindGardenPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingFile;

  // Updated to match the files in assets/audio/
  final List<Map<String, String>> _whiteMusicOptions = [
    {'name': 'Rain', 'emoji': '🌧️', 'file': 'Rain.mp3'},
    {'name': 'Ocean Waves', 'emoji': '🌊', 'file': 'Ocean Waves.mp3'},
    {'name': 'Forest Birds', 'emoji': '🌲', 'file': 'Forest Birds.mp3'},
    {'name': 'Thunderstorm', 'emoji': '⚡', 'file': 'Thunderstorm.mp3'},
    {'name': 'Fireplace', 'emoji': '🔥', 'file': 'Fireplace Crackling.mp3'},
    {'name': 'City', 'emoji': '🏙️', 'file': 'City.mp3'},
  ];

  // --- Placeholder data from the original file ---
  bool _isLoadingLesson = false;
  String _lifeLessonText = '';
  final List<Map<String, dynamic>> _lifeLessons = [
    {'topic': 'Time Management', 'emoji': '⏰'},
    {'topic': 'Stress Control', 'emoji': '🧘'},
    {'topic': 'Self Care', 'emoji': '💆'},
    {'topic': 'Relationships', 'emoji': '💕'},
    {'topic': 'Career Growth', 'emoji': '📈'},
    {'topic': 'Financial Health', 'emoji': '💰'},
    {'topic': 'Physical Health', 'emoji': '💪'},
    {'topic': 'Mental Clarity', 'emoji': '🧠'},
  ];
  final Map<String, List<Map<String, dynamic>>> _meditationOptions = {
    'Time Spans': [
      {'name': '5 Minutes', 'duration': 300},
      {'name': '10 Minutes', 'duration': 600},
    ],
    'Sleep Regulation': [
      {'name': 'Deep Sleep', 'frequency': 40},
      {'name': 'Light Sleep', 'frequency': 60},
    ],
    'Pranayama & Breathwork': [
      {'name': 'Box Breathing', 'pattern': '4-4-4-4'},
      {'name': '4-7-8 Breathing', 'pattern': '4-7-8'},
    ],
  };
  // --- End of placeholder data ---


  @override
  void initState() {
    super.initState();
    // When the player finishes a song, update the UI
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _currentlyPlayingFile = null;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(String fileName) async {
    try {
      if (_currentlyPlayingFile == fileName) {
        // If the clicked sound is already playing, stop it.
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingFile = null;
        });
      } else {
        // If a different sound is playing (or no sound), start the new one.
        await _audioPlayer.play(AssetSource('audio/$fileName'));
        setState(() {
          _currentlyPlayingFile = fileName;
        });
      }
    } catch (e) {
      // Handle potential errors, e.g., file not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing sound: $e')),
      );
      setState(() {
        _currentlyPlayingFile = null;
      });
    }
  }

  // --- Placeholder functions from the original file ---
  Future<void> _getLifeLesson(String topic) async {/* ... */}
  Future<void> _startMeditation(String type, Map<String, dynamic> option) async {/* ... */}
  // --- End of placeholder functions ---


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // White Music Section
          _buildSection(
            'White Music',
            Icons.music_note,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _whiteMusicOptions.length,
              itemBuilder: (context, index) {
                final option = _whiteMusicOptions[index];
                final bool isActive = _currentlyPlayingFile == option['file'];
                
                return GestureDetector(
                  onTap: () => _toggleSound(option['file']!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option['emoji']!,
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            option['name']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isActive)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Icon(
                              Icons.volume_up, // Changed from stop to volume up
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Life Lessons Section (Placeholder UI)
          _buildSection(
            'Life Lessons',
            Icons.school,
            const Text('Life lessons content goes here.', style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 16),

          // Guided Meditation Section (Placeholder UI)
          _buildSection(
            'Guided Meditation',
            Icons.self_improvement,
            const Text('Guided meditation content goes here.', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper widget to build consistent section styling
  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
