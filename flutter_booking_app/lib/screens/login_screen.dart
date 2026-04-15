// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

const _kBg         = Color(0xFF0F0720);
const _kPrimary    = Color(0xFF7C3AED);
const _kPrimaryMid = Color(0xFF6D28D9);
const _kLavender   = Color(0xFFA78BFA);
const _kAccent     = Color(0xFFEC4899);

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  // ── Role: 0 = client, 1 = provider ───────────────────────
  int _role = 0;
  bool get _isProvider => _role == 1;

  // ── Input method: 0 = phone, 1 = email ───────────────────
  int _tab = 0;

  // Phone
  final _phoneCtrl = TextEditingController();
  String _countryCode = '+213';
  String _countryFlag = '🇩🇿';
  String _countryName = 'Algeria';

  // Email
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  bool    _isLoading = false;
  String? _error;

  late final AnimationController _enterCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  // Role switch animation
  late final AnimationController _roleCtrl;

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _enterCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _enterCtrl, curve: Curves.easeOutCubic));

    _roleCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 300));

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose(); _roleCtrl.dispose();
    _phoneCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Switch role ───────────────────────────────────────────
  void _switchRole(int r) {
    if (_role == r) return;
    setState(() {
      _role  = r;
      _tab   = 0;
      _error = null;
      _phoneCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
    });
    _roleCtrl.reset();
    _roleCtrl.forward();
  }

  // ── Login with phone → OTP ────────────────────────────────
  Future<void> _loginWithPhone() async {
    final phone = '$_countryCode ${_phoneCtrl.text.trim()}';
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your phone number.');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.loginWithPhone(phone);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      // OTP verification — same screen for both roles
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          role:    _isProvider ? 'provider' : 'client',
          contact: phone,
          isEmail: false,
        ),
      ));
    } else {
      setState(() => _error = auth.error ?? 'Failed to send OTP. Please check your connection.');
    }
  }

  // ── Login with email ──────────────────────────────────────
  Future<void> _loginWithEmail() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok   = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      // ✅ Use backend-returned role for correct routing
      final role = auth.userType;
      Navigator.pushReplacementNamed(
          context, role == 'provider' ? '/provider/home' : '/');
    } else {
      setState(() => _error = auth.error ?? 'Invalid credentials. Please try again.');
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0B3B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
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
              fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w600, color: _kLavender)),
          selected: _countryCode == c['code'],
          selectedTileColor: _kPrimary.withOpacity(0.20),
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
    final accent = _isProvider ? _kAccent : _kPrimary;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(children: [
        // Background
        Positioned.fill(child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(_isProvider ? -0.2 : 0.2, -0.6),
              radius: 1.0,
              colors: _isProvider
                  ? [const Color(0xFF4A1055), _kBg]
                  : [const Color(0xFF2E1065), _kBg],
            ),
          ),
        )),
        Positioned(top: -80, right: -80, child: Container(
          width: 260, height: 260,
          decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                accent.withOpacity(0.18), Colors.transparent])),
        )),
        Positioned(bottom: -80, left: -80, child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _kPrimary.withOpacity(0.12), Colors.transparent])),
        )),

        SafeArea(child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              _GlassCircleBtn(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(child: Text('HayaBook',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 18,
                      fontWeight: FontWeight.w800, color: Colors.white))),
              const SizedBox(width: 44),
            ]),
          ),

          // ── Role switcher ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _RoleSwitcher(selected: _role, onChanged: _switchRole),
          ),

          // ── Card ──────────────────────────────────────────
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildCard(accent),
              ),
            ),
          )),
        ])),
      ]),
    );
  }

  Widget _buildCard(Color accent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: _isProvider
                  ? [const Color(0xFF4A1055).withOpacity(0.85),
                const Color(0xFF2E1065).withOpacity(0.90)]
                  : [const Color(0xFF3B1FA0).withOpacity(0.85),
                const Color(0xFF2E1065).withOpacity(0.90)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.40),
                  blurRadius: 50, offset: const Offset(0, 20)),
              BoxShadow(color: accent.withOpacity(0.20),
                  blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isProvider
                        ? [_kAccent.withOpacity(0.80), const Color(0xFF9D174D)]
                        : [const Color(0xFF5B21B6), const Color(0xFF2E1065)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: accent.withOpacity(0.50),
                      blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Icon(
                    _isProvider ? Icons.store_rounded : Icons.storefront_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),

              // Title
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  key: ValueKey(_isProvider),
                  _isProvider ? 'Provider Sign In' : "Welcome Back",
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 24,
                      fontWeight: FontWeight.w800, color: Colors.white,
                      letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  key: ValueKey(_isProvider),
                  _isProvider
                      ? 'Log in to manage your bookings and services'
                      : 'Log in to book your next appointment',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      color: Colors.white.withOpacity(0.65), height: 1.5),
                ),
              ),
              const SizedBox(height: 26),

              // Tab switcher
              _TabSwitcher(selected: _tab, accent: accent,
                  onChanged: (i) => setState(() { _tab = i; _error = null; })),
              const SizedBox(height: 22),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.30), width: 1),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                        style: const TextStyle(fontFamily: 'Inter',
                            fontSize: 12, color: Colors.redAccent))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              // Phone tab
              if (_tab == 0) ...[
                _FieldLabel('Country'),
                const SizedBox(height: 8),
                _CountryField(flag: _countryFlag, code: _countryCode,
                    name: _countryName, onTap: _showCountryPicker),
                const SizedBox(height: 14),
                _FieldLabel('Phone Number'),
                const SizedBox(height: 8),
                _DarkInput(ctrl: _phoneCtrl, hint: '5xx xx xx xx',
                    prefixIcon: Icons.call_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)]),
                const SizedBox(height: 26),
                _ActionButton(label: 'Send OTP', loading: _isLoading,
                    accent: accent, onTap: _loginWithPhone),
              ],

              // Email tab
              if (_tab == 1) ...[
                _FieldLabel('Email Address'),
                const SizedBox(height: 8),
                _DarkInput(ctrl: _emailCtrl, hint: 'you@example.com',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FieldLabel('Password'),
                      GestureDetector(onTap: () {},
                          child: Text('Forgot?', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isProvider ? _kAccent : _kLavender))),
                    ]),
                const SizedBox(height: 8),
                _DarkInput(ctrl: _passwordCtrl, hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withOpacity(0.40), size: 18))),
                const SizedBox(height: 26),
                _ActionButton(label: 'Sign In', loading: _isLoading,
                    accent: accent, onTap: _loginWithEmail),
              ],

              const SizedBox(height: 22),

              // Bottom links
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account?  ",
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        color: Colors.white.withOpacity(0.50))),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context,
                      _isProvider ? '/signup/provider' : '/signup/client'),
                  child: Text(_isProvider ? 'Register as Provider' : 'Sign Up',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _isProvider ? _kAccent : _kLavender)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ROLE SWITCHER  — Client | Provider toggle at top
