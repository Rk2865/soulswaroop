import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/ai_config.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Content> _history = [];
  
  // Using key from config

  String get _apiKey => AiConfig.apiKey; 
  
  late final GenerativeModel _model;
  ChatSession? _chatSession;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _userContextPrompt;

  // Chat message model for UI
  List<Map<String, dynamic>> _uiMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    try {
      // 1. Fetch User Context
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Parse Context
      String name = userData['firstName'] ?? 'User';
      String profession = "Unknown";
         if (userData['professionProfile'] != null) {
         profession = userData['professionProfile']['whatDoYouDo'] ?? "Unknown";
      }
      
      String mbti = "Unknown";
      if (userData['mbtiResult'] != null) {
        mbti = userData['mbtiResult']['type'] ?? "Unknown";
      }
      
      String enneagram = "Unknown";
      if (userData['enneagramResult'] != null) {
        enneagram = "Primary: ${userData['enneagramResult']['primaryType']}, Secondary: ${userData['enneagramResult']['secondaryType']}";
      }

      // 2. Build System Prompt
      _userContextPrompt = """
You are SoulSwaroop AI, a compassionate mental health and wellness assistant. 
You are speaking to $name.
User Profile:
- Profession: $profession
- MBTI Personality Type: $mbti
- Enneagram Type: $enneagram

Guidelines:
1. Personalize advice based on MBTI/Enneagram.
2. Consider profession context.
3. STRICT SAFETY: Refuse & refer for self-harm, suicide, violence, abuse.

If safety boundary is triggered: "I am an AI assistant and cannot provide the help you need right now. Please contacting a local emergency number."
""";

      // 3. Initialize Model
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 500,
        )
      );

      // 4. Load & Reconstruct History
      final historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_history')
          .orderBy('timestamp', descending: false)
          .get();

      _history.clear();
      
      // Inject System Prompt as first message context
      _history.add(Content.text(_userContextPrompt!));
      _history.add(Content.model([TextPart("Understood. I am ready to help.")]));

      for (var doc in historySnapshot.docs) {
        final data = doc.data();
        bool isUser = data['role'] == 'user';
        String message = data['message'];
        
        if (isUser) {
          _history.add(Content.text(message));
        } else {
          _history.add(Content.model([TextPart(message)]));
        }

        _uiMessages.add({
          'message': message,
          'isUser': isUser,
        });
      }

      _chatSession = _model.startChat(history: _history);

      if (mounted) {
        setState(() {
          _isInitializing = false;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        });
      }

    } catch (e) {
      debugPrint("Error initializing chat: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
           _uiMessages.add({
             'message': "Connection Error: $e\n\nPlease verify your internet connection and API Key permissions.",
             'isUser': false, 
             'isError': true
           });
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _clearChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('This will permanently delete your conversation history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // Delete from Firestore
      final batch = FirebaseFirestore.instance.batch();
      final snapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_history')
          .get();
      
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Reset
      setState(() {
        _uiMessages.clear();
        _history.clear();
        // Re-inject prompts
        _history.add(Content.text(_userContextPrompt!));
        _history.add(Content.model([TextPart("Understood. I'm ready to help.")]));

        _chatSession = _model.startChat(history: _history);
        _isLoading = false;
      });

    } catch (e) {
      debugPrint("Error clearing chat: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing chat: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _chatSession == null) return;

    _chatController.clear();
    setState(() {
      _uiMessages.add({'message': text, 'isUser': true});
      _isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Save User Message to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chat_history')
            .add({
          'role': 'user',
          'message': text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Generate AI Response
      final response = await _chatSession!.sendMessage(Content.text(text));
      final aiText = response.text ?? "I'm sorry, I couldn't process that.";

      // Check for safety block in response (simple heuristic, Gemini usually throws or returns empty if blocked)
      // We will just display whatever Gemini returned which should adhere to the system prompt guidelines.

      setState(() {
        _uiMessages.add({'message': aiText, 'isUser': false});
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      // Save AI Message to Firestore
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chat_history')
            .add({
          'role': 'model',
          'message': aiText,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

    } catch (e) {
      debugPrint("Error sending message: $e");
      setState(() {
        _uiMessages.add({
          'message': "Error: $e\n\nPossible fixes:\n1. Enable 'Google Generative AI API' in Google Cloud Console.\n2. Verify API Key permissions.\n3. Make sure your API key has access to the selected model.", 
          'isUser': false,
          'isError': true
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoulSwaroop AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF667eea),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: () => _clearChat(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFfdfbfb), Color(0xFFebedee)]),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isInitializing
                  ? const Center(child: CircularProgressIndicator())
                  : _uiMessages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _uiMessages.length,
                          itemBuilder: (context, index) {
                             return _buildMessageBubble(_uiMessages[index]);
                          },
                        ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LinearProgressIndicator(),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 80, color: Colors.purple.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              "Start your journey...",
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              "I'm here to listen and guide you based on your unique essence.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'];
    bool isError = msg['isError'] ?? false;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser 
              ? const Color(0xFF667eea) 
              : isError ? Colors.red.shade100 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          msg['message'],
          style: TextStyle(
            color: isUser ? Colors.white : (isError ? Colors.red : Colors.black87),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your thoughts...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF667eea),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
