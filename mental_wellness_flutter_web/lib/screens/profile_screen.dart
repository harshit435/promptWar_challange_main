import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/state_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final StateManager _state = StateManager();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _studyGoalController;

  String _targetExam = 'JEE';
  DateTime? _examDate;

  final List<String> _exams = [
    'JEE',
    'NEET',
    'UPSC',
    'CUET',
    'CAT',
    'GATE',
    'CBSE Boards',
    'ICSE Boards',
    'Other Competitive Exams',
  ];

  @override
  void initState() {
    super.initState();
    final profile = _state.profile;
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _studyGoalController = TextEditingController(
        text: profile.dailyStudyHoursGoal.toStringAsFixed(1));
    _targetExam = profile.targetExam;
    _examDate = profile.examDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _studyGoalController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(const Duration(days: 60)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF64FFDA),
              onPrimary: Color(0xFF0C0E1A),
              surface: Color(0xFF111422),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newProfile = UserProfile(
        id: _state.profile.id,
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 18,
        targetExam: _targetExam,
        examDate: _examDate,
        dailyStudyHoursGoal: double.tryParse(_studyGoalController.text) ?? 8.0,
      );

      await _state.updateProfile(newProfile);

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
                  'Aspirant target profile updated!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111422),
        title: const Text('Reset Sanctuary Data?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete all your logged journal entries, stress signatures, and shred counts. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _state.clearAllData();
      if (mounted) {
        setState(() {
          final profile = _state.profile;
          _nameController.text = profile.name;
          _ageController.text = profile.age.toString();
          _studyGoalController.text =
              profile.dailyStudyHoursGoal.toStringAsFixed(1);
          _targetExam = profile.targetExam;
          _examDate = profile.examDate;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset to defaults.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = Colors.white.withOpacity(0.02);
    final borderCol = Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Setting Form Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exam Preparation Targets',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Setting your target exam and date helps our inference engine compute countdown pressure zones.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 28),

                    // Name input
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                          'Your Nickname', Icons.badge_outlined),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Age input
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                          'Aspirant Age', Icons.calendar_today_outlined),
                      validator: (v) {
                        final val = int.tryParse(v ?? '');
                        if (val == null || val <= 0) return 'Enter a valid age';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Study Goal input
                    TextFormField(
                      controller: _studyGoalController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                          'Daily Study Hours Goal', Icons.menu_book_rounded),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0 || val > 24)
                          return 'Enter a valid value (0-24)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Exam Dropdown selection
                    DropdownButtonFormField<String>(
                      value: _targetExam,
                      dropdownColor: const Color(0xFF111422),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _buildInputDecoration(
                          'Target Competitive Exam', Icons.school_outlined),
                      items: _exams.map((exam) {
                        return DropdownMenuItem<String>(
                          value: exam,
                          child: Text(exam),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _targetExam = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Exam Target date
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded,
                                    color: Colors.white54),
                                const SizedBox(width: 12),
                                Text(
                                  _examDate == null
                                      ? 'Select Target Exam Date'
                                      : 'Exam Date: ${_examDate!.day}/${_examDate!.month}/${_examDate!.year}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white30, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64FFDA),
                          foregroundColor: const Color(0xFF0C0E1A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Update Target Info',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Danger Zone Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danger Zone',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset all data',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Clear all local files storage records, logs, and countdown progress.',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _clearData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.15),
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                          child: const Text('Clear Storage'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF64FFDA)),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.005),
    );
  }
}
