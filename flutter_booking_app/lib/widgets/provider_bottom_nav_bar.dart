// lib/widgets/provider_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

const _kPrimary = Color(0xFF7C3AED);

class ProviderBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const ProviderBottomNavBar({Key? key, required this.currentIndex})
      : super(key: key);

  static const List<_TabData> _tabs = [
    _TabData(label: 'Dashboard', icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,           route: '/provider/home'),
    _TabData(label: 'Bookings',  icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded, route: '/provider/bookings'),
    _TabData(label: 'Messages',  icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,    route: '/provider/messages'),
    _TabData(label: 'Services',  icon: Icons.content_cut_outlined,
        activeIcon: Icons.content_cut_rounded,    route: '/provider/services'),
    _TabData(label: 'Profile',   icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,         route: '/provider/profile'),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, _tabs[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, bottomPad > 0 ? bottomPad + 8 : 16),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          // Solid white — clean floating pill, no blur artifacts
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            // Main deep shadow — creates floating illusion
            BoxShadow(
              color:        Colors.black.withOpacity(0.13),
              blurRadius:   30,
              spreadRadius: -4,
              offset:       const Offset(0, 10),
            ),
            // Purple glow underneath
            BoxShadow(
              color:      _kPrimary.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: -3,
              offset:     const Offset(0, 8),
            ),
            // Crisp near shadow
            BoxShadow(
              color:      Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) => _NavItem(
            data:     _tabs[i],
            isActive: i == currentIndex,
            onTap:    () => _onTap(context, i),
            hasBadge: (i == 2 && context.watch<ChatProvider>().hasUnreadMessages),
          )),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// NAV ITEM — icon only, active = purple, with bounce animation
// ══════════════════════════════════════════════════════════════
class _NavItem extends StatefulWidget {
  final _TabData     data;
  final bool         isActive;
  final VoidCallback onTap;
  final bool         hasBadge;
  const _NavItem(
      {required this.data, required this.isActive, required this.onTap, this.hasBadge = false});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:           this,
      duration:        const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 260),
    );
    // iOS spring bounce: up → dip → settle
    _bounce = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.22)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.22, end: 0.92)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 0.92, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
    ]).animate(_ctrl);

    if (widget.isActive) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap:    widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: widget.isActive ? _bounce.value : 1.0,
              child: AnimatedSwitcher(
                duration:          const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                      parent: anim, curve: Curves.easeOutBack),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      widget.isActive
                          ? widget.data.activeIcon
                          : widget.data.icon,
                      key:   ValueKey(widget.isActive),
                      color: widget.isActive
                          ? _kPrimary
                          : const Color(0xFF94A3B8),
                      size:  widget.isActive ? 26 : 24,
                    ),
                    if (widget.hasBadge)
                      Positioned(
                        top:  -2,
                        right: -2,
                        child: Container(
                          width:  8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab data ──────────────────────────────────────────────────
class _TabData {
  final String   label;
  final IconData icon;
  final IconData activeIcon;
  final String   route;
  const _TabData({required this.label, required this.icon,
    required this.activeIcon, required this.route});
}

// ── Route helper ──────────────────────────────────────────────
int providerNavIndex(String route) {
  switch (route) {
    case '/provider/home':     return 0;
    case '/provider/bookings': return 1;
    case '/provider/messages': return 2;
    case '/provider/services': return 3;
    case '/provider/profile':  return 4;
    default:                   return 0;
  }
}