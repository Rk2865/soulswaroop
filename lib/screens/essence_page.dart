import 'package:flutter/material.dart';
import '../data/mbti_questions.dart';
import '../data/enneagram_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class EssencePage extends StatefulWidget {
  const EssencePage({super.key});

  @override
  State<EssencePage> createState() => _EssencePageState();
}

class _EssencePageState extends State<EssencePage> {
  final List<Map<String, dynamic>> _quizzes = [];

  @override
  void initState() {
    super.initState();
    _initializeQuizzes();
  }

  void _initializeQuizzes() {
    _quizzes.add({
      'name': 'MBTI Test',
      'emoji': '🧩',
      'description': 'Discover your personality type (Myers-Briggs).',
      'questions': [
        // E/I
        const Question(q: "After a long day, which helps you recharge more?", A: "Going out/talking", B: "Being alone", type: "EI"),
        const Question(q: "In social situations, you usually:", A: "Speak first, think later", B: "Think first, speak selectively", type: "EI"),
        const Question(q: "When attending events:", A: "Feel energized by the crowd", B: "Get drained and need recovery time", type: "EI"),
        const Question(q: "Your communication style is:", A: "Quick, expressive, spontaneous", B: "Measured, reflective, thoughtful", type: "EI"),
        const Question(q: "When meeting new people:", A: "Enjoy initiating conversation", B: "Wait for others to approach first", type: "EI"),
        // S/N
        const Question(q: "When learning something new, you prefer:", A: "Practical examples", B: "Concepts, theories, big-picture", type: "SN"),
        const Question(q: "Your attention naturally goes to:", A: "Details, facts, the present moment", B: "Patterns, possibilities, future implications", type: "SN"),
        const Question(q: "When remembering something:", A: "Recall concrete details", B: "Remember the overall meaning", type: "SN"),
        const Question(q: "Which appeals more?", A: "Step-by-step instructions", B: "Inventing your own method or theory", type: "SN"),
        const Question(q: "Your creativity works by:", A: "Improving existing things", B: "Imagining new, unusual ideas", type: "SN"),
        // T/F
        const Question(q: "When making decisions, you rely mostly on:", A: "Logic, objectivity", B: "Emotions, values", type: "TF"),
        const Question(q: "Which criticism bothers you more?", A: "Your work is incorrect", B: "You hurt someone without meaning to", type: "TF"),
        const Question(q: "In conflict, you tend to:", A: "Stay detached and focus on solutions", B: "Prioritize harmony and comfort", type: "TF"),
        const Question(q: "You judge success by:", A: "Efficiency, competence, results", B: "Meaningfulness, connection, well-being", type: "TF"),
        const Question(q: "You prefer to work in an environment where:", A: "Rules are fair & logical", B: "Relationships and empathy matter most", type: "TF"),
        // J/P
        const Question(q: "Your planning style:", A: "Structured plans, deadlines, order", B: "Flexible plans, spontaneity", type: "JP"),
        const Question(q: "When starting tasks:", A: "I finish one thing before moving", B: "I jump between tasks", type: "JP"),
        const Question(q: "Your workspace tends to be:", A: "Organized and predictable", B: "Creative chaos", type: "JP"),
        const Question(q: "How do you respond to sudden changes?", A: "Stressful – you prefer preparation", B: "Exciting – you enjoy adjusting", type: "JP"),
        const Question(q: "When approaching a long-term goal:", A: "You break it into steps", B: "You keep options open", type: "JP"),
      ],
    });
    
    _quizzes.add({
      'name': 'Enneagram Test',
      'emoji': '✨',
      'description': 'Find your Enneagram type (1-9).',
      'questions': enneagramQuestions,
    });
  }



  int? _selectedQuiz;
  int _currentQuestion = 0;
  List<int> _answers = [];
  int _totalScore = 0;
  String _quizResult = '';
  bool _isLoadingResult = false;
  bool _showResults = false;
  bool _isReadyToSubmit = false;

  // Profession Form State
  bool _showProfessionForm = false;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _livingController = TextEditingController();
  final _dreamLivingController = TextEditingController();
  bool _isSavingProfession = false;

  void _startQuiz(int quizIndex) {
    setState(() {
      _selectedQuiz = quizIndex;
      _currentQuestion = 0;
      _answers = [];
      _totalScore = 0;
      _quizResult = '';
      _showResults = false;
      _isReadyToSubmit = false;
    });
  }

