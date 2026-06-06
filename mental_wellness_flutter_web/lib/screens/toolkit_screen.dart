import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/state_manager.dart';

class ToolkitScreen extends StatefulWidget {
  const ToolkitScreen({super.key});

  @override
  State<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends State<ToolkitScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Box Breathing States
  late AnimationController _breathingController;
  int _breathPhase = 0; // 0: Inhale, 1: Hold full, 2: Exhale, 3: Hold empty
  String _breathText = "Tap Start to Breathe";
  bool _breathingActive = false;

  // Stress Shredder States
  final TextEditingController _thoughtController = TextEditingController();
  late AnimationController _shredController;
  List<ShredParticle> _particles = [];
  bool _isShredding = false;
  final Random _random = Random();

  // Concentration Game States
  bool _gameActive = false;
  bool _showSuccess = false;
  int _timeLeft = 60;
  Timer? _gameTimer;
  late AnimationController _gameAnimationController;
  List<BouncingBall> _gameBalls = [];
  List<FireworkParticle> _fireworks = [];

  // Width and Height for simulation
  final double _simWidth = 500.0;
  final double _simHeight = 280.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Breathing Controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathingController.addStatusListener((status) {
      if (!_breathingActive) return;
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathPhase = (_breathPhase + 1) % 4;
          _updateBreathingInstructions();
        });
        _breathingController.forward(from: 0.0);
      }
    });

    // Shredder Controller
    _shredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        if (_isShredding) {
          _updateParticles();
        }
      });

    _shredController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isShredding = false;
          _particles.clear();
          _thoughtController.clear();
        });
      }
    });

    // Game Physics Ticker
    _gameAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        if (_gameActive) {
          _updateGamePhysics();
        } else if (_showSuccess) {
          _updateFireworksPhysics();
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _breathingController.dispose();
    _shredController.dispose();
    _thoughtController.dispose();
    _gameAnimationController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  // --- Breathing Logic ---
  void _toggleBreathing() {
    setState(() {
      _breathingActive = !_breathingActive;
      if (_breathingActive) {
        _breathPhase = 0;
        _updateBreathingInstructions();
        _breathingController.forward(from: 0.0);
      } else {
        _breathingController.stop();
        _breathText = "Breathe Sanctuary Stopped";
      }
    });
  }

  void _updateBreathingInstructions() {
    switch (_breathPhase) {
      case 0:
        _breathText = "Inhale slowly...";
        break;
      case 1:
        _breathText = "Hold your breath...";
        break;
      case 2:
        _breathText = "Exhale slowly...";
        break;
      case 3:
        _breathText = "Hold empty...";
        break;
    }
  }

  double _getBubbleScale() {
    if (!_breathingActive) return 0.5;
    final value = _breathingController.value;
    switch (_breathPhase) {
      case 0: // Inhale
        return 0.5 + (value * 0.5);
      case 1: // Hold
        return 1.0;
      case 2: // Exhale
        return 1.0 - (value * 0.5);
      case 3: // Hold empty
        return 0.5;
      default:
        return 0.5;
    }
  }

  Color _getBreathingColor() {
    switch (_breathPhase) {
      case 0: // Inhale
        return const Color(0xFF64FFDA);
      case 1: // Hold
        return const Color(0xFF80DEEA);
      case 2: // Exhale
        return Colors.orangeAccent;
      case 3: // Hold empty
        return Colors.amberAccent;
      default:
        return const Color(0xFF64FFDA);
    }
  }

  // --- Shredder Logic ---
  void _triggerShred() {
    if (_thoughtController.text.trim().isEmpty || _isShredding) return;

    setState(() {
      _isShredding = true;
      _particles = List.generate(80, (index) {
        return ShredParticle(
          x: 200.0 + _random.nextDouble() * 200.0,
          y: 120.0 + _random.nextDouble() * 40.0,
          vx: (_random.nextDouble() - 0.5) * 8.0,
          vy: -(_random.nextDouble() * 6.0 + 2.0),
          size: _random.nextDouble() * 5.0 + 2.0,
          color: Color.lerp(Colors.orangeAccent, const Color(0xFF64FFDA),
              _random.nextDouble())!,
          opacity: 1.0,
        );
      });
    });

    _shredController.forward(from: 0.0);
    StateManager().incrementShredCount();
  }

  void _updateParticles() {
    setState(() {
      for (var p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.05;
        p.opacity = (p.opacity - 0.012).clamp(0.0, 1.0);
      }
    });
  }

  // --- Concentration Game Logic ---
  void _startConcentrationGame() {
    _gameTimer?.cancel();
    _fireworks.clear();

    setState(() {
      _gameActive = true;
      _showSuccess = false;
      _timeLeft = 60;

      // Create bouncing balls with soothing colors
      final List<Color> ballColors = [
        const Color(0xFF64FFDA),
        const Color(0xFF80DEEA),
        Colors.orangeAccent,
        Colors.amberAccent,
        Colors.tealAccent,
        Colors.lightBlueAccent,
        Colors.pinkAccent,
        Colors.purpleAccent,
      ];

      _gameBalls = List.generate(10, (index) {
        return BouncingBall(
          x: 50.0 + _random.nextDouble() * (_simWidth - 100.0),
          y: 50.0 + _random.nextDouble() * (_simHeight - 100.0),
          vx: (_random.nextDouble() > 0.5 ? 1.5 : -1.5) *
              (_random.nextDouble() * 1.2 + 0.8),
          vy: (_random.nextDouble() > 0.5 ? 1.5 : -1.5) *
              (_random.nextDouble() * 1.2 + 0.8),
          radius: _random.nextDouble() * 6.0 + 12.0, // varied size
          color: ballColors[index % ballColors.length],
        );
      });
    });

    // Start 1-sec countdown timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 1) {
          _timeLeft--;
        } else {
          _timeLeft = 0;
          _triggerGameSuccess();
        }
      });
    });

    _gameAnimationController.repeat();
  }

  void _updateGamePhysics() {
    setState(() {
      for (var ball in _gameBalls) {
        ball.x += ball.vx;
        ball.y += ball.vy;

        // Bounce left/right
        if (ball.x - ball.radius < 0) {
          ball.x = ball.radius;
          ball.vx = -ball.vx;
        } else if (ball.x + ball.radius > _simWidth) {
          ball.x = _simWidth - ball.radius;
          ball.vx = -ball.vx;
        }

        // Bounce top/bottom
        if (ball.y - ball.radius < 0) {
          ball.y = ball.radius;
          ball.vy = -ball.vy;
        } else if (ball.y + ball.radius > _simHeight) {
          ball.y = _simHeight - ball.radius;
          ball.vy = -ball.vy;
        }
      }
    });
  }

  void _triggerGameSuccess() {
    _gameTimer?.cancel();

    // Trigger fireworks explosion particles from the location of each ball
    List<FireworkParticle> fParticles = [];
    for (var ball in _gameBalls) {
      // Create 15 explosion sparks per ball
      for (int i = 0; i < 15; i++) {
        final double angle = _random.nextDouble() * 2 * pi;
        final double speed = _random.nextDouble() * 5.0 + 2.0;
        fParticles.add(
          FireworkParticle(
            x: ball.x,
            y: ball.y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            color: ball.color,
            radius: _random.nextDouble() * 3.0 + 2.0,
            opacity: 1.0,
          ),
        );
      }
    }

    setState(() {
      _gameActive = false;
      _showSuccess = true;
      _fireworks = fParticles;
    });

    // Run animation controller for a short burst
    _gameAnimationController.forward(from: 0.0);
  }

  void _updateFireworksPhysics() {
    setState(() {
      for (var p in _fireworks) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.08; // gravity drop
        p.opacity = (p.opacity - 0.015).clamp(0.0, 1.0);
      }
    });
  }

  void _stopGame() {
    _triggerGameSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = Colors.white.withOpacity(0.02);
    final borderCol = Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Styled Tab Bar (now 3 tabs)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF090A14),
              border: Border(bottom: BorderSide(color: borderCol)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF64FFDA),
              labelColor: const Color(0xFF64FFDA),
              unselectedLabelColor: Colors.white60,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(
                  icon: Icon(Icons.center_focus_strong_rounded),
                  text: 'Breathing Circle',
                ),
                Tab(
                  icon: Icon(Icons.delete_sweep_rounded),
                  text: 'Worry Shredder',
                ),
                Tab(
                  icon: Icon(Icons.blur_circular_rounded),
                  text: 'Concentration Game',
                ),
              ],
            ),
          ),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBreathingTab(cardBg, borderCol),
                _buildShredderTab(cardBg, borderCol),
                _buildGameTab(cardBg, borderCol),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Breathing Guide View ---
  Widget _buildBreathingTab(Color cardBg, Color borderCol) {
    final double bubbleScale = _getBubbleScale();
    final Color currentColor = _getBreathingColor();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Box Breathing Sanctuary',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Calms the nervous system and triggers a rapid relaxation response.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 48),

              // Animated Breathing Ball
              SizedBox(
                height: 220,
                width: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 150 * bubbleScale + 50,
                      height: 150 * bubbleScale + 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentColor.withOpacity(0.05),
                        border: Border.all(
                            color: currentColor.withOpacity(0.15), width: 2),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 150 * bubbleScale,
                      height: 150 * bubbleScale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            currentColor.withOpacity(0.4),
                            currentColor.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentColor.withOpacity(0.2),
                            blurRadius: 24,
                            spreadRadius: bubbleScale * 4,
                          )
                        ],
                      ),
                    ),
                    Text(
                      _breathingActive
                          ? "${(4 - (_breathingController.value * 4)).ceil()}s"
                          : "Ready",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                _breathText,
                style: TextStyle(
                  color: currentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _breathingActive
                    ? (_breathPhase == 0
                        ? "Fill your lungs with cool energy"
                        : _breathPhase == 1
                            ? "Stay calm and centered"
                            : _breathPhase == 2
                                ? "Release all pressure and tension"
                                : "Pause before the next cycle")
                    : "Prepare yourself, click start when comfortable.",
                style: const TextStyle(color: Colors.white30, fontSize: 12),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed: _toggleBreathing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _breathingActive
                        ? Colors.redAccent.withOpacity(0.2)
                        : const Color(0xFF64FFDA),
                    foregroundColor: _breathingActive
                        ? Colors.redAccent
                        : const Color(0xFF0C0E1A),
                    side: _breathingActive
                        ? const BorderSide(color: Colors.redAccent)
                        : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _breathingActive ? 'Stop Session' : 'Start Session',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Stress Shredder View ---
  Widget _buildShredderTab(Color cardBg, Color borderCol) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Stress Worry Shredder',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Write down your negative thoughts, anxiety, or backlog stress. When you click Shred, let go of the thought completely.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  children: [
                    if (_isShredding)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ParticlePainter(particles: _particles),
                        ),
                      ),
                    if (!_isShredding)
                      Center(
                        child: TextField(
                          controller: _thoughtController,
                          maxLines: 4,
                          maxLength: 140,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, height: 1.4),
                          decoration: InputDecoration(
                            hintText:
                                'e.g. "I am terrified I won\'t clear the mock test cut-off this Sunday."',
                            hintStyle: const TextStyle(
                                color: Colors.white24, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFF64FFDA)),
                            ),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                        ),
                      ),
                    if (_isShredding)
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: Color(0xFF64FFDA), size: 40),
                            SizedBox(height: 12),
                            Text(
                              'Shredded into stardust...',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!_isShredding)
                SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _triggerShred,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: const Color(0xFF0C0E1A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      shadowColor: Colors.orangeAccent.withOpacity(0.3),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_sweep_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Shred This Worry',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Concentration Game View ---
  Widget _buildGameTab(Color cardBg, Color borderCol) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Concentration Ball Sanctuary',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a single ball with your eyes and follow it. Let your thoughts anchor to its movement to release mental tension.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Game Arena Container
              Container(
                height: _simHeight,
                width: _simWidth,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Physics Canvas Painter
                      if (_gameActive || _showSuccess)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GameArenaPainter(
                              balls: _gameBalls,
                              fireworks: _fireworks,
                              drawBalls: _gameActive,
                              drawFireworks: _showSuccess,
                            ),
                          ),
                        ),

                      // Countdown text overlay
                      if (_gameActive)
                        Positioned(
                          top: 12,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    color: Colors.orangeAccent, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  '${_timeLeft}s',
                                  style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Welcome overlay / Success banner
                      if (!_gameActive && !_showSuccess)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF64FFDA).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.blur_circular_rounded,
                                    color: Color(0xFF64FFDA), size: 36),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Select one ball, concentrate for 1 minute.',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                      if (_showSuccess)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xEC111422),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      const Color(0xFF64FFDA).withOpacity(0.3)),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.task_alt_rounded,
                                    color: Color(0xFF64FFDA), size: 48),
                                SizedBox(height: 8),
                                Text(
                                  '🎉 Successfully Centered!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'All worries popped like fireworks.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_gameActive && !_showSuccess)
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _startConcentrationGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64FFDA),
                          foregroundColor: const Color(0xFF0C0E1A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Start Concentration',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_gameActive)
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _stopGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.2),
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Exit Game',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_showSuccess)
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _startConcentrationGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64FFDA),
                          foregroundColor: const Color(0xFF0C0E1A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Focus Again',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bouncing Ball class
class BouncingBall {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  Color color;

  BouncingBall({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });
}

// Fireworks Spark Particle
class FireworkParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double radius;
  double opacity;

  FireworkParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.radius,
    required this.opacity,
  });
}

// Arena Painter
class GameArenaPainter extends CustomPainter {
  final List<BouncingBall> balls;
  final List<FireworkParticle> fireworks;
  final bool drawBalls;
  final bool drawFireworks;

  GameArenaPainter({
    required this.balls,
    required this.fireworks,
    required this.drawBalls,
    required this.drawFireworks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (drawBalls) {
      for (var ball in balls) {
        // Draw glow aura
        paint.color = ball.color.withOpacity(0.15);
        canvas.drawCircle(Offset(ball.x, ball.y), ball.radius + 8, paint);

        // Draw solid core
        paint.color = ball.color;
        canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, paint);
      }
    }

    if (drawFireworks) {
      for (var spark in fireworks) {
        if (spark.opacity <= 0.0) continue;
        paint.color = spark.color.withOpacity(spark.opacity);
        canvas.drawCircle(Offset(spark.x, spark.y), spark.radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle Class
class ShredParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;

  ShredParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.opacity,
  });
}

// Canvas Painter for dissolving effect
class ParticlePainter extends CustomPainter {
  final List<ShredParticle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      if (p.opacity <= 0.0) continue;
      paint.color = p.color.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
