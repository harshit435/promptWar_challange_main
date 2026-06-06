import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'storage_stub.dart' if (dart.library.html) 'storage_web.dart';
import '../models/mood_entry.dart';
import '../models/user_profile.dart';

class StateManager extends ChangeNotifier {
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  List<MoodEntry> _entries = [];
  UserProfile? _profile;
  int _shreddedThoughtsCount = 0;
  bool _isLoading = true;

  List<MoodEntry> get entries => _entries;
  UserProfile get profile =>
      _profile ??
      UserProfile(
        id: 'default',
        name: 'Aspirant',
        age: 18,
        targetExam: 'JEE',
        examDate: DateTime.now().add(const Duration(days: 60)),
        dailyStudyHoursGoal: 8.0,
      );
  int get shreddedThoughtsCount => _shreddedThoughtsCount;
  bool get isLoading => _isLoading;

  static const String _entriesKey = 'zenprep_entries_v1';
  static const String _profileKey = 'zenprep_profile_v1';
  static const String _shredKey = 'zenprep_shred_v1';

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Load entries from localStorage via helper
        final entriesData = StorageHelper.load(_entriesKey);
        if (entriesData != null) {
          final List<dynamic> decoded =
              jsonDecode(entriesData) as List<dynamic>;
          _entries = decoded
              .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          // Fallback to sample assets if empty
          await _loadSampleData();
        }

        // Load profile from localStorage via helper
        final profileData = StorageHelper.load(_profileKey);
        if (profileData != null) {
          _profile = UserProfile.fromJson(
              jsonDecode(profileData) as Map<String, dynamic>);
        } else {
          _profile = UserProfile(
            id: 'aspirant_1',
            name: 'Aspirant',
            age: 18,
            targetExam: 'JEE',
            examDate: DateTime.now().add(const Duration(days: 60)),
            dailyStudyHoursGoal: 8.0,
          );
          _saveProfile();
        }

        // Load shred count
        final shredData = StorageHelper.load(_shredKey);
        if (shredData != null) {
          _shreddedThoughtsCount = int.tryParse(shredData) ?? 0;
        }
      } else {
        // Fallback for non-web environments (desktop/testing)
        await _loadSampleData();
        _profile = UserProfile(
          id: 'aspirant_1',
          name: 'Aspirant (Desktop Test)',
          age: 18,
          targetExam: 'JEE',
          examDate: DateTime.now().add(const Duration(days: 45)),
          dailyStudyHoursGoal: 8.0,
        );
      }
    } catch (e) {
      debugPrint("Error loading local state: $e");
      // Fallback
      _entries = [];
      _profile = UserProfile(
        id: 'aspirant_1',
        name: 'Aspirant',
        age: 18,
        targetExam: 'JEE',
        examDate: DateTime.now().add(const Duration(days: 30)),
        dailyStudyHoursGoal: 8.0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSampleData() async {
    try {
      final s = await rootBundle.loadString('assets/sample_data.json');
      final List<dynamic> arr = jsonDecode(s) as List<dynamic>;
      _entries = arr
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _saveEntries();
    } catch (e) {
      debugPrint("Error loading sample assets: $e");
      _entries = [];
    }
  }

  void _saveEntries() {
    if (kIsWeb) {
      final String serialized =
          jsonEncode(_entries.map((e) => e.toJson()).toList());
      StorageHelper.save(_entriesKey, serialized);
    }
  }

  void _saveProfile() {
    if (kIsWeb && _profile != null) {
      StorageHelper.save(_profileKey, jsonEncode(_profile!.toJson()));
    }
  }

  Future<void> addEntry(MoodEntry entry) async {
    _entries.insert(0, entry);
    _saveEntries();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    _saveProfile();
    notifyListeners();
  }

  Future<void> incrementShredCount() async {
    _shreddedThoughtsCount++;
    if (kIsWeb) {
      StorageHelper.save(_shredKey, _shreddedThoughtsCount.toString());
    }
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _entries.clear();
    _shreddedThoughtsCount = 0;
    _profile = UserProfile(
      id: 'aspirant_1',
      name: 'Aspirant',
      age: 18,
      targetExam: 'JEE',
      examDate: DateTime.now().add(const Duration(days: 60)),
      dailyStudyHoursGoal: 8.0,
    );
    if (kIsWeb) {
      StorageHelper.remove(_entriesKey);
      StorageHelper.remove(_profileKey);
      StorageHelper.remove(_shredKey);
    }
    notifyListeners();
  }
}
