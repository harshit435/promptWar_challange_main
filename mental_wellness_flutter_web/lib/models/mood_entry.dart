class MoodEntry {
  final DateTime timestamp;
  final int mood; // 1-10
  final int stressLevel; // 1-10
  final double sleepHours;
  final double? mockTestScore;
  final String? note;
  final String? reframingNote;
  final List<String>? tags;

  MoodEntry({
    required this.timestamp,
    required this.mood,
    required this.stressLevel,
    required this.sleepHours,
    this.mockTestScore,
    this.note,
    this.reframingNote,
    this.tags,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        timestamp: DateTime.parse(j['timestamp'] as String),
        mood: j['mood'] as int,
        stressLevel: j['stressLevel'] ?? 5,
        sleepHours: (j['sleepHours'] ?? 7.0) as double,
        mockTestScore: j['mockTestScore'] != null
            ? (j['mockTestScore'] as num).toDouble()
            : null,
        note: j['note'] as String?,
        reframingNote: j['reframingNote'] as String?,
        tags: j['tags'] == null ? null : List<String>.from(j['tags'] as List),
      );

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'mood': mood,
        'stressLevel': stressLevel,
        'sleepHours': sleepHours,
        'mockTestScore': mockTestScore,
        'note': note,
        'reframingNote': reframingNote,
        'tags': tags,
      };
}
