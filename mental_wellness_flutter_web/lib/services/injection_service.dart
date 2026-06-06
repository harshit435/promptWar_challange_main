import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/mood_entry.dart';

class InjectionService {
  Future<List<MoodEntry>> loadSampleData() async {
    final s = await rootBundle.loadString('assets/sample_data.json');
    final List<dynamic> arr = jsonDecode(s) as List<dynamic>;
    return arr
        .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
