// lib/screens/otp_verification_screen.dart
//
// Works for: phone OTP, email OTP, client role, provider role.
// All params passed via constructor — no route args parsing.
// ─────────────────────────────────────────────────────────────
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

const _kPurpleBright = Color(0xFF8B5CF6);
const _kPurpleDark1  = Color(0xFF1A0A3C);
const _kPurpleDark2  = Color(0xFF2E1065);
const _kFocusViolet  = Color(0xFF7C3AED);
const _kAccent       = Color(0xFFEC4899);

class OtpVerificationScreen extends StatefulWidget {
  final String role;    // 'client' | 'provider'
  final String contact; // phone number or email address
  final bool   isEmail; // true → email OTP, false → SMS OTP

  const OtpVerificationScreen({
    Key? key,
    this.role    = 'client',
    this.contact = '',
    this.isEmail = false,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {

  final List<String> _digits      = List.filled(6, '');
  int                _activeIndex = 0;
  bool               _isVerifying = false;
  int                _secondsLeft = 30;
  Timer?             _timer;
  String?            _error;

  late final AnimationController _cardCtrl;
  late final Animation<double>   _cardOpacity;
  late final Animation<double>   _cardSlide;

  bool get _isProvider => widget.role == 'provider';
  Color get _accent    => _isProvider ? _kAccent : _kPurpleBright;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _cardCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 520));
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
      if (_secondsLeft == 0) { t.cancel(); return; }
      setState(() => _secondsLeft--);
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
    if (_digits.any((d) => d.isEmpty)) return;
    setState(() { _isVerifying = true; _error = null; });
    
    final code = _digits.join();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final ok = await auth.verifyPhoneOtp(widget.contact, code);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (ok) {
      // ✅ Smart Routing: where to send the user next?
      if (auth.profileComplete) {
        // Returning user → Go to correct Home
        final dest = auth.userType == 'provider' ? '/provider/home' : '/';
        Navigator.pushNamedAndRemoveUntil(context, dest, (_) => false);
      } else {
        // New user or incomplete profile → Go to Setup
        if (auth.userType == 'provider') {
          Navigator.pushNamedAndRemoveUntil(context, '/provider/setup', (_) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/complete-profile', (_) => false);
        }
      }
    } else {
      setState(() => _error = auth.error ?? 'Invalid code. Please try again.');
      // Clear digits on error
      setState(() {
        _digits.fillRange(0, 6, '');
        _activeIndex = 0;
      });
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _isVerifying) return;
    
    setState(() {
      _isVerifying = true;
      _error = null;
      _digits.fillRange(0, 6, '');
      _activeIndex = 0;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.resendOtp(widget.contact);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (ok) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('New code sent successfully!', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
    } else {
      setState(() => _error = auth.error ?? 'Failed to resend code. Please try again.');
    }
  }

  bool get _allFilled => _digits.every((d) => d.isNotEmpty);

  // ── Masked contact display ────────────────────────────────
  String get _maskedContact {
    final c = widget.contact;
    if (c.isEmpty) return '';
    if (widget.isEmail) {
      final parts = c.split('@');
      if (parts.length < 2) return c;
      final name = parts[0];
      final masked = name.length > 2
          ? '${name.substring(0, 2)}***@${parts[1]}'
          : '***@${parts[1]}';
      return masked;
    } else {
      // Phone: show last 4 digits
      final clean = c.replaceAll(' ', '');
      if (clean.length > 4) {
        return '•••• ${clean.substring(clean.length - 4)}';
      }
      return c;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad     = MediaQuery.of(context).padding;
    final screenH = MediaQuery.of(context).size.height;
    final scale   = (screenH / 812.0).clamp(0.75, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kPurpleDark1,
        resizeToAvoidBottomInset: false,
        body: Stack(fit: StackFit.expand, children: [
          // Background
          DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: _isProvider
                  ? [const Color(0xFF4A1055), _kPurpleDark1, _kPurpleDark2]
                  : [_kPurpleBright, _kPurpleDark1, _kPurpleDark2],
            ),
          )),
          Positioned(top: -130, left: -90, child: _GlowBlob(
              size: 370, color: _accent.withOpacity(0.35))),
          Positioned(bottom: -90, right: -70, child: _GlowBlob(
              size: 320, color: _accent.withOpacity(0.22))),

          Column(children: [
            SizedBox(height: pad.top),
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(children: [
                _GlassCircleBtn(icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context)),
                const Spacer(),
                // Show contact + method badge
                if (widget.contact.isNotEmpty)
                  _ContactPill(
                    contact:    _maskedContact,
                    isEmail:    widget.isEmail,
                    isProvider: _isProvider,
                  ),
              ]),
            ),
            Expanded(child: Center(child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 8, 16, pad.bottom + 8),
              child: AnimatedBuilder(
                animation: _cardCtrl,
                builder: (_, child) => Opacity(
                  opacity: _cardOpacity.value,
                  child: Transform.translate(
                      offset: Offset(0, _cardSlide.value), child: child),
                ),
                child: _buildCard(scale),
              ),
            ))),
          ]),
        ]),
      ),
    );
  }

  Widget _buildCard(double scale) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20 * scale, 20, 16 * scale),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.07)]),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: Colors.white.withOpacity(0.20), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10),
                  blurRadius: 40, offset: const Offset(0, 8))]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Lock/icon tile
            _LockIconTile(size: 58 * scale, isProvider: _isProvider,
                isEmail: widget.isEmail),
            SizedBox(height: 14 * scale),

            Text(
              _isProvider ? 'Verify Your Number' : 'Enter the Code',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter',
                  fontSize: 26 * scale, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 6 * scale),

            // Subtitle with masked contact
            RichText(textAlign: TextAlign.center, text: TextSpan(
              style: TextStyle(fontFamily: 'Inter', fontSize: 13 * scale,
                  color: Colors.white.withOpacity(0.72), height: 1.4),
              children: [
                TextSpan(text: widget.isEmail
                    ? 'We sent a 6-digit code to\n'
                    : 'We sent a 6-digit SMS to\n'),
                TextSpan(
                  text: _maskedContact,
                  style: TextStyle(fontFamily: 'Inter',
                      fontSize: 13 * scale, fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95)),
                ),
              ],
            )),
            // Error display
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ],
            SizedBox(height: 22 * scale),

            // OTP boxes
            _OtpBoxRow(digits: _digits, activeIndex: _activeIndex,
                onBoxTap: _onBoxTap, scale: scale, accent: _accent),
            SizedBox(height: 18 * scale),

            Text("Didn't receive it?",
                style: TextStyle(fontFamily: 'Inter',
                    fontSize: 13 * scale,
                    color: Colors.white.withOpacity(0.68))),
            SizedBox(height: 8 * scale),

            _ResendPill(secondsLeft: _secondsLeft,
                onTap: _resend, scale: scale, accent: _accent),
            SizedBox(height: 20 * scale),

            _VerifyButton(isVerifying: _isVerifying,
                enabled: _allFilled && !_isVerifying,
                onTap: _verify, scale: scale, accent: _accent),
            SizedBox(height: 12 * scale),

            Text('HAYABOOK SECURE ENTRY',
                style: TextStyle(fontFamily: 'Inter',
                    fontSize: 9 * scale, fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.35),
                    letterSpacing: 1.8)),
            SizedBox(height: 14 * scale),

            _Numpad(onDigit: _onDigit,
                onBackspace: _onBackspace, scale: scale),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONTACT PILL  — shows phone/email with icon
