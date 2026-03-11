// lib/widgets/bottom_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment:   Alignment.bottomCenter,
          children: [

            // ── Glass pill ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin:  Alignment.topLeft,
                      end:    Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.72),
                        Colors.white.withOpacity(0.58),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.60),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.12),
                        blurRadius: 28,
                        offset:     const Offset(0, 6),
                      ),
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset:     const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        index:       0,
                        current:     currentIndex,
                        icon:        Icons.home_outlined,
                        activeIcon:  Icons.home_rounded,
                        label:       'Home',
                        onTap:       onTap,
                      ),
                      _NavItem(
                        index:       1,
                        current:     currentIndex,
                        icon:        Icons.calendar_month_outlined,
                        activeIcon:  Icons.calendar_month_rounded,
                        label:       'Bookings',
                        onTap:       onTap,
                      ),

                      // Centre spacer for FAB
                      const Expanded(child: SizedBox()),

                      _NavItem(
                        index:       3,
                        current:     currentIndex,
                        icon:        Icons.chat_bubble_outline_rounded,
                        activeIcon:  Icons.chat_bubble_rounded,
                        label:       'Messages',
                        onTap:       onTap,
                      ),
                      _NavItem(
                        index:       4,
                        current:     currentIndex,
                        icon:        Icons.person_outline_rounded,
                        activeIcon:  Icons.person_rounded,
                        label:       'Profile',
                        onTap:       onTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Centre floating Explore button ──────────────
            Positioned(
              top: -22,
              child: _ExploreFab(
                isActive: currentIndex == 2,
                onTap:    () {
                  HapticFeedback.mediumImpact();
                  onTap(2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Single nav item
// ══════════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final int               index;
  final int               current;
  final IconData          icon;
  final IconData          activeIcon;
  final String            label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve:    Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Icon with active pill background
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve:    Curves.easeOutCubic,
                padding:  EdgeInsets.symmetric(
                  horizontal: isActive ? 14 : 0,
                  vertical:   4,
                ),
                decoration: BoxDecoration(
                  color:        isActive
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size:  22,
                  color: isActive
                      ? AppColors.primary
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 3),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    10,
                  fontWeight:  isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? AppColors.primary
                      : const Color(0xFF94A3B8),
                ),
              ),

              // Active dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin:   const EdgeInsets.only(top: 2),
                width:    isActive ? 4 : 0,
                height:   isActive ? 4 : 0,
                decoration: BoxDecoration(
                  color:  AppColors.primary,
                  shape:  BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Centre floating FAB — Explore
// ══════════════════════════════════════════════════════════════
class _ExploreFab extends StatefulWidget {
  final bool         isActive;
  final VoidCallback onTap;

  const _ExploreFab({required this.isActive, required this.onTap});

  @override
  State<_ExploreFab> createState() => _ExploreFabState();
}

class _ExploreFabState extends State<_ExploreFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:           this,
      duration:        const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: ()  => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:   (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Stack(
          alignment: Alignment.center,
          children: [

            // Outer glow ring
            Container(
              width:  68, height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.28),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),

            // White border ring
            Container(
              width:  60, height: 60,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                color:  Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset:     const Offset(0, 1),
                  ),
                ],
              ),
            ),

            // Purple gradient circle
            Container(
              width:  54, height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.primary.withOpacity(0.45),
                    blurRadius: 18,
                    offset:     const Offset(0, 5),
                  ),
                  BoxShadow(
                    color:      AppColors.primary.withOpacity(0.20),
                    blurRadius: 6,
                    offset:     const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top-left gloss sheen
                  Positioned(
                    top: 8, left: 10,
                    child: Container(
                      width:  20, height: 8,
                      decoration: BoxDecoration(
                        color:        Colors.white.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Icon(
                    widget.isActive
                        ? Icons.explore_rounded
                        : Icons.add_rounded,
                    color: Colors.white,
                    size:  26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Navigation helper
// ══════════════════════════════════════════════════════════════
void navigateToTab(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      break;
    case 1:
      Navigator.pushNamedAndRemoveUntil(context, '/bookings', (_) => false);
      break;
    case 2:
      Navigator.pushNamedAndRemoveUntil(context, '/browse', (_) => false);
      break;
    case 3:
      Navigator.pushNamedAndRemoveUntil(context, '/messages', (_) => false);
      break;
    case 4:
      Navigator.pushNamedAndRemoveUntil(context, '/profile', (_) => false);
      break;
  }
}