import '../models/mood_entry.dart';
import '../models/user_profile.dart';

class InferenceService {
  /// Analyzes mood, stress, and sleep trends to return aggregate wellness stats.
  Map<String, dynamic> analyzeWellness(
      List<MoodEntry> entries, UserProfile profile) {
    if (entries.isEmpty) {
      return {
        'averageMood': 6.0,
        'averageStress': 4.0,
        'averageSleep': 7.0,
        'burnoutScore': 0.0, // 0 - 100
        'burnoutLevel': 'Low',
        'topTriggers': <String>[],
        'stressPrediction': 'Stable',
        'examCountdownDays': _getCountdownDays(profile.examDate),
      };
    }

    final double avgMood =
        entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
    final double avgStress =
        entries.map((e) => e.stressLevel).reduce((a, b) => a + b) /
            entries.length;
    final double avgSleep =
        entries.map((e) => e.sleepHours).reduce((a, b) => a + b) /
            entries.length;

    // Trigger analysis (find most common tags where stress is high, e.g. > 5)
    final Map<String, int> triggerCounts = {};
    for (var entry in entries) {
      if (entry.stressLevel >= 5 && entry.tags != null) {
        for (var tag in entry.tags!) {
          final cleanTag = tag.trim();
          if (cleanTag.isNotEmpty) {
            triggerCounts[cleanTag] = (triggerCounts[cleanTag] ?? 0) + 1;
          }
        }
      }
    }

    final sortedTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTriggers = sortedTriggers.take(3).map((e) => e.key).toList();

    // Burnout Index calculation (0 to 100)
    // Formula: stress weight (50%), sleep deficit weight (30%), low mood weight (20%)
    double sleepDeficit =
        (8.0 - avgSleep).clamp(0.0, 4.0); // max 4 hours deficit
    double stressFactor = (avgStress / 10.0) * 50; // max 50 points
    double sleepFactor = (sleepDeficit / 4.0) * 30; // max 30 points
    double moodFactor = ((10.0 - avgMood) / 10.0) * 20; // max 20 points
    double burnoutScore =
        (stressFactor + sleepFactor + moodFactor).clamp(0.0, 100.0);

    String burnoutLevel = 'Low';
    if (burnoutScore > 65 || avgStress >= 7.5 || avgSleep < 5.5) {
      burnoutLevel = 'Critical';
    } else if (burnoutScore > 40 || avgStress >= 5.0 || avgSleep < 6.5) {
      burnoutLevel = 'Moderate';
    }

    // Exam countdown stress prediction
    final countdownDays = _getCountdownDays(profile.examDate);
    String stressPrediction = 'Stable';
    if (countdownDays != null) {
      if (countdownDays <= 3) {
        stressPrediction = 'Peak Prep Pressure';
      } else if (countdownDays <= 10) {
        stressPrediction = 'Pre-Exam Anxiety Alert';
      } else if (countdownDays <= 30) {
        stressPrediction = 'Sustained Study Build-up';
      } else {
        stressPrediction = 'Gradual Prep Phase';
      }
    }

    return {
      'averageMood': double.parse(avgMood.toStringAsFixed(1)),
      'averageStress': double.parse(avgStress.toStringAsFixed(1)),
      'averageSleep': double.parse(avgSleep.toStringAsFixed(1)),
      'burnoutScore': double.parse(burnoutScore.toStringAsFixed(1)),
      'burnoutLevel': burnoutLevel,
      'topTriggers': topTriggers,
      'stressPrediction': stressPrediction,
      'examCountdownDays': countdownDays,
    };
  }

  int? _getCountdownDays(DateTime? targetDate) {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return examDay.difference(today).inDays;
  }
}