// ══════════════════════════════════════════════════════════════
class _ContactPill extends StatelessWidget {
  final String contact; final bool isEmail; final bool isProvider;
  const _ContactPill({required this.contact, required this.isEmail,
    required this.isProvider});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(99),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white.withOpacity(0.20), width: 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isEmail ? Icons.mail_outline_rounded
                : Icons.phone_iphone_rounded,
                color: Colors.white.withOpacity(0.70), size: 12),
            const SizedBox(width: 5),
            Text(contact, style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: Colors.white.withOpacity(0.80),
                fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LOCK ICON TILE
// ══════════════════════════════════════════════════════════════
class _LockIconTile extends StatelessWidget {
  final double size; final bool isProvider; final bool isEmail;
  const _LockIconTile({this.size = 62, required this.isProvider,
    required this.isEmail});

  @override
  Widget build(BuildContext context) {
    final color = isProvider ? _kAccent : _kPurpleBright;
    return ClipRRect(borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(width: size, height: size,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withOpacity(0.45), width: 1)),
                child: Icon(
                    isEmail ? Icons.mark_email_read_rounded
                        : isProvider ? Icons.store_rounded : Icons.lock_open_rounded,
                    color: Colors.white, size: size * 0.48))));
  }
}

// ══════════════════════════════════════════════════════════════
// OTP BOX ROW
// ══════════════════════════════════════════════════════════════
class _OtpBoxRow extends StatelessWidget {
  final List<String> digits; final int activeIndex;
  final ValueChanged<int> onBoxTap; final double scale; final Color accent;
  const _OtpBoxRow({required this.digits, required this.activeIndex,
    required this.onBoxTap, this.scale = 1.0, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cardInnerW = MediaQuery.of(context).size.width - 32 - 40;
    final boxW = (cardInnerW - 5 * 5) / 6;
    final boxH = boxW * 1.05;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) => _OtpBox(
            width: boxW, height: boxH,
            value: digits[i],
            isFilled: digits[i].isNotEmpty, isFocused: i == activeIndex,
            onTap: () => onBoxTap(i), scale: scale, focusColor: accent)));
  }
}

