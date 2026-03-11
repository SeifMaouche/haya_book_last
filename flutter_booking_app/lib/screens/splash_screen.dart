// lib/screens/splash_screen.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _textCtrl;
  late final Animation<double>   _textOpacity;
  late final Animation<double>   _textScale;
  late final Animation<double>   _textBlur;

  late final AnimationController _progressCtrl;
  late final Animation<double>   _progress;
  late final Animation<double>   _progressFade;

  late final AnimationController _blobCtrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:                    Colors.transparent,
      statusBarIconBrightness:           Brightness.light,
      systemNavigationBarColor:          Color(0xFF1A0A3C),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _textCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _textScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );
    _textBlur = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.68, curve: Curves.easeOut),
      ),
    );

    _progressCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2600),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressCtrl,
        curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
      ),
    );

    _blobCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _textCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressCtrl.forward();
    });

    _progressCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _progressCtrl.dispose();
    _blobCtrl.dispose();
    super.dispose();
  }

  Offset _drift(double t, {required double phase, double amp = 22}) {
    final a = (t + phase) * 2 * math.pi;
    return Offset(
      math.sin(a * 0.60) * amp,
      math.cos(a * 0.45) * amp * 1.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sz  = MediaQuery.of(context).size;
    final pad = MediaQuery.of(context).padding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0A3C), // bgNearBlack
        body: Stack(
          fit: StackFit.expand,
          children: [

            // ── LAYER 1 — Purple gradient ──────────────────────
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Color(0xFF8B5CF6), // gradientTop
                    Color(0xFF2E1065), // gradientDark
                    Color(0xFF1A0A3C), // bgNearBlack
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
              ),
            ),

            // ── LAYER 2 — Animated blobs ───────────────────────
            AnimatedBuilder(
              animation: _blobCtrl,
              builder: (_, __) {
                final t  = _blobCtrl.value;
                final tr = _drift(t, phase: 0.00);
                final bl = _drift(t, phase: 0.50, amp: 18);
                final cr = _drift(t, phase: 0.25, amp: 14);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top:   -95 + tr.dy,
                      right: -55 + tr.dx,
                      child: _GlowBlob(
                        diameter: sz.width * 0.82,
                        color:    const Color(0xFF8B5CF6), // gradientTop
                        opacity:  0.62,
                        blur:     60,
                      ),
                    ),
                    Positioned(
                      bottom: sz.height * 0.08 + bl.dy,
                      left:   -58 + bl.dx,
                      child: _GlowBlob(
                        diameter: sz.width * 0.70,
                        color:    const Color(0xFF7C3AED), // primary
                        opacity:  0.55,
                        blur:     62,
                      ),
                    ),
                    Positioned(
                      top:   sz.height * 0.36 + cr.dy,
                      right: -sz.width * 0.26 + cr.dx,
                      child: _GlowBlob(
                        diameter: sz.width * 0.72,
                        color:    const Color(0xFFA78BFA), // blobColor
                        opacity:  0.20,
                        blur:     72,
                      ),
                    ),
                  ],
                );
              },
            ),

            // ── LAYER 3 — Noise grain ──────────────────────────
            const Opacity(
              opacity: 0.040,
              child: _NoiseTexture(),
            ),

            // ── LAYER 4 — UI content ───────────────────────────
            Column(
              children: [
                SizedBox(height: pad.top),
                Expanded(
                  child: Align(
                    alignment: const Alignment(0.0, 0.05),
                    child: AnimatedBuilder(
                      animation: _textCtrl,
                      builder: (_, __) {
                        Widget text = const _WordMark();
                        final blurVal = _textBlur.value;
                        if (blurVal > 0.02) {
                          text = ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: blurVal,
                              sigmaY: blurVal,
                            ),
                            child: text,
                          );
                        }
                        return Opacity(
                          opacity: _textOpacity.value,
                          child: Transform.scale(
                            scale: _textScale.value,
                            child: text,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) {
                    final pct = (_progress.value * 100).round();
                    return Opacity(
                      opacity: _progressFade.value,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          28, 0, 28,
                          math.max(pad.bottom + 28, 44),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Initializing...',
                                  style: TextStyle(
                                    fontFamily:    'Inter',
                                    fontSize:      13,
                                    fontWeight:    FontWeight.w500,
                                    color:         Colors.white.withOpacity(0.72),
                                    letterSpacing: 0.05,
                                  ),
                                ),
                                Text(
                                  '$pct%',
                                  style: TextStyle(
                                    fontFamily:  'Inter',
                                    fontSize:    13,
                                    fontWeight:  FontWeight.w600,
                                    color:       Colors.white.withOpacity(0.72),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _LiquidGlassBar(value: _progress.value),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WORDMARK — shimmer gradient from white → lavender
// ══════════════════════════════════════════════════════════════
class _WordMark extends StatelessWidget {
  const _WordMark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),   // white
            Color(0xFFE9D5FF),   // shimmer lavender
          ],
        ).createShader(bounds),
        child: const Text(
          'HayaBook',
          style: TextStyle(
            fontFamily:    'Inter',
            fontSize:      52,
            fontWeight:    FontWeight.w800,
            color:         Colors.white,
            letterSpacing: -1.5,
            height:        1.0,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LIQUID-GLASS PROGRESS BAR
// ══════════════════════════════════════════════════════════════
class _LiquidGlassBar extends StatelessWidget {
  final double value;
  const _LiquidGlassBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.13),
                      Colors.white.withOpacity(0.07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 0.5,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:        Colors.white.withOpacity(0.70),
                          blurRadius:   6,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color:        Colors.white.withOpacity(0.30),
                          blurRadius:   14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.90),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
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
// GLOW BLOB
// ══════════════════════════════════════════════════════════════
class _GlowBlob extends StatelessWidget {
  final double diameter;
  final Color  color;
  final double opacity;
  final double blur;

  const _GlowBlob({
    required this.diameter,
    required this.color,
    this.opacity = 0.6,
    this.blur    = 58,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width:  diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0.0),
            ],
            stops: const [0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// NOISE TEXTURE
// ══════════════════════════════════════════════════════════════
class _NoiseTexture extends StatelessWidget {
  const _NoiseTexture();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _NoisePainter(), child: const SizedBox.expand());
}

class _NoisePainter extends CustomPainter {
  static final _rnd = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = Colors.white;
    for (int i = 0; i < 2600; i++) {
      canvas.drawCircle(
        Offset(
          _rnd.nextDouble() * size.width,
          _rnd.nextDouble() * size.height,
        ),
        0.48,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(_NoisePainter _) => false;
}