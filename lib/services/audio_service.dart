import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentTrack;
  Timer? _audioTimer;

  bool get isPlaying => _isPlaying;
  String? get currentTrack => _currentTrack;

  // Generate different types of ambient sounds
  Future<void> playWhiteMusic(String trackName) async {
    try {
      // Stop current audio if playing
      if (_isPlaying) {
        await stopAudio();
      }

      _currentTrack = trackName;
      _isPlaying = true;

      // Simulate ambient sound with timer-based approach
      await _playAmbientSound(trackName);
      
    } catch (e) {
      _isPlaying = false;
      _currentTrack = null;
      print('Error playing audio: $e');
    }
  }

  Future<void> _playAmbientSound(String trackName) async {
    // Simulate different ambient sounds with different durations
    int duration = 30; // 30 seconds for demo
    
    // Handle white music tracks
    switch (trackName) {
      case 'Rain':
        duration = 60;
        break;
      case 'Ocean':
        duration = 45;
        break;
      case 'Forest':
        duration = 50;
        break;
      case 'Wind':
        duration = 40;
        break;
      case 'Thunder':
        duration = 35;
        break;
      case 'Birds':
        duration = 55;
        break;
      // Handle meditation tracks
      default:
        if (trackName.startsWith('time_')) {
          duration = 30; // 30 seconds for time-based meditation
        } else if (trackName.startsWith('sleep_')) {
          duration = 25; // 25 seconds for sleep regulation
        } else if (trackName.startsWith('breath_')) {
          duration = 20; // 20 seconds for breathing exercises
        }
        break;
    }

    // Use timer for better control
    _audioTimer = Timer(Duration(seconds: duration), () {
      _isPlaying = false;
      _currentTrack = null;
    });
  }

  Future<void> stopAudio() async {
    try {
      _audioTimer?.cancel();
      _audioTimer = null;
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentTrack = null;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  void dispose() {
    _audioTimer?.cancel();
    _audioPlayer.dispose();
  }
}