class _OtpBox extends StatelessWidget {
  final double width, height; final String value;
  final bool isFilled, isFocused; final VoidCallback onTap;
  final double scale; final Color focusColor;
  const _OtpBox({required this.width, required this.height, required this.value,
    required this.isFilled, required this.isFocused, required this.onTap,
    this.scale = 1.0, required this.focusColor});

  @override
  Widget build(BuildContext context) {
    final Color  bg;
    final Border border;
    if (isFilled) {
      bg = Colors.white.withOpacity(0.18);
      border = Border.all(color: Colors.white.withOpacity(0.55), width: 2.0);
    } else if (isFocused) {
      bg = Colors.white.withOpacity(0.15);
      border = Border.all(color: focusColor, width: 2.5);
    } else {
      bg = Colors.white.withOpacity(0.10);
      border = Border.all(color: Colors.white.withOpacity(0.26), width: 1.5);
    }
    return GestureDetector(onTap: onTap, child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: width, height: height,
              decoration: BoxDecoration(color: bg,
                  borderRadius: BorderRadius.circular(14), border: border),
              child: Center(child: _content()))),
    ));
  }

  Widget _content() {
    if (isFilled) {
      return Text(value, style: TextStyle(fontFamily: 'Inter',
          fontSize: 20 * scale, fontWeight: FontWeight.w700,
          color: Colors.white));
    } else if (isFocused) {
      return Container(width: 2, height: 16 * scale,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(99)));
    } else {
      return Container(width: 5, height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.38)));
    }
  }
}

// ══════════════════════════════════════════════════════════════
// RESEND PILL
// ══════════════════════════════════════════════════════════════
class _ResendPill extends StatelessWidget {
  final int secondsLeft; final VoidCallback onTap;
  final double scale; final Color accent;
  const _ResendPill({required this.secondsLeft, required this.onTap,
    this.scale = 1.0, required this.accent});

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0;
    return GestureDetector(onTap: onTap, child: ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9 * scale),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.30),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: canResend
                  ? accent.withOpacity(0.50)
                  : Colors.white.withOpacity(0.07), width: 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(canResend ? Icons.refresh_rounded : Icons.schedule_rounded,
                color: Colors.white.withOpacity(canResend ? 1.0 : 0.70),
                size: 13 * scale),
            const SizedBox(width: 6),
            Text(canResend ? 'Resend Code'
                : 'Resend in ${secondsLeft}s',
                style: TextStyle(fontFamily: 'Inter',
                    fontSize: 13 * scale, fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(canResend ? 1.0 : 0.70))),
          ]),
        ),
      ),
    ));
  }
}

// ══════════════════════════════════════════════════════════════
// VERIFY BUTTON
// ══════════════════════════════════════════════════════════════
class _VerifyButton extends StatelessWidget {
  final bool isVerifying, enabled; final VoidCallback onTap;
  final double scale; final Color accent;
  const _VerifyButton({required this.isVerifying, required this.enabled,
    required this.onTap, this.scale = 1.0, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 52 * scale,
        decoration: BoxDecoration(
            color: enabled ? accent : accent.withOpacity(0.40),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled ? [BoxShadow(color: accent.withOpacity(0.40),
                blurRadius: 20, offset: const Offset(0, 5))] : []),
        child: Center(child: isVerifying
            ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Verify & Continue',
              style: TextStyle(fontFamily: 'Inter',
                  fontSize: 16 * scale, fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white, size: 22 * scale),
        ])),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// NUMPAD
// ══════════════════════════════════════════════════════════════
class _Numpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace; final double scale;
  const _Numpad({required this.onDigit, required this.onBackspace,
    this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _row(context, ['1','2','3']),
      _row(context, ['4','5','6']),
      _row(context, ['7','8','9']),
      _row(context, ['','0','⌫']),
      const SizedBox(height: 2),
    ]);
  }

  Widget _row(BuildContext ctx, List<String> keys) {
    return Row(children: keys.map((key) {
      if (key.isEmpty) return const Expanded(child: SizedBox());
      final isBack = key == '⌫';
      return Expanded(child: GestureDetector(
        onTap: isBack ? onBackspace : () => onDigit(key),
        child: Container(
          height: 52 * scale, alignment: Alignment.center,
          child: isBack
              ? ClipRRect(borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.backspace_outlined,
                          color: Colors.white, size: 18 * scale))))
              : Text(key, style: TextStyle(fontFamily: 'Inter',
              fontSize: 24 * scale, fontWeight: FontWeight.w400,
              color: Colors.white)),
        ),
      ));
    }).toList());
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _GlassCircleBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: ClipOval(
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.13),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1)),
              child: Icon(icon, color: Colors.white, size: 20))),
    ));
  }
}

class _GlowBlob extends StatelessWidget {
  final double size; final Color color;
  const _GlowBlob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
      child: Container(width: size, height: size,

          decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(
                  colors: [color, color.withOpacity(0.0)],
                  stops: const [0.35, 1.0]))),
    );
  }
}