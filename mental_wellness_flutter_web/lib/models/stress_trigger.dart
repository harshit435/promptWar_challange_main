class StressTrigger {
  final String id;
  final String name;
  final String? description;

  StressTrigger({required this.id, required this.name, this.description});

  factory StressTrigger.fromJson(Map<String, dynamic> j) => StressTrigger(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}
