import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isLoading  = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Please enter your full name.');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6), // gradientTop
              Color(0xFF7C3AED), // gradientMid
              Color(0xFF2E1065), // gradientDark
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Ambient blobs ──────────────────────────────
            Positioned(
              top: -80, left: -60,
              child: _Blob(size: 300, opacity: 0.18),
            ),
            Positioned(
              bottom: -80, right: -60,
              child: _Blob(size: 300, opacity: 0.18),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.18,
              right: -40,
              child: _Blob(size: 180, opacity: 0.10),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height
                        - MediaQuery.of(context).padding.top
                        - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [

                        // ── Top bar ────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.13),
                                        border: Border.all(
                                            color: Colors.white
                                                .withOpacity(0.25)),
                                      ),
                                      child: const Icon(Icons.chevron_left,
                                          color: Colors.white, size: 26),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'HAYABOOK',
                                    style: TextStyle(
                                      fontFamily:    'Inter',
                                      fontSize:      11,
                                      fontWeight:    FontWeight.w700,
                                      color:         Colors.white
                                          .withOpacity(0.60),
                                      letterSpacing: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 44),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Glass card ─────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 28, sigmaY: 28),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end:   Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.13),
                                        Colors.white.withOpacity(0.07),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.22),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 32,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [

                                      // Title
                                      const Text(
                                        'Complete Profile',
                                        style: TextStyle(
                                          fontFamily:    'Inter',
                                          fontSize:      28,
                                          fontWeight:    FontWeight.w800,
                                          color:         Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Help your providers recognise you',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:   14,
                                          color: Colors.white.withOpacity(0.70),
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      // Avatar
                                      Stack(
                                        children: [
                                          ClipOval(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 12, sigmaY: 12),
                                              child: Container(
                                                width: 110, height: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                                      .withOpacity(0.12),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.40),
                                                    width: 2,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.photo_camera_rounded,
                                                  size:  40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0, bottom: 0,
                                            child: Container(
                                              width: 34, height: 34,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF8B5CF6),
                                                    Color(0xFF7C3AED),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end:   Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 1.5),
                                              ),
                                              child: const Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),

                                      // Full name field
                                      _glassField(
                                        label:        'Full Name',
                                        hint:         'Ahmed Benali',
                                        controller:   _nameCtrl,
                                        icon:         Icons.person_outline,
                                        keyboardType: TextInputType.name,
                                      ),
                                      const SizedBox(height: 18),

                                      // Email field
                                      _glassField(
                                        label:        'Email Address',
                                        hint:         'ahmed.benali@gmail.com',
                                        controller:   _emailCtrl,
                                        icon:         Icons.mail_outline,
                                        keyboardType:
                                        TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 28),

                                      // Continue button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed:
                                          _isLoading ? null : _continue,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            disabledBackgroundColor:
                                            Colors.white.withOpacity(0.6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                            width: 22, height: 22,
                                            child:
                                            CircularProgressIndicator(
                                              color:       AppColors.primary,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                              : Text(
                                            'Continue',
                                            style: TextStyle(
                                              fontFamily:  'Inter',
                                              fontSize:    17,
                                              fontWeight:  FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Skip button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pushNamedAndRemoveUntil(
                                                  context, '/', (_) => false),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: Colors.white
                                                    .withOpacity(0.25)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            'Skip for now',
                                            style: TextStyle(
                                              fontFamily:  'Inter',
                                              fontSize:    15,
                                              fontWeight:  FontWeight.w500,
                                              color: Colors.white
                                                  .withOpacity(0.85),
                                            ),
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

                        const SizedBox(height: 20),

                        // Footer
                        Text(
                          'PROTECTED BY HAYABOOK SECURITY',
                          style: TextStyle(
                            fontFamily:    'Inter',
                            fontSize:      10,
                            fontWeight:    FontWeight.w600,
                            color:         Colors.white.withOpacity(0.35),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Glass field — transparent, no white fill ──────────────────
  Widget _glassField({
    required String                label,
    required String                hint,
    required TextEditingController controller,
    required IconData              icon,
    required TextInputType         keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily:  'Inter',
            fontSize:    13,
            fontWeight:  FontWeight.w600,
            color:       Colors.white.withOpacity(0.90),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                // ✅ Same glass tint as the rest of the card
                color:        Colors.white.withOpacity(0.09),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withOpacity(0.20), width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(icon,
                      color: Colors.white.withOpacity(0.45), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Theme(
                      // ✅ Kill the white fill that comes from the app theme
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          filled:    true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                      child: TextField(
                        controller:   controller,
                        keyboardType: keyboardType,
                        cursorColor:  Colors.white,
                        cursorWidth:  1.5,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize:   15,
                          color:      Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText:  hint,
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize:   15,
                            color:      Colors.white.withOpacity(0.35),
                          ),
                          // ✅ All borders and fill off
                          border:         InputBorder.none,
                          enabledBorder:  InputBorder.none,
                          focusedBorder:  InputBorder.none,
                          filled:         true,
                          fillColor:      Colors.transparent,
                          isDense:        true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Soft ambient blob ─────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}