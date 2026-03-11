// lib/screens/otp_verification_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';

// ─── Purple constants — replaces all _kTeal* ─────────────────────────────────
const _kPurpleBright = Color(0xFF8B5CF6); // gradientTop
const _kPurpleDark1  = Color(0xFF1A0A3C); // bgNearBlack
const _kPurpleDark2  = Color(0xFF2E1065); // bgDarkPurple
const _kFocusViolet  = Color(0xFF7C3AED); // primary — replaces blue focus

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {

  final List<String> _digits      = List.filled(6, '');
  int                _activeIndex = 0;

  bool   _isVerifying = false;
  int    _secondsLeft = 30;
  Timer? _timer;

  late final AnimationController _cardCtrl;
  late final Animation<double>   _cardOpacity;
  late final Animation<double>   _cardSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _cardCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 520),
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardCtrl,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _cardSlide = Tween<double>(begin: 44.0, end: 0.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardCtrl.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft == 0) { t.cancel(); }
      else { setState(() => _secondsLeft--); }
    });
  }

  void _onDigit(String d) {
    if (_activeIndex >= 6) return;
    setState(() {
      _digits[_activeIndex] = d;
      if (_activeIndex < 5) _activeIndex++;
    });
    if (_digits.every((x) => x.isNotEmpty)) _verify();
  }

  void _onBackspace() {
    setState(() {
      if (_digits[_activeIndex].isNotEmpty) {
        _digits[_activeIndex] = '';
      } else if (_activeIndex > 0) {
        _activeIndex--;
        _digits[_activeIndex] = '';
      }
    });
  }

  void _onBoxTap(int index) => setState(() => _activeIndex = index);

  Future<void> _verify() async {
    final code = _digits.join();
    if (code.length < 6 || _digits.any((d) => d.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter the complete 6-digit code.',
            style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
      return;
    }
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    Navigator.pushNamedAndRemoveUntil(
        context, '/complete-profile', (_) => false);
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    setState(() {
      _digits.fillRange(0, 6, '');
      _activeIndex = 0;
    });
    _startTimer();
  }

  bool get _allFilled => _digits.every((d) => d.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final pad     = MediaQuery.of(context).padding;
    final screenH = MediaQuery.of(context).size.height;
    final scale   = (screenH / 812.0).clamp(0.75, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor:          _kPurpleDark1,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [

            // Purple gradient — replaces teal gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [_kPurpleBright, _kPurpleDark1, _kPurpleDark2],
                ),
              ),
            ),

            Positioned(
              top: -130, left: -90,
              child: _GlowBlob(size: 370,
                  color: _kPurpleBright.withOpacity(0.40)),
            ),
            Positioned(
              bottom: -90, right: -70,
              child: _GlowBlob(size: 320,
                  color: _kPurpleBright.withOpacity(0.26)),
            ),

            Column(
              children: [
                SizedBox(height: pad.top),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _GlassCircleBtn(
                      icon:  Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          16, 8, 16, pad.bottom + 8),
                      child: AnimatedBuilder(
                        animation: _cardCtrl,
                        builder: (_, child) => Opacity(
                          opacity: _cardOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _cardSlide.value),
                            child: child,
                          ),
                        ),
                        child: _buildGlassCard(context, scale),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, double scale) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20 * scale, 20, 16 * scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.07),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.10),
                blurRadius: 40,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LockIconTile(size: 58 * scale),
              SizedBox(height: 14 * scale),
              Text(
                'Verify Phone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      26 * scale,
                  fontWeight:    FontWeight.w800,
                  color:         Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'We sent a 6-digit code to your phone',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   13 * scale,
                  color:      Colors.white.withOpacity(0.80),
                  height:     1.4,
                ),
              ),
              SizedBox(height: 20 * scale),
              _OtpBoxRow(
                digits:      _digits,
                activeIndex: _activeIndex,
                onBoxTap:    _onBoxTap,
                scale:       scale,
              ),
              SizedBox(height: 18 * scale),
              Text(
                "Didn't receive code?",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   13 * scale,
                  color:      Colors.white.withOpacity(0.68),
                ),
              ),
              SizedBox(height: 8 * scale),
              _ResendPill(secondsLeft: _secondsLeft, onTap: _resend, scale: scale),
              SizedBox(height: 20 * scale),
              _VerifyButton(
                isVerifying: _isVerifying,
                enabled:     _allFilled && !_isVerifying,
                onTap:       _verify,
                scale:       scale,
              ),
              SizedBox(height: 12 * scale),
              Text(
                'HAYABOOK SECURE ENTRY',
                style: TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      9 * scale,
                  fontWeight:    FontWeight.w600,
                  color:         Colors.white.withOpacity(0.35),
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 14 * scale),
              _Numpad(
                onDigit:     _onDigit,
                onBackspace: _onBackspace,
                scale:       scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LOCK ICON TILE
// ══════════════════════════════════════════════════════════════
class _LockIconTile extends StatelessWidget {
  final double size;
  const _LockIconTile({this.size = 62});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color:        _kPurpleBright.withOpacity(0.28),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: Icon(Icons.lock_open_rounded,
              color: Colors.white, size: size * 0.48),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// OTP BOX ROW
// ══════════════════════════════════════════════════════════════
class _OtpBoxRow extends StatelessWidget {
  final List<String>      digits;
  final int               activeIndex;
  final ValueChanged<int> onBoxTap;
  final double            scale;

  const _OtpBoxRow({
    required this.digits,
    required this.activeIndex,
    required this.onBoxTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final cardInnerW = MediaQuery.of(context).size.width - 32 - 40;
    final boxW = (cardInnerW - 5 * 5) / 6;
    final boxH = boxW * 1.05;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
        width:     boxW,
        height:    boxH,
        value:     digits[i],
        isFilled:  digits[i].isNotEmpty,
        isFocused: i == activeIndex,
        onTap:     () => onBoxTap(i),
        scale:     scale,
      )),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final double width, height;
  final String value;
  final bool   isFilled, isFocused;
  final VoidCallback onTap;
  final double scale;

  const _OtpBox({
    required this.width,
    required this.height,
    required this.value,
    required this.isFilled,
    required this.isFocused,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color  bg;
    final Border border;

    if (isFilled) {
      bg     = Colors.white.withOpacity(0.18);
      border = Border.all(color: Colors.white.withOpacity(0.55), width: 2.0);
    } else if (isFocused) {
      bg     = Colors.white.withOpacity(0.15);
      border = Border.all(color: _kFocusViolet, width: 2.5); // purple focus
    } else {
      bg     = Colors.white.withOpacity(0.10);
      border = Border.all(color: Colors.white.withOpacity(0.26), width: 1.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration:    const Duration(milliseconds: 160),
            width:       width,
            height:      height,
            decoration: BoxDecoration(
              color:        bg,
              borderRadius: BorderRadius.circular(14),
              border:       border,
            ),
            child: Center(child: _boxContent()),
          ),
        ),
      ),
    );
  }

  Widget _boxContent() {
    if (isFilled) {
      return Text(value,
          style: TextStyle(
            fontFamily:  'Inter',
            fontSize:    20 * scale,
            fontWeight:  FontWeight.w700,
            color:       Colors.white,
          ));
    } else if (isFocused) {
      return Container(
        width: 2, height: 16 * scale,
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(99),
        ),
      );
    } else {
      return Container(
        width: 5, height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.38),
        ),
      );
    }
  }
}

