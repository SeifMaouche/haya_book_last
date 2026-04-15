// lib/screens/signup_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

const _kPurpleBright = Color(0xFF8B5CF6);
const _kPurpleMid    = Color(0xFF7C3AED);
const _kPurpleDark   = Color(0xFF2E1065);
const _kPurpleBlob   = Color(0xFFA78BFA);
const _kAccent       = Color(0xFFEC4899);

class SignupScreen extends StatefulWidget {
  final String role; // 'client' or 'provider'
  const SignupScreen({Key? key, this.role = 'client'}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {

  // ── Method: 0 = phone, 1 = email ─────────────────────────
  int _tab = 0;
  bool get _isProvider => widget.role == 'provider';
  bool get _useEmail   => _tab == 1;

  // Phone
  final _phoneCtrl = TextEditingController();
  String _countryCode = '+213';
  String _countryFlag = '🇩🇿';
  String _countryName = 'Algeria';

  // Email
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  bool _obscure = true;

  bool _isLoading = false;

  late final AnimationController _cardCtrl;
  late final Animation<double>   _cardOpacity;
  late final Animation<double>   _cardSlide;

  static const _countries = [
    {'flag': '🇩🇿', 'code': '+213', 'name': 'Algeria'},
    {'flag': '🇫🇷', 'code': '+33',  'name': 'France'},
    {'flag': '🇺🇸', 'code': '+1',   'name': 'United States'},
    {'flag': '🇬🇧', 'code': '+44',  'name': 'United Kingdom'},
    {'flag': '🇸🇦', 'code': '+966', 'name': 'Saudi Arabia'},
    {'flag': '🇦🇪', 'code': '+971', 'name': 'UAE'},
    {'flag': '🇲🇦', 'code': '+212', 'name': 'Morocco'},
    {'flag': '🇹🇳', 'code': '+216', 'name': 'Tunisia'},
  ];

  Color get _accent => _isProvider ? _kAccent : _kPurpleMid;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _cardCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 560));
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardCtrl,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _cardSlide = Tween<double>(begin: 48.0, end: 0.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _nameCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  // ── Proceed with phone → OTP ──────────────────────────────
  Future<void> _sendPhoneOtp() async {
    final phone = '$_countryCode ${_phoneCtrl.text.trim()}';
    if (_phoneCtrl.text.trim().isEmpty) {
      _showSnack('Please enter your phone number.');
      return;
    }
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Note: for phone signup, we need some dummy/default password since backend requires it
    final ok = await auth.signup(
      email: '',
      phone: phone,
      password: 'OTP_USER_${DateTime.now().millisecondsSinceEpoch}', // random pass for OTP users
      name: 'New User',
      userType: widget.role,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          role:    widget.role,
          contact: phone,
          isEmail: false,
        ),
      ));
    } else {
      _showSnack(auth.error ?? 'Signup failed. Please try again.');
    }
  }

  // ── Proceed with email → OTP ──────────────────────────────
  Future<void> _sendEmailOtp() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text.trim();

    if (name.isEmpty) { _showSnack('Please enter your name.'); return; }
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Please enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      _showSnack('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.signup(
      email: email,
      password: pass,
      name: name,
      userType: widget.role,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          role:    widget.role,
          contact: email,
          isEmail: true,
        ),
      ));
    } else {
      _showSnack(auth.error ?? 'Signup failed. Please try again.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0B3B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(99))),
        const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(alignment: Alignment.centerLeft,
                child: Text('Select Country', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 17,
                    fontWeight: FontWeight.w700, color: Colors.white)))),
        ..._countries.map((c) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
          title: Text(c['name']!, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, color: Colors.white)),
          trailing: Text(c['code']!, style: TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
              color: _kPurpleBlob)),
          selected: _countryCode == c['code'],
          selectedTileColor: _kPurpleMid.withOpacity(0.20),
          onTap: () {
            setState(() {
              _countryCode = c['code']!;
              _countryFlag = c['flag']!;
              _countryName = c['name']!;
            });
            Navigator.pop(context);
          },
        )),
        const SizedBox(height: 24),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kPurpleDark,
        resizeToAvoidBottomInset: true,
        body: Stack(fit: StackFit.expand, children: [
          // Background
          DecoratedBox(decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(_isProvider ? -0.55 : 0.55, -0.80),
              radius: 1.75,
              colors: _isProvider
                  ? [const Color(0xFF4A1055), _kPurpleMid, _kPurpleDark]
                  : [_kPurpleBright, _kPurpleMid, _kPurpleDark],
            ),
          )),
          Positioned(top: -90, left: -90, child: _GlowBlob(size: 330,
              color: _kPurpleBlob.withOpacity(0.38))),
          Positioned(bottom: -90, right: -90, child: _GlowBlob(size: 310,
              color: _kPurpleBlob.withOpacity(0.38))),
          if (_isProvider)
            Positioned(top: -40, right: -60, child: _GlowBlob(size: 240,
                color: _kAccent.withOpacity(0.18))),

          Column(children: [
            SizedBox(height: pad.top),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(children: [
                _GlassCircleBtn(icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context)),
                const Spacer(),
                _RoleBadge(isProvider: _isProvider),
              ]),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, pad.bottom + 16),
                  child: AnimatedBuilder(
                    animation: _cardCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _cardOpacity.value,
                      child: Transform.translate(
                          offset: Offset(0, _cardSlide.value), child: child),
                    ),
                    child: _GlassCard(child: _buildCardContent()),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, pad.bottom + 16),
              child: Column(children: [
                Text('PROTECTED BY HAYABOOK SECURITY',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 1.8)),
                const SizedBox(height: 14),
                Container(width: 120, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(99))),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Icon
      _GlassIconCircle(isProvider: _isProvider),
      const SizedBox(height: 20),

      // Title
      Text(_isProvider ? 'Join as Provider' : 'Create Account',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 24,
              fontWeight: FontWeight.w800, color: Colors.white,
              letterSpacing: -0.5, height: 1.1)),
      const SizedBox(height: 8),
      Text(
        _isProvider
            ? 'Register your business and start accepting bookings'
            : 'Choose how you want to create your account',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Inter', fontSize: 13,
            color: Colors.white.withOpacity(0.65), height: 1.45),
      ),

      if (_isProvider) ...[
        const SizedBox(height: 18),
        _ProviderPerksRow(),
      ],
      const SizedBox(height: 22),

      // ── Method tab switcher ───────────────────────────────
      _MethodSwitcher(selected: _tab, accent: _accent,
          onChanged: (i) => setState(() {
            _tab = i;
            _phoneCtrl.clear();
            _emailCtrl.clear();
            _passwordCtrl.clear();
            _nameCtrl.clear();
          })),
      const SizedBox(height: 22),

      // ── Phone method ──────────────────────────────────────
      if (_tab == 0) ...[
        _FormLabel('Country'),
        const SizedBox(height: 8),
        _CountryField(flag: _countryFlag, code: _countryCode,
            name: _countryName, onTap: _showCountryPicker),
        const SizedBox(height: 14),
        _FormLabel('Phone Number'),
        const SizedBox(height: 8),
        _GlassInput(controller: _phoneCtrl, hint: '5xx xx xx xx',
            icon: Icons.call_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)]),
        const SizedBox(height: 22),
        _OtpButton(label: 'Send OTP via SMS', loading: _isLoading,
            accent: _accent, onTap: _isLoading ? null : _sendPhoneOtp),
      ],

      // ── Email method ──────────────────────────────────────
      if (_tab == 1) ...[
        _FormLabel('Full Name'),
        const SizedBox(height: 8),
        _GlassInput(controller: _nameCtrl,
            hint: _isProvider ? 'Business name' : 'Ahmed Benali',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name),
        const SizedBox(height: 14),
        _FormLabel('Email Address'),
        const SizedBox(height: 8),
        _GlassInput(controller: _emailCtrl, hint: 'you@example.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _FormLabel('Password'),
        const SizedBox(height: 8),
        _GlassInput(
          controller: _passwordCtrl,
          hint: 'Min. 6 characters',
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.white.withOpacity(0.45),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 26),
        _OtpButton(label: 'Send OTP via Email', loading: _isLoading,
            accent: _accent, onTap: _isLoading ? null : _sendEmailOtp),
      ],

      const SizedBox(height: 20),
      Divider(color: Colors.white.withOpacity(0.12), height: 1),
      const SizedBox(height: 16),

      // Bottom links
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Already have an account?  ',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                color: Colors.white.withOpacity(0.55))),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Log In',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// METHOD SWITCHER  — Phone | Email
// ══════════════════════════════════════════════════════════════
class _MethodSwitcher extends StatelessWidget {
  final int selected; final Color accent;
  final ValueChanged<int> onChanged;
  const _MethodSwitcher({required this.selected, required this.accent,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Row(children: [
        _MBtn(label: 'Phone', icon: Icons.phone_iphone_rounded,
            active: selected == 0, accent: accent,
            onTap: () => onChanged(0)),
        _MBtn(label: 'Email', icon: Icons.mail_outline_rounded,
            active: selected == 1, accent: accent,
            onTap: () => onChanged(1)),
      ]),
    );
  }
}

class _MBtn extends StatelessWidget {
  final String label; final IconData icon;
  final bool active; final Color accent; final VoidCallback onTap;
  const _MBtn({required this.label, required this.icon, required this.active,
    required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: accent.withOpacity(0.30),
              blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14,
              color: active ? Colors.white : Colors.white.withOpacity(0.45)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : Colors.white.withOpacity(0.50))),
        ]),
      ),
    ));
  }
}

