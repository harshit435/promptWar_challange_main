import 'package:flutter_test/flutter_test.dart';
import 'package:mental_wellness_flutter_web/models/mood_entry.dart';
import 'package:mental_wellness_flutter_web/models/user_profile.dart';
import 'package:mental_wellness_flutter_web/services/inference_service.dart';

void main() {
  group('Data Model Tests', () {
    test('MoodEntry JSON serialization & deserialization', () {
      final entry = MoodEntry(
        timestamp: DateTime.parse('2026-06-06T12:00:00Z'),
        mood: 8,
        stressLevel: 3,
        sleepHours: 7.5,
        mockTestScore: 92.5,
        note: 'Feeling prepared',
        reframingNote: 'I can do this',
        tags: ['UPSC', 'Mock Test'],
      );

      final json = entry.toJson();
      expect(json['mood'], 8);
      expect(json['stressLevel'], 3);
      expect(json['sleepHours'], 7.5);
      expect(json['mockTestScore'], 92.5);
      expect(json['note'], 'Feeling prepared');
      expect(json['reframingNote'], 'I can do this');
      expect(json['tags'], containsAll(['UPSC', 'Mock Test']));

      final deserialized = MoodEntry.fromJson(json);
      expect(deserialized.mood, 8);
      expect(deserialized.stressLevel, 3);
      expect(deserialized.sleepHours, 7.5);
      expect(deserialized.mockTestScore, 92.5);
      expect(deserialized.note, 'Feeling prepared');
      expect(deserialized.reframingNote, 'I can do this');
      expect(deserialized.tags, containsAll(['UPSC', 'Mock Test']));
    });

    test('UserProfile JSON serialization & deserialization', () {
      final profile = UserProfile(
        id: 'aspirant_test_1',
        name: 'Amit',
        age: 19,
        targetExam: 'JEE',
        examDate: DateTime.parse('2026-08-15T00:00:00Z'),
        dailyStudyHoursGoal: 9.0,
      );

      final json = profile.toJson();
      expect(json['name'], 'Amit');
      expect(json['age'], 19);
      expect(json['targetExam'], 'JEE');
      expect(json['dailyStudyHoursGoal'], 9.0);

      final deserialized = UserProfile.fromJson(json);
      expect(deserialized.name, 'Amit');
      expect(deserialized.age, 19);
      expect(deserialized.targetExam, 'JEE');
      expect(deserialized.dailyStudyHoursGoal, 9.0);
    });
  });

  group('InferenceService Wellness Analysis Tests', () {
    final inference = InferenceService();
    final profile = UserProfile(
      id: 'test_1',
      name: 'Aspirant',
      age: 18,
      targetExam: 'NEET',
      examDate:
          DateTime.now().add(const Duration(days: 8)), // countdown <= 10 days
      dailyStudyHoursGoal: 8.0,
    );

    test('analyzeWellness handles empty list gracefully', () {
      final result = inference.analyzeWellness([], profile);
      expect(result['averageMood'], 6.0);
      expect(result['averageStress'], 4.0);
      expect(result['averageSleep'], 7.0);
      expect(result['burnoutLevel'], 'Low');
      expect(result['topTriggers'], isEmpty);
    });

    test('analyzeWellness correctly aggregates wellness scores', () {
      final entries = [
        MoodEntry(
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          mood: 8,
          stressLevel: 3,
          sleepHours: 8.0,
          tags: ['Revision'],
        ),
        MoodEntry(
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          mood: 4,
          stressLevel: 7, // elevated stress
          sleepHours: 5.0, // sleep deficit
          tags: ['Mock Test', 'Backlog'],
        ),
      ];

      final result = inference.analyzeWellness(entries, profile);
      expect(result['averageMood'], 6.0); // (8 + 4) / 2
      expect(result['averageStress'], 5.0); // (3 + 7) / 2
      expect(result['averageSleep'], 6.5); // (8 + 5) / 2
      expect(result['topTriggers'], containsAll(['Mock Test', 'Backlog']));
      expect(result['burnoutLevel'], 'Moderate');
      expect(result['stressPrediction'],
          'Pre-Exam Anxiety Alert'); // countdown 8 days
    });

    test('analyzeWellness detects Critical burnout risk on severe metrics', () {
      final entries = [
        MoodEntry(
          timestamp: DateTime.now(),
          mood: 3,
          stressLevel: 9, // critical stress
          sleepHours: 4.5, // severe sleep deficit
          tags: ['Mock Test'],
        ),
      ];

      final result = inference.analyzeWellness(entries, profile);
      expect(result['burnoutLevel'], 'Critical');
    });
  });
}
