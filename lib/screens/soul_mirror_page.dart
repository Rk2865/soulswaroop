
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';


class SoulMirrorPage extends StatefulWidget {
  const SoulMirrorPage({super.key});

  @override
  State<SoulMirrorPage> createState() => _SoulMirrorPageState();
}

class _SoulMirrorPageState extends State<SoulMirrorPage> {
  final TextEditingController _notepadController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  String? _selectedNoteId;
  bool _isSavingNote = false;

// _tasks list removed in favor of StreamBuilder
  bool _isLoadingActivity = false;
  String _bedtimeActivity = '';

  String get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated state appropriately, maybe return generic id or throw
      return 'guest'; 
    }
    return user.uid;
  }

  void _startNewNote() {
    setState(() {
      _selectedNoteId = null;
      _notepadController.clear();
    });
  }

  Future<void> _saveNote() async {
    if (_notepadController.text.trim().isEmpty) return;
    if (FirebaseAuth.instance.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to save notes')));
        return;
    }

    setState(() => _isSavingNote = true);

    try {
      final content = _notepadController.text.trim();
      final now = DateTime.now();
      final userNotesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('notes');

      if (_selectedNoteId == null) {
        // Create new
        await userNotesRef.add({
          'content': content,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
        _startNewNote(); // Clear after save or keep? Usually, keep for editing. But user might want to write next. Let's keep it open but set ID so next save looks like update.
        // Actually, to set ID I need the Ref.
        // Let's change flow: Save updates the stream, clearer to just clear or show "Saved".
        // Better UX: After save, if it was new, now it is an edit state of that new note.
        // But finding the ID of added doc needs the ref.
        // Simple version: clear after safe.
        _startNewNote();
      } else {
        // Update existing
        await userNotesRef.doc(_selectedNoteId).update({
          'content': content,
          'updatedAt': Timestamp.fromDate(now),
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving note')));
      }
    } finally {
      if (mounted) setState(() => _isSavingNote = false);
    }
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('notes')
          .doc(noteId)
          .delete();
      
      if (_selectedNoteId == noteId) {
        _startNewNote();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting note')));
    }
  }

  void _selectNote(String id, String content) {
    setState(() {
      _selectedNoteId = id;
      _notepadController.text = content;
    });
  }

  @override
  void dispose() {
    _notepadController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to add tasks')));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
        'text': _taskController.text.trim(),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _taskController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error adding task')));
      }
    }
  }

  Future<void> _toggleTask(String id, bool currentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(id)
          .update({'isCompleted': !currentStatus});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating task')));
      }
    }
  }

  Future<void> _deleteTask(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(id)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting task')));
      }
    }
  }

  void _getBedtimeActivity(String mood) {
    String activity = '';
    switch (mood) {
      case 'sad':
        activity =
            "Enhance your tonight’s routine by performing 10 minutes of guided or 4‑7‑8 style breathing to calm the nervous system.​ Then write 3 small things you are grateful for (people, moments, comforts) to gently shift focus from stress to supportive thoughts.​";
        break;
      case 'okay':
        activity =
            "Enhance your tonight’s routine by performing 5–10 minutes of slow breathing or body scan (in bed, lights low).​ Then write 3 things that went fine or “could have been worse” plus 1 intention for tomorrow, which helps organize thoughts and reduce pre‑sleep worry.​";
        break;
      case 'neutral':
        activity =
            "Enhance your tonight’s routine by performing 5–10 minutes of slow breathing or body scan (in bed, lights low).​ Then write 2 things that went fine or “could have been worse” plus 2 intentions for tomorrow, which help organize thoughts and reduce pre‑sleep worry.​";
        break;
      case 'good':
        activity =
            "Enhance your tonight’s routine by performing 5 minutes of relaxed breathing.​ Then write 3 things you’re grateful for from the day, focusing on what you want “more of” in future days.​ Finish with 10–15 minutes of soft white noise or nature sounds.​";
        break;
      case 'great':
        activity =
            "Enhance your tonight’s routine by performing short wind‑down only: 3–5 minutes of calm breathing just to signal sleep time.​ Write a quick “highlight of the day” plus 2 gratitudes to reinforce positive mood and future motivation.​ Play white noise / relaxing music until sleep.";
        break;
      default:
        activity = "Take some time to relax and unwind before bed.";
    }

    setState(() {
      _bedtimeActivity = activity;
    });
  }

  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reminder Section
          _buildGlassSection(
            'Reminders',
            Icons.notifications_active_outlined,
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFdad7cd).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('reminders').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No reminders yet. Check back later!',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load reminders.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  var reminders = snapshot.data!.docs;

                  return PageView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      var reminderData = reminders[index].data() as Map<String, dynamic>;
                      String text = reminderData['text'] ?? 'No content';

                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Notepad Section
          _buildGlassSection(
            'Notepad',
            Icons.edit_note_rounded,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _startNewNote,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text('New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFdad7cd).withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSavingNote ? null : _saveNote,
                      icon: _isSavingNote
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2))
                          : Icon(_selectedNoteId != null ? Icons.update_rounded : Icons.save_rounded, size: 18),
                      label: Text(_selectedNoteId != null ? 'Update' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFdad7cd),
                        foregroundColor: const Color(0xFF344e41), // Dark aesthetic green for text
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notepadController,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts here...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFdad7cd).withOpacity(0.95),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
                const SizedBox(height: 24),
                
                if (FirebaseAuth.instance.currentUser != null) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        "Saved Notes",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFdad7cd).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('notes')
                              .orderBy('updatedAt', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text('No saved notes yet.', style: TextStyle(color: Colors.grey[400])),
                              ],
                            ),
                          );
                        }

                        final notes = snapshot.data!.docs;

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notes.length,
                          separatorBuilder: (ctx, i) => Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final doc = notes[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final content = data['content'] as String? ?? '';
                            final timestamp = data['updatedAt'] as Timestamp?;
                            final dateStr = timestamp != null
                                ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                                : "?";

                            return ListTile(
                              title: Text(
                                content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                dateStr,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () => _deleteNote(doc.id),
                              ),
                              onTap: () => _selectNote(doc.id, content),
                              selected: _selectedNoteId == doc.id,
                              selectedTileColor: const Color(0xFF667eea).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Daily Planner Section
          _buildGlassSection(
            'Daily Planner',
            Icons.checklist_rounded,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Add a new task...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFdad7cd).withOpacity(0.95),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFdad7cd),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add_rounded, color: Color(0xFF344e41)),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFdad7cd).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseAuth.instance.currentUser != null
                        ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('tasks')
                            .orderBy('createdAt', descending: true)
                            .snapshots()
                        : null,
                    builder: (context, snapshot) {
                      if (FirebaseAuth.instance.currentUser == null) {
                         return const Center(child: Text('Please login to view your planner.'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final docs = snapshot.data?.docs ?? [];
                      final tasks = docs.map((doc) => Task.fromSnapshot(doc)).toList();
                      
                      final completedTasks = tasks.where((t) => t.isCompleted).length;
                      final totalTasks = tasks.length;
                      
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildTaskStat('Done', completedTasks, Colors.teal, Icons.check_circle_rounded)), // Changed to teal for better contrast with bg
                              const SizedBox(width: 12),
                              Expanded(child: _buildTaskStat('To Do', totalTasks, const Color(0xFF344e41), Icons.format_list_bulleted_rounded)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 16),
                          if (tasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No tasks yet. Start planning!',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...tasks.map((task) => _buildTaskItem(task)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Rate the Day Section
          _buildGlassSection(
            'Rate the Day',
            Icons.sentiment_satisfied_rounded,
            Column(
              children: [
                const Text(
                  'How was your day?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMoodButton('😢', 'Sad', () => _getBedtimeActivity('sad'), Colors.blueGrey),
                      const SizedBox(width: 12),
                      _buildMoodButton('😐', 'Okay', () => _getBedtimeActivity('okay'), Colors.blue),
                      const SizedBox(width: 12),
                      _buildMoodButton('😑', 'Neutral', () => _getBedtimeActivity('neutral'), Colors.teal),
                      const SizedBox(width: 12),
                      _buildMoodButton('😊', 'Good', () => _getBedtimeActivity('good'), Colors.orange),
                      const SizedBox(width: 12),
                      _buildMoodButton('😄', 'Great', () => _getBedtimeActivity('great'), Colors.pink),
                    ],
                  ),
                ),
                if (_bedtimeActivity.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFdad7cd).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.nights_stay_rounded, color: Color(0xFF344e41), size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Suggested Bedtime Activity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF344e41),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _bedtimeActivity,
                          style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                        ),
                        if (_isLoadingActivity)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildGlassSection(String title, IconData icon, Widget content) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStat(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _toggleTask(task.id, task.isCompleted),
            activeColor: Colors.green,
          ),
          Expanded(
            child: Text(
              task.text,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _deleteTask(task.id),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String label, VoidCallback onTap, Color activeColor) {
    bool isSelected = _bedtimeActivity.isNotEmpty &&
        ((label == 'Sad' && _bedtimeActivity.contains('10 minutes of guided')) ||
            (label == 'Okay' && _bedtimeActivity.contains('things that went fine')) ||
            (label == 'Neutral' && _bedtimeActivity.contains('2 intentions')) ||
            (label == 'Good' && _bedtimeActivity.contains('what you want “more of”')) ||
            (label == 'Great' && _bedtimeActivity.contains('short wind‑down')));
    
    // Fallback simple selection if text doesn'match exactly (allows improved logic later)
    // For now, let's just show feedback on tap
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  final String id;
  final String text;
  final bool isCompleted;

  Task({
    required this.id,
    required this.text,
    required this.isCompleted,
  });

  factory Task.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      text: data['text'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