// ── Shared widgets ────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.88))));
}

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint; final IconData icon;
  final bool obscure; final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _GlassInput({required this.controller, required this.hint,
    required this.icon, this.obscure = false, this.suffix,
    this.keyboardType, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.20), width: 1),
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(icon, color: Colors.white.withOpacity(0.45), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                    filled: true, fillColor: Colors.transparent),
              ),
              child: TextField(
                controller: controller, obscureText: obscure,
                keyboardType: keyboardType, inputFormatters: inputFormatters,
                cursorColor: Colors.white, cursorWidth: 1.5,
                style: const TextStyle(fontFamily: 'Inter',
                    fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 15,
                      color: Colors.white.withOpacity(0.35)),
                  border: InputBorder.none, enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true, fillColor: Colors.transparent,
                  isDense: true, contentPadding: EdgeInsets.zero,
                ),
              ),
            )),
            if (suffix != null)
              Padding(padding: const EdgeInsets.only(right: 14), child: suffix!),
            const SizedBox(width: 14),
          ]),
        ),
      ),
    );
  }
}

class _CountryField extends StatelessWidget {
  final String flag, code, name; final VoidCallback onTap;
  const _CountryField({required this.flag, required this.code,
    required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.20), width: 1),
          ),
          child: Row(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(flag, style: const TextStyle(fontSize: 22))),
            Expanded(child: Text('$name  $code',
                style: const TextStyle(fontFamily: 'Inter',
                    fontSize: 15, color: Colors.white))),
            Padding(padding: const EdgeInsets.only(right: 14),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.40), size: 20)),
          ]),
        ),
      ),
    ));
  }
}

