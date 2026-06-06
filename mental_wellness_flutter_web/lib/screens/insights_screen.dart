import 'dart:math';
import 'package:flutter/material.dart';
import '../services/state_manager.dart';
import '../services/inference_service.dart';
import '../models/mood_entry.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StateManager();
    final inference = InferenceService();
    final profile = state.profile;
    final analytics = inference.analyzeWellness(state.entries, profile);

    final List<MoodEntry> entries = state.entries;
    final double avgStress = analytics['averageStress'] as double;
    final String burnoutLevel = analytics['burnoutLevel'] as String;
    final double burnoutScore = analytics['burnoutScore'] as double;
    final List<String> topTriggers =
        List<String>.from(analytics['topTriggers'] ?? []);

    final cardBg = Colors.white.withOpacity(0.02);
    final borderCol = Colors.white.withOpacity(0.05);

    // Filter entries that have reframing notes
    final reframedEntries = entries
        .where((e) =>
            e.reframingNote != null && e.reframingNote!.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Burnout Arc & Triggers split view
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 750;
                final widgets = [
                  // Burnout Arc Meter
                  _buildBurnoutArcMeter(
                      burnoutScore,
                      burnoutLevel,
                      cardBg,
                      borderCol,
                      isWide
                          ? (constraints.maxWidth - 20) / 2
                          : double.infinity),
                  if (isWide) const SizedBox(width: 20),
                  // Top Triggers
                  _buildTopTriggersWidget(
                      topTriggers,
                      avgStress,
                      cardBg,
                      borderCol,
                      isWide
                          ? (constraints.maxWidth - 20) / 2
                          : double.infinity),
                ];

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgets.map((w) => Expanded(child: w)).toList(),
                  );
                } else {
                  return Column(
                    children: [
                      widgets[0],
                      const SizedBox(height: 20),
                      widgets[1],
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Custom Painted Stress Trend Chart
            _buildCustomTrendChart(entries, cardBg, borderCol),
            const SizedBox(height: 20),

            // Reframed Library
            _buildReframedLibraryWidget(reframedEntries, cardBg, borderCol),
          ],
        ),
      ),
    );
  }

  Widget _buildBurnoutArcMeter(
      double score, String level, Color bg, Color border, double width) {
    Color levelColor = const Color(0xFF64FFDA);
    if (level == 'Critical') {
      levelColor = Colors.redAccent;
    } else if (level == 'Moderate') {
      levelColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Burnout Risk Index',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: BurnoutMeterPainter(score: score, color: levelColor),
                  child: Center(
                    child: Text(
                      '${score.round()}%',
                      style: TextStyle(
                          color: levelColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$level Risk Level',
                      style: TextStyle(
                          color: levelColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level == 'Critical'
                          ? 'Burnout score is elevated. High stress and insufficient sleep detected. Please take an intentional day off mock prep.'
                          : level == 'Moderate'
                              ? 'Moderate academic fatigue. Maintain daily 15-minute sanctuary breaks and ensure 7+ hours of sleep.'
                              : 'Healthy wellness balance. Continue tracking mood triggers as countdown moves closer.',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTriggersWidget(List<String> triggers, double avgStress,
      Color bg, Color border, double width) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Academic Stressors',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (triggers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No trigger clusters logged yet. Keep updating your logs!',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: triggers.map((trigger) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded,
                            color: Colors.orangeAccent, size: 16),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trigger,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Linked with elevated stress signatures (Stress > 5/10)',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomTrendChart(
      List<MoodEntry> entries, Color bg, Color border) {
    // We reverse list to show from oldest to newest left-to-right
    final sortedEntries = entries.reversed.take(7).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Pressure Trend (Stress Signature vs. Flow Mood)',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.fiber_manual_record,
                      color: Colors.orangeAccent, size: 12),
                  SizedBox(width: 4),
                  Text('Stress',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  SizedBox(width: 12),
                  Icon(Icons.fiber_manual_record,
                      color: Color(0xFF64FFDA), size: 12),
                  SizedBox(width: 4),
                  Text('Mood',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (sortedEntries.length < 2)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Log at least 2 entries to calculate line trend correlations.',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: LineChartPainter(entries: sortedEntries),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: sortedEntries.map((e) {
                    final day = '${e.timestamp.day}/${e.timestamp.month}';
                    return Text(
                      day,
                      style:
                          const TextStyle(color: Colors.white24, fontSize: 11),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReframedLibraryWidget(
      List<MoodEntry> reframed, Color bg, Color border) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories_rounded,
                  color: Color(0xFF64FFDA), size: 20),
              SizedBox(width: 10),
              Text(
                'My Sanctuary Reframed Thought Library',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Read through your previous rational reframes when self-doubt arises.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 20),
          if (reframed.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No cognitive reframings logged yet. Add one in the reflection journal!',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reframed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = reframed[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.02)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Logged ${e.timestamp.day}/${e.timestamp.month}',
                            style: const TextStyle(
                                color: Colors.white30,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF64FFDA).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stress: ${e.stressLevel}/10',
                              style: const TextStyle(
                                  color: Color(0xFF64FFDA),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.close_rounded,
                              color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Worry: "${e.note}"',
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.3,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_rounded,
                              color: Color(0xFF64FFDA), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reframe: "${e.reframingNote}"',
                              style: const TextStyle(
                                  color: Color(0xFF64FFDA),
                                  fontSize: 12,
                                  height: 1.3,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Custom Painter for Burnout Meter Gauge
class BurnoutMeterPainter extends CustomPainter {
  final double score;
  final Color color;

  BurnoutMeterPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double thickness = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (thickness / 2);

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness;

    canvas.drawCircle(center, radius, trackPaint);

    final double sweepAngle = 2 * pi * (score / 100.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start from the top
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for Double Line Chart (Mood vs. Stress)
class LineChartPainter extends CustomPainter {
  final List<MoodEntry> entries;

  LineChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final stressPoints = <Offset>[];
    final moodPoints = <Offset>[];

    final double dx = size.width / (entries.length - 1);

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final double x = i * dx;

      // Map values (1 to 10) to Y coordinates (inverted, since 0 is top)
      final double stressY =
          size.height - ((e.stressLevel - 1) / 9.0) * size.height;
      final double moodY = size.height - ((e.mood - 1) / 9.0) * size.height;

      stressPoints.add(Offset(x, stressY));
      moodPoints.add(Offset(x, moodY));
    }

    // Paint definition
    final stressPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final moodPaint = Paint()
      ..color = const Color(0xFF64FFDA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw lines
    for (int i = 0; i < entries.length - 1; i++) {
      canvas.drawLine(stressPoints[i], stressPoints[i + 1], stressPaint);
      canvas.drawLine(moodPoints[i], moodPoints[i + 1], moodPaint);
    }

    // Draw dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < entries.length; i++) {
      dotPaint.color = Colors.orangeAccent;
      canvas.drawCircle(stressPoints[i], 5.0, dotPaint);

      dotPaint.color = const Color(0xFF64FFDA);
      canvas.drawCircle(moodPoints[i], 5.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