// ══════════════════════════════════════════════════════════════
// RESEND PILL
// ══════════════════════════════════════════════════════════════
class _ResendPill extends StatelessWidget {
  final int          secondsLeft;
  final VoidCallback onTap;
  final double       scale;

  const _ResendPill({
    required this.secondsLeft,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: 9 * scale),
            decoration: BoxDecoration(
              color:        Colors.black.withOpacity(0.30),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                  color: Colors.white.withOpacity(0.07), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    color: Colors.white.withOpacity(canResend ? 1.0 : 0.90),
                    size: 13 * scale),
                const SizedBox(width: 6),
                Text(
                  canResend ? 'Resend Code' : 'Resend in ${secondsLeft}s',
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    13 * scale,
                    fontWeight:  FontWeight.w700,
                    color:       Colors.white.withOpacity(canResend ? 1.0 : 0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// VERIFY BUTTON — purple fill instead of teal
// ══════════════════════════════════════════════════════════════
class _VerifyButton extends StatelessWidget {
  final bool         isVerifying;
  final bool         enabled;
  final VoidCallback onTap;
  final double       scale;

  const _VerifyButton({
    required this.isVerifying,
    required this.enabled,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration:    const Duration(milliseconds: 150),
        width:       double.infinity,
        height:      52 * scale,
        decoration: BoxDecoration(
          color:        enabled
              ? _kPurpleBright
              : _kPurpleBright.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [BoxShadow(
            color:      _kPurpleBright.withOpacity(0.38),
            blurRadius: 20,
            offset:     const Offset(0, 5),
          )]
              : [],
        ),
        child: Center(
          child: isVerifying
              ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Verify',
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    16 * scale,
                    fontWeight:  FontWeight.w700,
                    color:       Colors.white,
                  )),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 22 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// NUMPAD
// ══════════════════════════════════════════════════════════════
class _Numpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback         onBackspace;
  final double               scale;

  const _Numpad({
    required this.onDigit,
    required this.onBackspace,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _numpadRow(context, ['1', '2', '3']),
        _numpadRow(context, ['4', '5', '6']),
        _numpadRow(context, ['7', '8', '9']),
        _numpadRow(context, ['', '0', '⌫']),
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _numpadRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys.map((key) {
        if (key.isEmpty) return const Expanded(child: SizedBox());
        final isBackspace = key == '⌫';
        return Expanded(
          child: GestureDetector(
            onTap: isBackspace ? onBackspace : () => onDigit(key),
            child: Container(
              height:    52 * scale,
              alignment: Alignment.center,
              child: isBackspace
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:        Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.backspace_outlined,
                        color: Colors.white, size: 18 * scale),
                  ),
                ),
              )
                  : Text(key,
                  style: TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    24 * scale,
                    fontWeight:  FontWeight.w400,
                    color:       Colors.white,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GLASS CIRCLE BUTTON
// ══════════════════════════════════════════════════════════════
class _GlassCircleBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _GlassCircleBtn({required this.icon, required this.onTap});

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
              shape:  BoxShape.circle,
              color:  Colors.white.withOpacity(0.13),
              border: Border.all(
                  color: Colors.white.withOpacity(0.25), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
  final double size;
  final Color  color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0.0)],
            stops:  const [0.35, 1.0],
          ),
        ),
      ),
    );
  }
}