class _OtpButton extends StatelessWidget {
  final String label; final bool loading;
  final Color accent; final VoidCallback? onTap;
  const _OtpButton({required this.label, required this.loading,
    required this.accent, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(loading ? 0.70 : 1.0),
          borderRadius: BorderRadius.circular(99),
          boxShadow: loading ? [] : [BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18, offset: const Offset(0, 4))],
        ),
        child: Center(child: loading
            ? SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: accent))
            : Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontFamily: 'Inter',
              fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, color: accent, size: 16),
        ])),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isProvider;
  const _RoleBadge({required this.isProvider});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isProvider ? _kAccent.withOpacity(0.22)
                : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
                color: isProvider ? _kAccent.withOpacity(0.55)
                    : Colors.white.withOpacity(0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isProvider ? Icons.store_rounded : Icons.person_rounded,
                color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(isProvider ? 'Provider' : 'Client',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

class _GlassIconCircle extends StatelessWidget {
  final bool isProvider;
  const _GlassIconCircle({required this.isProvider});
  @override
  Widget build(BuildContext context) {
    return ClipOval(child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(width: 72, height: 72,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: isProvider ? _kAccent.withOpacity(0.20)
                  : Colors.white.withOpacity(0.13),
              border: Border.all(
                  color: isProvider ? _kAccent.withOpacity(0.45)
                      : Colors.white.withOpacity(0.28), width: 1.2)),
          child: Icon(isProvider ? Icons.store_rounded : Icons.calendar_month_rounded,
              color: Colors.white, size: 32)),
    ));
  }
}

class _ProviderPerksRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kAccent.withOpacity(0.25))),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PerkItem(icon: Icons.people_rounded,    label: 'Reach\nClients'),
              _PerkItem(icon: Icons.payments_rounded,  label: 'Manage\nBookings'),
              _PerkItem(icon: Icons.bar_chart_rounded, label: 'Track\nEarnings'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerkItem extends StatelessWidget {
  final IconData icon; final String label;
  const _PerkItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: Colors.white.withOpacity(0.90), size: 22),
    const SizedBox(height: 5),
    Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            color: Colors.white.withOpacity(0.72), height: 1.3)),
  ]);
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.13),
                    Colors.white.withOpacity(0.08)]),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: Colors.white.withOpacity(0.35), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                  blurRadius: 40, offset: const Offset(0, 8))]),
          child: child,
        ),
      ),
    );
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
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.28), width: 1)),
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
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    );
  }
}