// lib/widgets/glass_kit.dart
// ─────────────────────────────────────────────────────────────────────────────
// iOS 26 Liquid-Glass design system for HayaBook
//   • GlassBox      – frosted-glass container (BackdropFilter + gradient border)
//   • GlassButton   – pill / circle frosted button
//   • GlassAppIcon  – gradient rounded-rect icon with inner sheen (SF-symbol style)
//   • FadeSlide     – stagger-in fade + translate animation
//   • ScaleTap      – spring scale-down on press
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

// ══════════════════════════════════════════════════════════════
// GlassBox
// ══════════════════════════════════════════════════════════════
class GlassBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color tint;
  final double blur;
  final double tintOpacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? shadows;

  const GlassBox({
    Key? key,
    required this.child,
    this.radius = 24,
    this.tint = Colors.white,
    this.blur = 22,
    this.tintOpacity = 0.55,
    this.borderOpacity = 0.32,
    this.padding,
    this.shadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withOpacity(tintOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1.0,
            ),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GlassButton — circle or pill glass icon button
// ══════════════════════════════════════════════════════════════
class GlassButton extends StatelessWidget {
  final Widget child;
  final double size;
  final double radius;
  final VoidCallback? onTap;
  final Color tint;
  final double tintOpacity;

  const GlassButton({
    Key? key,
    required this.child,
    this.size = 44,
    this.radius = 99,
    this.onTap,
    this.tint = Colors.white,
    this.tintOpacity = 0.22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap ?? () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: tint.withOpacity(tintOpacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.0,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GlassAppIcon — iOS 26 SF-symbol style app icon
// gradient rect + inner sheen highlight + icon
// ══════════════════════════════════════════════════════════════
class GlassAppIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final double size;
  final double radius;
  final double iconSize;

  const GlassAppIcon({
    Key? key,
    required this.icon,
    required this.gradient,
    this.size = 52,
    this.radius = 16,
    this.iconSize = 26,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.40),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top-left gloss sheen — iOS 26 liquid glass look
          Positioned(
            top: size * 0.08,
            left: size * 0.12,
            child: Container(
              width: size * 0.40,
              height: size * 0.20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: iconSize),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FadeSlide — stagger fade + translate-up entrance
// ══════════════════════════════════════════════════════════════
class FadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double dy;
  final Duration duration;

  const FadeSlide({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 28,
    this.duration = const Duration(milliseconds: 520),
  }) : super(key: key);

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: widget.duration);
    _opacity =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<double>(begin: widget.dy, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, child) => Opacity(
      opacity: _opacity.value,
      child: Transform.translate(
          offset: Offset(0, _slide.value), child: child),
    ),
    child: widget.child,
  );
}

// ══════════════════════════════════════════════════════════════
// ScaleTap — spring scale-down press feedback
// ══════════════════════════════════════════════════════════════
class ScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;

  const ScaleTap({
    Key? key,
    required this.child,
    required this.onTap,
    this.scale = 0.94,
  }) : super(key: key);

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _s = Tween<double>(begin: 1.0, end: widget.scale).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) {
      _ctrl.reverse();
      widget.onTap();
    },
    onTapCancel: () => _ctrl.reverse(),
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) =>
          Transform.scale(scale: _s.value, child: child),
      child: widget.child,
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// GlassScaffold — shared teal-gradient header shell
// ══════════════════════════════════════════════════════════════
class GlassHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;

  const GlassHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.white70)),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
              if (bottom != null) ...[const SizedBox(height: 14), bottom!],
            ],
          ),
        ),
      ),
    );
  }
}