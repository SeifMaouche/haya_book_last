// lib/screens/welcome_onboarding_screen.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_localizations.dart';

const _kPrimaryDark  = Color(0xFF2E1065);
const _kPrimary      = Color(0xFF7C3AED);
const _kPrimaryLight = Color(0xFF8B5CF6);
const _kBlob         = Color(0xFFA78BFA);
const _kAccent       = Color(0xFFEC4899);
const _kAccentDark   = Color(0xFFBE185D);

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {

  final PageController _pageCtrl = PageController();
  int _page = 0;

  late AnimationController _enterCtrl;
  late Animation<double>   _enterOpacity;
  late Animation<double>   _enterSlide;

  static const List<_PageData> _pages = [
    _PageData(
      type:       PageType.medical,
      title:      'Find Providers\nNear You',
      subtitle:   'Connect instantly with top-rated professionals in your neighborhood with our advanced geolocation booking.',
      topBtnIcon: Icons.close,
      topLabel:   'Mawidi',
      dotActive:  Colors.white,
    ),
    _PageData(
      type:       PageType.calendar,
      title:      'Book in\nSeconds',
      subtitle:   "Experience the future of booking with Mawidi's ultimate glass interface.",
      topBtnIcon: Icons.chevron_left,
      topLabel:   'Mawidi',
      dotActive:  _kAccent,
    ),
    _PageData(
      type:       PageType.confirm,
      title:      'Get Confirmed\nInstantly',
      subtitle:   'Experience seamless validation and instant access to your Mawidi features with our high-end glass technology.',
      topBtnIcon: Icons.arrow_back,
      topLabel:   'Mawidi',
      dotActive:  Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _buildEnterAnim();
    _enterCtrl.forward();
  }

  void _buildEnterAnim() {
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _enterOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _enterSlide = Tween<double>(begin: 32.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut);
    }
  }

  void _goPrev() {
    if (_page > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOut);
    }
  }

  void _onPageChanged(int i) {
    setState(() => _page = i);
    _enterCtrl.reset();
    _enterCtrl.forward();
  }

  // ✅ Navigate to dedicated client route — role baked in, never wrong
  void _goClientSignup() {
    Navigator.pushNamed(context, '/signup/client');
  }

  // ✅ Navigate to dedicated provider route — role baked in, never wrong
  void _goProviderSignup() {
    Navigator.pushNamed(context, '/signup/provider');
  }

  @override
  Widget build(BuildContext context) {
    final data = _pages[_page];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kPrimaryDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _Background(page: _page),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    page:     _page,
                    pageData: data,
                    onClose: _goClientSignup,
                    onBack: _goPrev,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller:    _pageCtrl,
                      onPageChanged: _onPageChanged,
                      itemCount:     _pages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, i) => AnimatedBuilder(
                        animation: _enterCtrl,
                        builder: (_, child) => Opacity(
                          opacity: _enterOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _enterSlide.value),
                            child: child,
                          ),
                        ),
                        child: _PageContent(data: _pages[i], pageIndex: i),
                      ),
                    ),
                  ),
                  _BottomSection(
                    page:             _page,
                    count:            _pages.length,
                    pageData:         data,
                    onNext:           _goNext,
                    onClientSignup:   _goClientSignup,
                    onProviderSignup: _goProviderSignup,
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

// ── Background ────────────────────────────────────────────────────
class _Background extends StatelessWidget {
  final int page;
  const _Background({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [_kPrimaryDark, _kPrimary, _kBlob],
            ),
          ),
        ),
        CustomPaint(
          painter: _OrganicTexturePainter(),
          child: const SizedBox.expand(),
        ),
        if (page == 0)
          Positioned(
            bottom: -60, right: -60,
            child: _SoftBlob(size: 280,
                color: _kAccent.withOpacity(0.18)),
          ),
      ],
    );
  }
}