  void _answerQuestion(int answerIndex) {
    setState(() {
      _answers.add(answerIndex);
      
      var currentQ = _quizzes[_selectedQuiz!]['questions'][_currentQuestion];
      if (currentQ is Question) {
        // MBTI logic handled at the end
      } else if (currentQ is EnneagramQuestion) {
        // Enneagram logic handled at the end (scores tracked in _answers)
      } else {
        _totalScore += (currentQ['scores'][answerIndex] as int);
      }
      
      if (_currentQuestion < _quizzes[_selectedQuiz!]['questions'].length - 1) {
        _currentQuestion++;
      } else {
        if (_quizzes[_selectedQuiz!]['name'] == 'MBTI Test' || _quizzes[_selectedQuiz!]['name'] == 'Enneagram Test') {
          _isReadyToSubmit = true;
        } else {
          _calculateResults();
        }
      }
    });
  }

  void _calculateResults() {
    setState(() {
      _isLoadingResult = true;
      _showResults = true; // Show results screen immediately
    });

    try {
      // Logic is now synchronous without AI calls
      
      final quiz = _quizzes[_selectedQuiz!];
      final maxScore = quiz['questions'].length * 4;
      final percentage = (_totalScore / maxScore * 100).round();
      
      String result = '';
      if (quiz['name'] == 'Work–Rest Balance Quiz') {
        if (percentage >= 75) {
          result = 'Excellent work-life balance! You have a healthy approach to work and rest.';
        } else if (percentage >= 50) {
          result = 'Good balance with room for improvement. Consider taking more breaks.';
        } else {
          result = 'Your work-life balance needs attention. Prioritize rest and self-care.';
        }
      } else if (quiz['name'] == 'MBTI Test') {
        int e = 0, i = 0, s = 0, n = 0, t = 0, f = 0, j = 0, p = 0;
        
        for (int k = 0; k < _answers.length; k++) {
           int answerIdx = _answers[k]; // 0 for A, 1 for B
           Question q = quiz['questions'][k];
           
           if (q.type == 'EI') {
             if (answerIdx == 0) e++; else i++;
           } else if (q.type == 'SN') {
             if (answerIdx == 0) s++; else n++;
           } else if (q.type == 'TF') {
             if (answerIdx == 0) t++; else f++;
           } else if (q.type == 'JP') {
             if (answerIdx == 0) j++; else p++;
           }
        }
        
        String type = "";
        type += (e >= i) ? "E" : "I";
        type += (s >= n) ? "S" : "N";
        type += (t >= f) ? "T" : "F";
        type += (j >= p) ? "J" : "P";
        
        var typeData = typeDescriptions[type]!;

        result = "Your Personality Type: $type — ${typeData['title']}\n\n${typeData['desc']}";

        // Save MBTI Result
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'mbtiResult': {
              'type': type,
              'resultString': result,
              'timestamp': FieldValue.serverTimestamp(),
            }
          }, SetOptions(merge: true));
        }
      } else if (quiz['name'] == 'Enneagram Test') {
         // Calculate Enneagram Results
         Map<int, int> typeScores = {};
         for (int i=1; i<=9; i++) typeScores[i] = 0;
         
         for (int k = 0; k < _answers.length; k++) {
           int score = _answers[k] + 1; // 0-4 index map to 1-5 score
           EnneagramQuestion q = quiz['questions'][k];
           typeScores[q.type] = (typeScores[q.type] ?? 0) + score;
         }
         
         var sortedScores = typeScores.entries.toList()
           ..sort((a, b) => b.value.compareTo(a.value));
           
         var primary = sortedScores[0];
         var secondary = sortedScores[1];
         
         // Assuming max possible score per type is not strictly 5 * 20 since questions are distributed. 
         // But per user request "max_score[type] = number_of_questions_for_that_type * 5".
         // We'll count questions per type dynamically.
         Map<int, int> typeCounts = {};
         for (var q in quiz['questions']) {
            if (q is EnneagramQuestion) {
              typeCounts[q.type] = (typeCounts[q.type] ?? 0) + 1;
            }
         }
         
         int maxPrimary = (typeCounts[primary.key] ?? 1) * 5;
         int percentage = ((primary.value / maxPrimary) * 100).round();
         
         var pType = enneagramTypes[primary.key]!;
         var sType = enneagramTypes[secondary.key]!;
         
         result = "Primary Type: ${primary.key} - ${pType.title}\n"
                  "Match: $percentage%\n\n"
                  "${pType.long}\n\n"
                  "---\n\n"
                  "Secondary Type: ${secondary.key} - ${sType.title}\n"
                  "${sType.long}";
         
         // Save Enneagram Result
         final user = FirebaseAuth.instance.currentUser;
         if (user != null) {
           FirebaseFirestore.instance.collection('users').doc(user.uid).set({
             'enneagramResult': {
               'resultString': result,
               'primaryType': primary.key,
               'secondaryType': secondary.key,
               'timestamp': FieldValue.serverTimestamp(),
             }
           }, SetOptions(merge: true));
         }
         
      } else if (quiz['name'] == 'Stress Level Assessment') {
        if (percentage >= 75) {
          result = 'You manage stress well! Keep up your healthy coping strategies.';
        } else if (percentage >= 50) {
          result = 'Moderate stress levels. Consider adding more stress management techniques.';
        } else {
          result = 'High stress levels detected. Please consider professional help and stress reduction strategies.';
        }
      } else if (quiz['name'] == 'Emotional Intelligence Quiz') {
        if (percentage >= 75) {
          result = 'High emotional intelligence! You have excellent self-awareness and empathy.';
        } else if (percentage >= 50) {
          result = 'Good emotional awareness with potential for growth in certain areas.';
        } else {
          result = 'Consider developing emotional intelligence through mindfulness and self-reflection.';
        }
      }
      
      setState(() {
        _quizResult = result;
        _isLoadingResult = false;
        _showResults = true;
      });
    } catch (e) {
      setState(() {
        _quizResult = 'Unable to generate results. Please try again.';
        _isLoadingResult = false;
        _showResults = true;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _selectedQuiz = null;
      _currentQuestion = 0;
      _answers = [];
      _totalScore = 0;
      _quizResult = '';
      _showResults = false;
      _isReadyToSubmit = false;
      _showProfessionForm = false;
      _nameController.clear();
      _ageController.clear();
      _sexController.clear();
      _livingController.clear();
      _dreamLivingController.clear();
    });
  }

  Future<void> _saveProfessionData() async {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _sexController.text.isEmpty ||
        _livingController.text.isEmpty ||
        _dreamLivingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isSavingProfession = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'professionProfile': {
            'name': _nameController.text.trim(),
            'age': _ageController.text.trim(),
            'sex': _sexController.text.trim(),
            'currentLiving': _livingController.text.trim(),
            'dreamLiving': _dreamLivingController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          }
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profession details saved successfully!')),
          );
          _resetQuiz(); // Go back to main selection
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfession = false;
        });
      }
    }
  }

  Future<void> _fetchProfessionData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('professionProfile')) {
          final data = doc.data()!['professionProfile'] as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _ageController.text = data['age'] ?? '';
            _sexController.text = data['sex'] ?? '';
            _livingController.text = data['currentLiving'] ?? '';
            _dreamLivingController.text = data['dreamLiving'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching profession data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showProfessionForm) {
      return _buildProfessionForm();
    } else if (_selectedQuiz == null) {
      return _buildQuizSelection();
    } else if (_showResults) {
      return _buildResults();
    } else if (_isReadyToSubmit) {
       return _buildSubmitPage();
    } else {
      return _buildQuiz();
    }
  }

  Widget _buildSubmitPage() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 80),
              const SizedBox(height: 24),
              const Text(
                "All questions answered!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Ready to generate your personality analysis?",
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _calculateResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2), // Matches other buttons
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _showProfessionForm = false;
              });
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Profession Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildProfessionTextField(_nameController, "Enter Your Name"),
                const SizedBox(height: 16),
                _buildProfessionTextField(_ageController, "Enter Your Age", isNumber: true),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Your Sex",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _sexController.text.isNotEmpty && ["Male", "Female", "Nonbinary"].contains(_sexController.text) ? _sexController.text : null,
                      dropdownColor: const Color(0xFF333333),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: ["Male", "Female", "Nonbinary"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _sexController.text = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfessionTextField(_livingController, "What do you do for a Living"),
                const SizedBox(height: 16),
                _buildProfessionTextField(_dreamLivingController, "If Money wasn't a factor, What would you do for a living?"),
                const SizedBox(height: 32),
                _isSavingProfession
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ElevatedButton(
                        onPressed: _saveProfessionData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            filled: true,
            fillColor: Colors.black12,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Personal Exploration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    int index = _quizzes.indexWhere((q) => q['name'] == 'MBTI Test');
                    if (index != -1) {
                      // Check for saved result
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                          if (doc.exists && doc.data()!.containsKey('mbtiResult')) {
                            final mbtiData = doc.data()!['mbtiResult'] as Map<String, dynamic>;
                            setState(() {
                              _selectedQuiz = index;
                              _quizResult = mbtiData['resultString'];
                              _showResults = true;
                              _isLoadingResult = false;
                            });
                            return;
                          }
                        } catch (e) {
                          debugPrint("Error fetching MBTI result: $e");
                        }
                      }
                      _startQuiz(index);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: MBTI Test not found')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('MBTI Test', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                     int index = _quizzes.indexWhere((q) => q['name'] == 'Enneagram Test');
                    if (index != -1) {
                      // Check for saved result
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                          if (doc.exists && doc.data()!.containsKey('enneagramResult')) {
                            final enneagramData = doc.data()!['enneagramResult'] as Map<String, dynamic>;
                            setState(() {
                              _selectedQuiz = index;
                              _quizResult = enneagramData['resultString'];
                              _showResults = true;
                              _isLoadingResult = false;
                            });
                            return;
                          }
                        } catch (e) {
                          debugPrint("Error fetching Enneagram result: $e");
                        }
                      }
                      _startQuiz(index);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: Enneagram Test not found')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Enneagram Test', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                     _fetchProfessionData();
                     setState(() {
                       _showProfessionForm = true;
                     });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Profession', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.1),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Column(
              children: [
                Text(
                  'Psychological Patterns & Disorders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: () => _startQuiz(_quizzes.indexOf(quiz)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Text(
              quiz['emoji'],
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final quiz = _quizzes[_selectedQuiz!];
    final question = quiz['questions'][_currentQuestion];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            quiz['name'],
            Icons.quiz,
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: _resetQuiz,
                        icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  ],
                ),
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / quiz['questions'].length,
                  backgroundColor: const Color.fromRGBO(255, 255, 255, 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Question ${_currentQuestion + 1} of ${quiz['questions'].length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Question
                // Question Title (Only for non-Enneagram, as Enneagram has its own styled box below)
                if (question is! EnneagramQuestion) ...[
                  Text(
                    question is Question ? question.q : question['question'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Answer options
                // Answer options
                if (question is Question) ...[
                  // MBTI and others - Keep existing layout style for them
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _answerQuestion(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              question.A,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _answerQuestion(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                            child: Text(
                                'B',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              question.B,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (question is EnneagramQuestion) ...[
                   // BOX 1: Question
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: const Color.fromRGBO(255, 255, 255, 0.1),
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: Colors.white.withOpacity(0.2)),
                     ),
                     child: Text(
                       question.text,
                       style: const TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.w600,
                         color: Colors.white,
                         height: 1.4,
                       ),
                       textAlign: TextAlign.center,
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // BOX 2: Options (1-5 Scale)
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: const Color.fromRGBO(255, 255, 255, 0.1),
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: Colors.white.withOpacity(0.2)),
                     ),
                     child: GridView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 5,
                         crossAxisSpacing: 8,
                         mainAxisSpacing: 8,
                         childAspectRatio: 0.5,
                       ),
                       itemCount: 5,
                       itemBuilder: (context, index) {
                          final labels = ["Never", "Rarely", "Sometime", "Often", "Always"];
                          return InkWell(
                            onTap: () => _answerQuestion(index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  labels[index],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                       },
                     ),
                   ),
                ] else
                // Default handling for other quizzes
                ...question['options'].asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _answerQuestion(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final quiz = _quizzes[_selectedQuiz!];
    final maxScore = quiz['questions'].length * 4;
    final percentage = (_totalScore / maxScore * 100).round();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Quiz Results',
            Icons.analytics,
            Column(
              children: [
                // Score display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        quiz['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (quiz['name'] != 'MBTI Test' && quiz['name'] != 'Enneagram Test') ...[
                        const Text(
                          'Your Score',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_totalScore / $maxScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // AI-generated result
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personalized Analysis:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingResult)
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                "Please wait just a second to generate your results...",
                                style: TextStyle(color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          _quizResult,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    if (quiz['name'] == 'MBTI Test' || quiz['name'] == 'Enneagram Test') ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _startQuiz(_selectedQuiz!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Test Again'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
