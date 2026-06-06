import 'package:flutter/material.dart';
import '../services/state_manager.dart';
import 'dashboard_screen.dart';
import 'entry_form.dart';
import 'toolkit_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Sanctuary Dashboard',
    'Self-Reflection Journal',
    'Stress Release Room',
    'Wellness Insights',
    'AI Wellness Companion',
    'Aspirant Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final state = StateManager();

    // The screens to display
    final List<Widget> screens = [
      const DashboardScreen(),
      const EntryFormScreen(isNavigatingFromShell: true),
      const ToolkitScreen(),
      const InsightsScreen(),
      const ChatbotScreen(),
      const ProfileScreen(),
    ];

    return AnimatedBuilder(
      animation: state,
      builder: (context, child) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F111E), // Deep space blue/black
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64FFDA)),
              ),
            ),
          );
        }

        // LayoutBuilder for responsiveness
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Scaffold(
              backgroundColor:
                  const Color(0xFF0C0E1A), // Ultra deep space background
              body: Stack(
                children: [
                  // Premium gradient backdrop that animates slightly or sets the tone
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-0.6, -0.6),
                          radius: 1.2,
                          colors: [
                            Color(0x153A1C60), // Soft dark purple glow
                            Color(0x000C0E1A), // Fades to ultra deep navy
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.8, 0.8),
                          radius: 1.5,
                          colors: [
                            Color(0x100D5C75), // Soft deep cyan glow
                            Color(0x000C0E1A), // Fades to black
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Layout
                  Row(
                    children: [
                      // Desktop Sidebar
                      if (isDesktop) _buildDesktopNavigationRail(),

                      // Primary Screen Area
                      Expanded(
                        child: Column(
                          children: [
                            // Custom glassy header bar
                            _buildHeaderBar(isDesktop),

                            // Screen Content
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: screens[_currentIndex],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              bottomNavigationBar:
                  !isDesktop ? _buildBottomNavigationBar() : null,
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x700C0E1A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isDesktop) ...[
                  const Icon(
                    Icons.spa_rounded,
                    color: Color(0xFF64FFDA), // Calming mint
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    _titles[_currentIndex],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Clean Glassy Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF64FFDA),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x8064FFDA),
                        blurRadius: 6,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isDesktop)
                  const Text(
                    'ZenPrep Sanctuary Active',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigationRail() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF090A14), // Dark navigation rail background
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo & Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64FFDA), Color(0xFF80DEEA)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64FFDA).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF090A14),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ZENPREP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Sanctuary',
                    style: TextStyle(
                      color: const Color(0xFF64FFDA).withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, 'Dashboard', Icons.dashboard_outlined,
                    Icons.dashboard_rounded),
                _buildNavItem(1, 'Journal Log', Icons.edit_note_outlined,
                    Icons.edit_note_rounded),
                _buildNavItem(2, 'Shredder & Breath', Icons.toys_outlined,
                    Icons.toys_rounded),
                _buildNavItem(3, 'Analytics', Icons.insights_outlined,
                    Icons.insights_rounded),
                _buildNavItem(4, 'ZenBot Companion', Icons.smart_toy_outlined,
                    Icons.smart_toy_rounded),
                _buildNavItem(5, 'Target Profile', Icons.person_outline_rounded,
                    Icons.person_rounded),
              ],
            ),
          ),

          // Custom Student Quote Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌿 One step at a time.',
                    style: TextStyle(
                      color: Color(0xFF64FFDA),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your value is not defined by a test result. Take a breath.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, String label, IconData outlineIcon, IconData filledIcon) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF64FFDA).withOpacity(0.12),
                      const Color(0xFF80DEEA).withOpacity(0.03),
                    ],
                  )
                : null,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF64FFDA).withOpacity(0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? filledIcon : outlineIcon,
                color: isSelected ? const Color(0xFF64FFDA) : Colors.white60,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF090A14),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF64FFDA),
        unselectedItemColor: Colors.white38,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note_rounded),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.toys_outlined),
            activeIcon: Icon(Icons.toys_rounded),
            label: 'Toolkit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy_rounded),
            label: 'ZenBot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