class _OrganicTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color       = Colors.white.withOpacity(0.055)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rings = [
      Offset(size.width * 0.75, size.height * 0.12),
      Offset(size.width * 0.10, size.height * 0.35),
      Offset(size.width * 0.85, size.height * 0.55),
      Offset(size.width * 0.15, size.height * 0.72),
      Offset(size.width * 0.60, size.height * 0.88),
    ];
    final radii = [110.0, 90.0, 130.0, 100.0, 120.0];

    for (int i = 0; i < rings.length; i++) {
      canvas.drawCircle(rings[i], radii[i], p);
      canvas.drawCircle(rings[i], radii[i] * 0.72,
          p..strokeWidth = 0.8);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Top Bar ───────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int        page;
  final _PageData  pageData;
  final VoidCallback onClose;
  final VoidCallback onBack;

  const _TopBar({
    required this.page,
    required this.pageData,
    required this.onClose,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = page == 0;
    final isCaps  = page == 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _GlassCircleBtn(
            icon:  isFirst ? Icons.close : Icons.arrow_back,
            size:  isFirst ? 20 : 22,
            onTap: isFirst ? onClose : onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                pageData.topLabel,
                style: TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      isCaps ? 13 : 17,
                  fontWeight:    FontWeight.w700,
                  color:         Colors.white,
                  letterSpacing: isCaps ? 2.0 : 0.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

// ── Page Content ──────────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final _PageData data;
  final int       pageIndex;
  const _PageContent({required this.data, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case PageType.medical:  return _Page0Medical(data: data);
      case PageType.calendar: return _Page1Calendar(data: data);
      case PageType.confirm:  return _Page2Confirm(data: data);
    }
  }
}

// ── Page 0 ────────────────────────────────────────────────────────
class _Page0Medical extends StatelessWidget {
  final _PageData data;
  const _Page0Medical({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            flex: 5,
            child: Stack(
              alignment:    Alignment.center,
              clipBehavior: Clip.none,
              children: [
                _GlassRing(outerDia: 280, innerDia: 220),
                Container(
                  width: 220, height: 220,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
                      center: Alignment(-0.3, -0.3),
                    ),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      color: Colors.white, size: 90),
                ),
                Positioned(
                  right: 10, bottom: 30,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: _GlassRoundedRect(
                      width: 72, height: 72, radius: 18,
                      tintOpacity: 0.18, blurSigma: 14,
                      child: const Icon(Icons.location_on_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _TextGlassCard(data: data),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Page 1 ────────────────────────────────────────────────────────
class _Page1Calendar extends StatelessWidget {
  final _PageData data;
  const _Page1Calendar({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            flex: 5,
            child: _GlassRoundedRect(
              width: double.infinity, height: double.infinity,
              radius: 32, tintOpacity: 0.13, blurSigma: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 28, right: 36,
                      child: _SmallGlassCircle(size: 48)),
                  Positioned(bottom: 44, left: 44,
                      child: _SmallGlassCircle(size: 34)),
                  _GlassRing(outerDia: 200, innerDia: 156),
                  Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.10),
                            blurRadius: 22, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: _kAccent, size: 56),
                        const SizedBox(height: 8),
                        Container(
                          width: 36, height: 3,
                          decoration: BoxDecoration(
                            color: _kAccent.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _TextGlassCard(data: data),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Page 2 ────────────────────────────────────────────────────────
class _Page2Confirm extends StatelessWidget {
  final _PageData data;
  const _Page2Confirm({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Expanded(
            flex: 4,
            child: _GlassRoundedRect(
              width: double.infinity, height: double.infinity,
              radius: 28, tintOpacity: 0.13, blurSigma: 18,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 190, height: 190,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                  ),
                  Container(
                    width: 160, height: 160,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFDDD6FE)),
                  ),
                  Container(
                    width: 100, height: 100,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _kPrimary),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 50),
                  ),
                  Positioned(
                    top: 32, right: 40,
                    child: Transform.rotate(
                      angle: 0.10,
                      child: _GlassRoundedRect(
                        width: 52, height: 52, radius: 14,
                        tintOpacity: 0.22, blurSigma: 12,
                        child: const Icon(Icons.verified_user_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: 60, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 34, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -0.5, height: 1.18,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                color: Colors.white.withOpacity(0.88), height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Bottom Section ────────────────────────────────────────────────
class _BottomSection extends StatelessWidget {
  final int        page;
  final int        count;
  final _PageData  pageData;
  final VoidCallback onNext;
  final VoidCallback onClientSignup;
  final VoidCallback onProviderSignup;

  const _BottomSection({
    required this.page,
    required this.count,
    required this.pageData,
    required this.onNext,
    required this.onClientSignup,
    required this.onProviderSignup,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page == count - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              final active = i == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve:    Curves.easeInOut,
                margin:   const EdgeInsets.symmetric(horizontal: 4),
                width:    active ? 28 : 7,
                height:   7,
                decoration: BoxDecoration(
                  color: active
                      ? pageData.dotActive
                      : Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow:
                  (active && pageData.dotActive == _kAccent)
                      ? [BoxShadow(color: _kAccent.withOpacity(0.55),
                      blurRadius: 10, spreadRadius: 1)]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          if (isLast) ...[
            _DualCtaButtons(
              onClientTap:   onClientSignup,
              onProviderTap: onProviderSignup,
            ),
          ] else ...[
            _ArrowCircleButton(onTap: onNext, page: page),
            const SizedBox(height: 12),
            Text(
              'NEXT STEP',
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.52), letterSpacing: 2.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Dual CTA Buttons ──────────────────────────────────────────────
class _DualCtaButtons extends StatelessWidget {
  final VoidCallback onClientTap;
  final VoidCallback onProviderTap;

  const _DualCtaButtons({
    required this.onClientTap,
    required this.onProviderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary — Book a Service
        GestureDetector(
          onTap: onClientTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity, height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.50), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08),
                        blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: _kPrimaryDark, size: 20),
                    SizedBox(width: 10),
                    Text('Book a Service',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 17,
                          fontWeight: FontWeight.w700, color: _kPrimaryDark,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary — Join as Provider
        GestureDetector(
          onTap: onProviderTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity, height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.38), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kAccent.withOpacity(0.22),
                        border: Border.all(
                            color: _kAccent.withOpacity(0.55), width: 1.2),
                      ),
                      child: const Icon(Icons.store_rounded,
                          color: Colors.white, size: 15),
                    ),
                    const SizedBox(width: 10),
                    const Text('Join as Provider',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 17,
                          fontWeight: FontWeight.w600, color: Colors.white,
                        )),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.55), size: 13),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            'Already have an account? Log In',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Atom Widgets ──────────────────────────────────────────────────
class _GlassCircleBtn extends StatelessWidget {
  final IconData     icon;
  final double       size;
  final VoidCallback onTap;
  const _GlassCircleBtn(
      {required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                  color: Colors.white.withOpacity(0.28), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }
}

class _GlassRing extends StatelessWidget {
  final double outerDia;
  final double innerDia;
  const _GlassRing({required this.outerDia, required this.innerDia});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: outerDia, height: outerDia,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(
                color: Colors.white.withOpacity(0.22), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _GlassRoundedRect extends StatelessWidget {
  final double?  width;
  final double?  height;
  final double   radius;
  final double   tintOpacity;
  final double   blurSigma;
  final Widget   child;

  const _GlassRoundedRect({
    this.width, this.height,
    required this.radius,
    required this.tintOpacity,
    required this.blurSigma,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width, height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(tintOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: Colors.white.withOpacity(0.24), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TextGlassCard extends StatelessWidget {
  final _PageData data;
  const _TextGlassCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _GlassRoundedRect(
      width: double.infinity, radius: 28,
      tintOpacity: 0.12, blurSigma: 20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: -0.5, height: 1.18,
                )),
            const SizedBox(height: 12),
            Text(data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 15,
                  color: Colors.white.withOpacity(0.86), height: 1.55,
                )),
          ],
        ),
      ),
    );
  }
}

class _SmallGlassCircle extends StatelessWidget {
  final double size;
  const _SmallGlassCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
                color: Colors.white.withOpacity(0.16), width: 1),
          ),
        ),
      ),
    );
  }
}

class _ArrowCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final int          page;
  const _ArrowCircleButton({required this.onTap, required this.page});

  @override
  Widget build(BuildContext context) {
    if (page == 0) {
      return GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.13),
                border: Border.all(
                    color: Colors.white.withOpacity(0.32), width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: const Icon(Icons.arrow_forward,
                      color: _kPrimary, size: 22),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                    color: Colors.white.withOpacity(0.28), width: 1.5),
              ),
              child: const Icon(Icons.arrow_forward,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
      );
    }
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final Color  color;
  const _SoftBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────────
enum PageType { medical, calendar, confirm }

class _PageData {
  final PageType type;
  final String   title;
  final String   subtitle;
  final IconData topBtnIcon;
  final String   topLabel;
  final Color    dotActive;

  const _PageData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.topBtnIcon,
    required this.topLabel,
    required this.dotActive,
  });
}