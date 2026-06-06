import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/state_manager.dart';

class EntryFormScreen extends StatefulWidget {
  final bool isNavigatingFromShell;

  const EntryFormScreen({super.key, this.isNavigatingFromShell = false});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StateManager _state = StateManager();

  int _mood = 6;
  int _stress = 4;
  double _sleepHours = 7.0;
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _reframingController = TextEditingController();

  final List<String> _availableTags = [
    'Mock Test',
    'Syllabus Backlog',
    'Peer Pressure',
    'Parental Expectations',
    'Lack of Sleep',
    'Time Management',
    'Self-Doubt',
    'Exam Day Dread',
    'Physics',
    'Chemistry',
    'Maths/Biology',
    'General Study',
  ];

  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _scoreController.dispose();
    _noteController.dispose();
    _reframingController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final double? score = double.tryParse(_scoreController.text);
      final entry = MoodEntry(
        timestamp: DateTime.now(),
        mood: _mood,
        stressLevel: _stress,
        sleepHours: _sleepHours,
        mockTestScore: score,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        reframingNote: _reframingController.text.isEmpty
            ? null
            : _reframingController.text,
        tags: _selectedTags.toList(),
      );

      await _state.addEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF64FFDA)),
                SizedBox(width: 12),
                Text(
                  'Reflection entry saved to your Sanctuary.',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );

        if (!widget.isNavigatingFromShell) {
          Navigator.pop(context, entry);
        } else {
          // Reset form fields
          setState(() {
            _mood = 6;
            _stress = 4;
            _sleepHours = 7.0;
            _selectedTags.clear();
            _scoreController.clear();
            _noteController.clear();
            _reframingController.clear();
          });
        }
      }
    }
  }

  String _getMoodEmoji(int moodVal) {
    if (moodVal <= 2) return '😩'; // Exhausted/Awful
    if (moodVal <= 4) return '🙁'; // Stressed/Down
    if (moodVal <= 6) return '😐'; // Neutral/Okay
    if (moodVal <= 8) return '😊'; // Good/Focused
    return '🚀'; // Flow state/Excellent
  }

  String _getStressEmoji(int stressVal) {
    if (stressVal <= 2) return '🧘'; // Calm
    if (stressVal <= 5) return '⏰'; // Moderate study pressure
    if (stressVal <= 8) return '🔥'; // High stress
    return '🌋'; // Critical panic/burnout
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = Colors.white.withOpacity(0.02);
    final borderCol = Colors.white.withOpacity(0.05);

    final formWidget = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood & Stress Slider Group
          _buildFormCard(
            title: 'How is your focus and energy today?',
            bg: cardBg,
            border: borderCol,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mood / Flow State',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '${_getMoodEmoji(_mood)} $_mood / 10',
                      style: const TextStyle(
                          color: Color(0xFF64FFDA),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _mood.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: const Color(0xFF64FFDA),
                  inactiveColor: Colors.white12,
                  onChanged: (v) => setState(() => _mood = v.round()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stress / Exam Pressure',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '${_getStressEmoji(_stress)} $_stress / 10',
                      style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _stress.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white12,
                  onChanged: (v) => setState(() => _stress = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sleep & Mock test scores
          _buildFormCard(
            title: 'Aspirant Health & Mock Tests',
            bg: cardBg,
            border: borderCol,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sleep Hours Last Night',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '${_sleepHours.toStringAsFixed(1)} Hours',
                      style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _sleepHours,
                  min: 2,
                  max: 12,
                  divisions: 20,
                  activeColor: Colors.lightBlueAccent,
                  inactiveColor: Colors.white12,
                  onChanged: (v) => setState(() => _sleepHours = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scoreController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Latest Mock Test Score % (Optional)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF64FFDA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon:
                        const Icon(Icons.quiz_rounded, color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Academic Triggers (Tags selection)
          _buildFormCard(
            title: 'Identify Stress Triggers',
            bg: cardBg,
            border: borderCol,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? const Color(0xFF0C0E1A) : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF64FFDA),
                  backgroundColor: Colors.white.withOpacity(0.04),
                  checkmarkColor: const Color(0xFF0C0E1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF64FFDA)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Worry & Reframer Section (Cognitive Behavioral Therapy Technique)
          _buildFormCard(
            title: 'Cognitive Reframing (Worry Shredder)',
            bg: cardBg,
            border: borderCol,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Brain Dump (What is raising your anxiety?):',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. "I am stressed that the physics mock test score was low and I am falling behind in backlogs."',
                    hintStyle:
                        const TextStyle(color: Colors.white24, fontSize: 13),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF64FFDA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2. Rational Reframe (What is a constructive statement or what can you control?):',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reframingController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. "Mock tests are meant to show gaps. I will spend 1 hour resolving mock errors and stick to my backlog revision block tomorrow."',
                    hintStyle:
                        const TextStyle(color: Colors.white24, fontSize: 13),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF64FFDA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64FFDA),
                foregroundColor: const Color(0xFF0C0E1A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFF64FFDA).withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_as_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Sanctuary Log',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );

    if (!widget.isNavigatingFromShell) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C0E1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Add Reflection Journal',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: formWidget,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: formWidget,
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required Widget child,
    required Color bg,
    required Color border,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
