class UserProfile {
  final String id;
  final String name;
  final int age;
  final String targetExam; // e.g. JEE, NEET, UPSC, Boards
  final DateTime? examDate;
  final double dailyStudyHoursGoal;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.targetExam,
    this.examDate,
    required this.dailyStudyHoursGoal,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        age: j['age'] as int,
        targetExam: j['targetExam'] ?? 'JEE',
        examDate: j['examDate'] != null
            ? DateTime.parse(j['examDate'] as String)
            : null,
        dailyStudyHoursGoal: (j['dailyStudyHoursGoal'] ?? 8.0) as double,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'targetExam': targetExam,
        'examDate': examDate?.toIso8601String(),
        'dailyStudyHoursGoal': dailyStudyHoursGoal,
      };
}
