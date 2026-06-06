import 'package:flutter/material.dart';
import '../services/state_manager.dart';
import '../services/inference_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StateManager();
    final inference = InferenceService();
    final profile = state.profile;
    final analytics = inference.analyzeWellness(state.entries, profile);

    final String countdownText = analytics['examCountdownDays'] != null
        ? "${analytics['examCountdownDays']} Days"
        : "Not Set";

    final double avgStress = analytics['averageStress'] as double;
    final double avgMood = analytics['averageMood'] as double;
    final String stressPrediction = analytics['stressPrediction'] as String;
    final String burnoutLevel = analytics['burnoutLevel'] as String;

    // curating theme values directly for glassmorphism
    const cardBg = Color(0x08FFFFFF);
    const borderCol = Color(0x0FFFFFFF);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // transparency for back glow gradients
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeBanner(profile, analytics),
            const SizedBox(height: 24),

            // Top Metrics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int columns = width > 1100 ? 4 : (width > 600 ? 2 : 1);
                const double spacing = 16;
                final double cellWidth =
                    (width - (columns - 1) * spacing) / columns;

                final metrics = [
                  _buildMetricCard(
                    title: 'Mood Index',
                    value: '$avgMood / 10',
                    icon: Icons.emoji_emotions_rounded,
                    color: Color.lerp(Colors.redAccent, Colors.tealAccent,
                            avgMood / 10) ??
                        Colors.tealAccent,
                    subtitle: 'Average student mood',
                    width: cellWidth,
                  ),
                  _buildMetricCard(
                    title: 'Stress Signature',
                    value: '$avgStress / 10',
                    icon: Icons.stacked_line_chart_rounded,
                    color: avgStress > 7
                        ? Colors.redAccent
                        : (avgStress > 4
                            ? Colors.orangeAccent
                            : const Color(0xFF64FFDA)),
                    subtitle: 'Pressure level indicator',
                    width: cellWidth,
                  ),
                  _buildMetricCard(
                    title: 'Sleep Average',
                    value: '${analytics['averageSleep']} hrs',
                    icon: Icons.bedtime_rounded,
                    color: analytics['averageSleep'] < 6.0
                        ? Colors.amberAccent
                        : Colors.lightBlueAccent,
                    subtitle: 'Target: 7-8 hours',
                    width: cellWidth,
                  ),
                  _buildMetricCard(
                    title: 'Burnout Risk',
                    value: burnoutLevel,
                    icon: Icons.offline_bolt_rounded,
                    color: burnoutLevel == 'Critical'
                        ? Colors.redAccent
                        : (burnoutLevel == 'Moderate'
                            ? Colors.orangeAccent
                            : const Color(0xFF64FFDA)),
                    subtitle: '${analytics['burnoutScore']}% risk index',
                    width: cellWidth,
                  ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: metrics,
                );
              },
            ),
            const SizedBox(height: 24),

            // Middle section (Main countdown + Shredder quick entrance)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // countdown glassmorphic card
                      _buildCountdownWidget(profile, countdownText,
                          stressPrediction, cardBg, borderCol),
                      const SizedBox(height: 20),
                      // simulated peer pulse
                      _buildPeerPulseWidget(
                          profile.targetExam, cardBg, borderCol),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Quick sanctuary activities (On Web/Desktop side card)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSanctuaryCard(context, cardBg, borderCol),
                      const SizedBox(height: 20),
                      _buildZenQuoteCard(cardBg, borderCol),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(dynamic profile, dynamic analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF64FFDA).withOpacity(0.07),
            const Color(0xFF1E293B).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF64FFDA).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Sanctuary, ${profile.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Preparing for ${profile.targetExam} • Stress prediction status: ${analytics['stressPrediction']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded,
                    color: Colors.orangeAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Shredded: ${StateManager().shreddedThoughtsCount}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownWidget(dynamic profile, String daysLeft,
      String prediction, Color bg, Color border) {
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
            'Exam Target countdown',
            style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      daysLeft,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${profile.targetExam} Exam',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                height: 70,
                width: 1,
                color: Colors.white10,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inference Engine Prediction',
                      style: TextStyle(
                          color: Color(0xFF64FFDA),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      prediction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pre-exam anxiety scales as targets draw closer. Plan micro-breaks.',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
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

  Widget _buildPeerPulseWidget(String targetExam, Color bg, Color border) {
    // Generate some simulated entries representing "Peer Pulse"
    final pulses = [
      '🔥 68% of $targetExam aspirants reported feeling "Mock Test Exhaustion" today.',
      '🌿 Student Pulse: "Focus is solid, but backlogs are causing minor anxiety."',
      '🧘 Anonymously shared: "Took a 10-minute walk outside, brain feels refreshed."',
      '💡 Study Hack: "Split study blocks into 50 mins work + 10 mins breathing."'
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Peer Pulse: $targetExam Community',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.blur_circular_rounded,
                  color: Color(0xFF64FFDA), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          ...pulses.map((pulse) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.02)),
                  ),
                  child: Text(
                    pulse,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSanctuaryCard(BuildContext context, Color bg, Color border) {
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
            'Sanctuary Tools',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Take a micro-break to release build-up tension.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Breathing button
          _buildToolActionItem(
            title: 'Box Breathing Circle',
            description:
                '4-4-4-4 cycle to instantly drop heart rate & study stress.',
            icon: Icons.center_focus_strong_rounded,
            color: const Color(0xFF64FFDA),
          ),
          const SizedBox(height: 12),

          // Shredder button
          _buildToolActionItem(
            title: 'Stress Shredder',
            description:
                'Write down negative thoughts and watch them dissolve.',
            icon: Icons.delete_sweep_rounded,
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildToolActionItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZenQuoteCard(Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: Color(0xFF64FFDA), size: 28),
          SizedBox(height: 8),
          Text(
            '"You do not have to see the whole staircase, just take the first step."',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '— Martin Luther King Jr.',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