// ══════════════════════════════════════════════════════════════
class _RoleSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _RoleSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(children: [
        _RoleBtn(label: 'Client', icon: Icons.person_rounded,
            active: selected == 0, accent: _kPrimary,
            onTap: () => onChanged(0)),
        _RoleBtn(label: 'Provider', icon: Icons.store_rounded,
            active: selected == 1, accent: _kAccent,
            onTap: () => onChanged(1)),
      ]),
    );
  }
}

class _RoleBtn extends StatelessWidget {
  final String label; final IconData icon;
  final bool active; final Color accent;
  final VoidCallback onTap;
  const _RoleBtn({required this.label, required this.icon,
    required this.active, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? [BoxShadow(color: accent.withOpacity(0.40),
              blurRadius: 12, offset: const Offset(0, 3))] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: active ? Colors.white
              : Colors.white.withOpacity(0.40), size: 15),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : Colors.white.withOpacity(0.40))),
        ]),
      ),
    ));
  }
}

// ══════════════════════════════════════════════════════════════
// TAB SWITCHER  — Phone | Email
// ══════════════════════════════════════════════════════════════
class _TabSwitcher extends StatelessWidget {
  final int selected; final Color accent;
  final ValueChanged<int> onChanged;
  const _TabSwitcher({required this.selected, required this.accent,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
      ),
      child: Row(children: [
        _TabBtn(label: 'Phone', icon: Icons.phone_iphone_rounded,
            active: selected == 0, accent: accent,
            onTap: () => onChanged(0)),
        _TabBtn(label: 'Email', icon: Icons.mail_outline_rounded,
            active: selected == 1, accent: accent,
            onTap: () => onChanged(1)),
      ]),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label; final IconData icon;
  final bool active; final Color accent;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.icon,
    required this.active, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: accent.withOpacity(0.35),
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
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.75))));
}

class _DarkInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint; final IconData prefixIcon;
  final bool obscure; final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _DarkInput({required this.ctrl, required this.hint,
    required this.prefixIcon, this.obscure = false,
    this.suffix, this.keyboardType, this.inputFormatters,
    // ignore linting — positional params from factory
  }) : super();
  // ignore: annotate_overrides
  get controller => ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
      ),
      child: Row(children: [
        Padding(padding: const EdgeInsets.only(left: 16, right: 10),
            child: Icon(prefixIcon,
                color: _kLavender.withOpacity(0.70), size: 18)),
        Expanded(child: TextField(
          controller: ctrl, obscureText: obscure,
          keyboardType: keyboardType, inputFormatters: inputFormatters,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
              color: Colors.white, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14,
                color: Colors.white.withOpacity(0.30)),
            border: InputBorder.none, enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true, fillColor: Colors.transparent,
            isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        )),
        if (suffix != null)
          Padding(padding: const EdgeInsets.only(right: 14), child: suffix!),
      ]),
    );
  }
}

class _CountryField extends StatelessWidget {
  final String flag, code, name; final VoidCallback onTap;
  const _CountryField({required this.flag, required this.code,
    required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
      ),
      child: Row(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(flag, style: const TextStyle(fontSize: 20))),
        Expanded(child: Text('$name ($code)', style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, color: Colors.white))),
        Padding(padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withOpacity(0.40), size: 20)),
      ]),
    ));
  }
}

class _ActionButton extends StatelessWidget {
  final String label; final bool loading;
  final Color accent; final VoidCallback onTap;
  const _ActionButton({required this.label, required this.loading,
    required this.accent, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            accent.withOpacity(0.90), accent]),
          borderRadius: BorderRadius.circular(99),
          boxShadow: [BoxShadow(color: accent.withOpacity(0.45),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: loading
            ? const Center(child: SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5)))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter',
              fontSize: 14, fontWeight: FontWeight.w700,
              color: Colors.white)),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded,
              color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final VoidCallback onTap; final Widget child;
  const _GlassCircleBtn({required this.onTap, required this.child});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: ClipOval(
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(width: 44, height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
                border: Border.all(color: Colors.white.withOpacity(0.20), width: 1)),
            child: Center(child: child)),
      ),
    ));
  }
}