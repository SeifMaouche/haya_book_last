// lib/screens/signup_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';

// ─── Purple palette — replaces all teal constants ────────────────────────────
const _kPurpleBright = Color(0xFF8B5CF6); // gradientTop
const _kPurpleMid    = Color(0xFF7C3AED); // primary
const _kPurpleDark   = Color(0xFF2E1065); // bgDarkPurple
const _kPurpleBlob   = Color(0xFFA78BFA); // blobColor

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {

  final _phoneCtrl = TextEditingController();
  bool   _isLoading   = false;
  String _countryCode = '+213';

  late final AnimationController _cardCtrl;
  late final Animation<double>   _cardOpacity;
  late final Animation<double>   _cardSlide;

  final List<Map<String, String>> _countries = const [
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
    _cardCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 560),
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<double>(begin: 48.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic),
    );
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showSnack('Please enter your phone number.');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushNamed(context, '/otp-verification', arguments: {
      'phone': '$_countryCode $phone',
    });
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CountryPickerSheet(
        countries:  _countries,
        selected:   _countryCode,
        onSelected: (code) {
          setState(() => _countryCode = code);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor:          _kPurpleDark,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [

            // ── Purple radial gradient background ─────────────
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.55, -0.80),
                  radius: 1.75,
                  colors: [_kPurpleBright, _kPurpleMid, _kPurpleDark],
                ),
              ),
            ),

            Positioned(
              top: -90, left: -90,
              child: _GlowBlob(size: 330,
                  color: _kPurpleBlob.withOpacity(0.38)),
            ),
            Positioned(
              bottom: -90, right: -90,
              child: _GlowBlob(size: 310,
                  color: _kPurpleBlob.withOpacity(0.38)),
            ),

            Column(
              children: [
                SizedBox(height: pad.top),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                      padding: EdgeInsets.fromLTRB(
                          24, 24, 24, pad.bottom + 24),
                      child: AnimatedBuilder(
                        animation: _cardCtrl,
                        builder: (_, child) => Opacity(
                          opacity: _cardOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _cardSlide.value),
                            child: child,
                          ),
                        ),
                        child: _GlassCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              const _GlassIconCircle(),
                              const SizedBox(height: 22),

                              const Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:    'Inter',
                                  fontSize:      34,
                                  fontWeight:    FontWeight.w800,
                                  color:         Colors.white,
                                  letterSpacing: -0.5,
                                  height:        1.1,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                'Enter your phone number to continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize:   15,
                                  color:      Colors.white.withOpacity(0.70),
                                  height:     1.45,
                                ),
                              ),
                              const SizedBox(height: 30),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:   14,
                                    fontWeight: FontWeight.w600,
                                    color:      Colors.white.withOpacity(0.90),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              _PhoneField(
                                ctrl:        _phoneCtrl,
                                countryCode: _countryCode,
                                onPickCode:  _showCountryPicker,
                              ),
                              const SizedBox(height: 26),

                              _SendOtpButton(
                                isLoading: _isLoading,
                                onTap:     _isLoading ? null : _sendOtp,
                              ),
                              const SizedBox(height: 22),

                              Divider(
                                color:     Colors.white.withOpacity(0.12),
                                height:    1,
                                thickness: 1,
                              ),
                              const SizedBox(height: 18),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize:   14,
                                      color:      Colors.white.withOpacity(0.62),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.pushReplacementNamed(
                                            context, '/login'),
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontFamily:  'Inter',
                                        fontSize:    14,
                                        fontWeight:  FontWeight.w700,
                                        color:       Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, pad.bottom + 16),
                  child: Column(
                    children: [
                      Text(
                        'PROTECTED BY HAYABOOK SECURITY',
                        style: TextStyle(
                          fontFamily:    'Inter',
                          fontSize:      10,
                          fontWeight:    FontWeight.w600,
                          color:         Colors.white.withOpacity(0.35),
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width:  120, height: 4,
                        decoration: BoxDecoration(
                          color:        Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
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
// GLASS CARD
// ══════════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.13),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.08),
                blurRadius: 40,
                offset:     const Offset(0, 8),
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
// GLASS ICON CIRCLE
// ══════════════════════════════════════════════════════════════
class _GlassIconCircle extends StatelessWidget {
  const _GlassIconCircle();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape:  BoxShape.circle,
            color:  Colors.white.withOpacity(0.13),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.2,
            ),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size:  32,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PHONE FIELD
// ══════════════════════════════════════════════════════════════
class _PhoneField extends StatelessWidget {
  final TextEditingController ctrl;
  final String                countryCode;
  final VoidCallback          onPickCode;

  const _PhoneField({
    required this.ctrl,
    required this.countryCode,
    required this.onPickCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap:    onPickCode,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:   const EdgeInsets.symmetric(horizontal: 20),
              height:    double.infinity,
              alignment: Alignment.center,
              child: Text(
                countryCode,
                style: const TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    16,
                  fontWeight:  FontWeight.w600,
                  color:       Colors.white,
                ),
              ),
            ),
          ),
          Container(
            width:  1, height: 28,
            color:  Colors.white.withOpacity(0.20),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled:    true,
                  fillColor: Colors.transparent,
                ),
              ),
              child: TextField(
                controller:        ctrl,
                keyboardType:      TextInputType.phone,
                textAlignVertical: TextAlignVertical.center,
                cursorColor:       Colors.white,
                cursorWidth:       1.5,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   16,
                  color:      Colors.white,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText:  '00 00 00 00',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize:   16,
                    color:      Colors.white.withOpacity(0.36),
                  ),
                  border:           InputBorder.none,
                  enabledBorder:    InputBorder.none,
                  focusedBorder:    InputBorder.none,
                  errorBorder:      InputBorder.none,
                  disabledBorder:   InputBorder.none,
                  filled:           true,
                  fillColor:        Colors.transparent,
                  isDense:          true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical:   0,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.phone_iphone_rounded,
                      color: Colors.white.withOpacity(0.40),
                      size:  20,
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth:  44,
                    minHeight: 44,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SEND OTP BUTTON
// ══════════════════════════════════════════════════════════════
class _SendOtpButton extends StatelessWidget {
  final bool          isLoading;
  final VoidCallback? onTap;

  const _SendOtpButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:    const Duration(milliseconds: 150),
        width:       double.infinity,
        height:      58,
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(isLoading ? 0.70 : 1.0),
          borderRadius: BorderRadius.circular(99),
          boxShadow: isLoading ? [] : [
            BoxShadow(
              color:      Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: _kPurpleMid),
          )
              : const Text(
            'Send OTP',
            style: TextStyle(
              fontFamily:  'Inter',
              fontSize:    17,
              fontWeight:  FontWeight.w700,
              color:       _kPurpleMid, // purple text on white button
            ),
          ),
        ),
      ),
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
                  color: Colors.white.withOpacity(0.26), width: 1),
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
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width:  size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// COUNTRY PICKER BOTTOM SHEET
// ══════════════════════════════════════════════════════════════
class _CountryPickerSheet extends StatelessWidget {
  final List<Map<String, String>> countries;
  final String                    selected;
  final ValueChanged<String>      onSelected;

  const _CountryPickerSheet({
    required this.countries,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.10),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28)),
            border: Border.all(
                color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select Country',
                      style: TextStyle(
                        fontFamily:  'Inter',
                        fontSize:    18,
                        fontWeight:  FontWeight.w700,
                        color:       Colors.white,
                      )),
                ),
              ),
              ...countries.map((c) {
                final isSelected = selected == c['code'];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  leading: Text(c['flag']!,
                      style: const TextStyle(fontSize: 26)),
                  title: Text(c['name']!,
                      style: TextStyle(
                        fontFamily:  'Inter',
                        fontSize:    15,
                        fontWeight:  FontWeight.w500,
                        color:       Colors.white.withOpacity(0.90),
                      )),
                  trailing: Text(c['code']!,
                      style: TextStyle(
                        fontFamily:  'Inter',
                        fontSize:    14,
                        fontWeight:  FontWeight.w600,
                        color:       Colors.white.withOpacity(0.65),
                      )),
                  tileColor: isSelected
                      ? Colors.white.withOpacity(0.12) : null,
                  onTap: () => onSelected(c['code']!),
                );
              }),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}