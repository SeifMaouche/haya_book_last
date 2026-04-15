// lib/screens/complete_profile_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool  _isLoading = false;
  File? _photo;                          // ← picked profile photo

  final _picker = ImagePicker();

  // Entry animation
  late final AnimationController _anim;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  final _passwordCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
        begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();

    // Pre-fill email if available (e.g. from email signup)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.email != null && auth.email!.isNotEmpty) {
        _emailCtrl.text = auth.email!;
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Pick photo ────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourceSheet(),
    );
    if (source == null) return;
    try {
      final img = await _picker.pickImage(
          source: source, maxWidth: 512, imageQuality: 85);
      if (img != null && mounted) {
        setState(() => _photo = File(img.path));
      }
    } catch (_) {}
  }

  // ── Continue ──────────────────────────────────────────────────
  Future<void> _continue() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Please enter your full name.');
      return;
    }
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final pass = _passwordCtrl.text.trim();

    // Save name, email, and photo path to AuthProvider + SharedPreferences
    final success = await auth.updateProfile(
      name:      _nameCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
      phone:     auth.phone ?? '',
      password:  pass.isNotEmpty ? pass : null,
      bio:       auth.bio,
      photoPath: _photo?.path,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    
    if (success) {
      if (auth.userType == 'provider') {
        Navigator.pushNamedAndRemoveUntil(context, '/provider/home', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } else {
      // Show failure message
      _showSnack(auth.error ?? 'Profile update failed. Please try again.');
    }
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
        width:  double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF2E1065)],
            stops:  [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(children: [
          // Blobs
          Positioned(top: -80, left: -60,
              child: _Blob(size: 300, opacity: 0.18)),
          Positioned(bottom: -80, right: -60,
              child: _Blob(size: 300, opacity: 0.18)),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.18, right: -40,
              child: _Blob(size: 180, opacity: 0.10)),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height
                          - MediaQuery.of(context).padding.top
                          - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(children: [

                        // Top bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(children: [
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
                                          color: Colors.white.withOpacity(0.25)),
                                    ),
                                    child: const Icon(Icons.chevron_left,
                                        color: Colors.white, size: 26),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: Center(
                              child: Text('HAYABOOK', style: TextStyle(
                                fontFamily: 'Inter', fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.60),
                                letterSpacing: 2.5,
                              )),
                            )),
                            const SizedBox(width: 44),
                          ]),
                        ),

                        const SizedBox(height: 28),

                        // Glass card
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
                                        width: 1.5),
                                    boxShadow: [BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 32,
                                        offset: const Offset(0, 8))],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      const Text('Complete Profile',
                                          style: TextStyle(
                                            fontFamily:    'Inter',
                                            fontSize:      24,
                                            fontWeight:    FontWeight.w800,
                                            color:         Colors.white,
                                            letterSpacing: -0.5,
                                          )),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Help your providers recognise you',
                                        style: TextStyle(fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.70)),
                                      ),
                                      const SizedBox(height: 28),

                                      // ── Avatar picker ─────────────
                                      GestureDetector(
                                        onTap: _pickPhoto,
                                        child: Stack(children: [
                                          // Avatar circle
                                          ClipOval(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 12, sigmaY: 12),
                                              child: Container(
                                                width: 90, height: 90,
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
                                                child: _photo != null
                                                // Show picked image
                                                    ? ClipOval(
                                                  child: Image.file(
                                                    _photo!,
                                                    fit:    BoxFit.cover,
                                                    width:  90,
                                                    height: 90,
                                                  ),
                                                )
                                                // Default camera icon
                                                    : const Icon(
                                                    Icons
                                                        .photo_camera_rounded,
                                                    size:  40,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          // + badge
                                          Positioned(
                                            right: 0, bottom: 0,
                                            child: Container(
                                              width: 28, height: 28,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF8B5CF6),
                                                    Color(0xFF7C3AED)],
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 1.5),
                                              ),
                                              child: const Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 16),
                                            ),
                                          ),
                                        ]),
                                      ),

                                      // "Tap to add photo" hint
                                      const SizedBox(height: 8),
                                      Text('Tap to add photo',
                                          style: TextStyle(
                                            fontFamily:  'Inter',
                                            fontSize:    11,
                                            color: Colors.white.withOpacity(0.50),
                                          )),
                                      const SizedBox(height: 24),

                                      // Full name
                                      _glassField(
                                        label:        'Full Name',
                                        hint:         'Ahmed Benali',
                                        controller:   _nameCtrl,
                                        icon:         Icons.person_outline,
                                        keyboardType: TextInputType.name,
                                      ),
                                      const SizedBox(height: 18),

                                      // Email
                                      _glassField(
                                        label:        'Email Address',
                                        hint:         'ahmed@gmail.com',
                                        controller:   _emailCtrl,
                                        icon:         Icons.mail_outline,
                                        keyboardType:
                                        TextInputType.emailAddress,
                                      ),
                                      
                                      // Password (only if phone user)
                                      Consumer<AuthProvider>(
                                        builder: (_, auth, __) {
                                          final isPhoneUser = auth.email == null || auth.email!.isEmpty;
                                          if (!isPhoneUser) return const SizedBox.shrink();
                                          
                                          return Column(children: [
                                            const SizedBox(height: 18),
                                            _glassField(
                                              label: 'Set Password',
                                              hint: 'Min. 6 characters',
                                              controller: _passwordCtrl,
                                              icon: Icons.lock_outline,
                                              keyboardType: TextInputType.text,
                                              obscure: !_showPass,
                                              suffix: GestureDetector(
                                                onTap: () => setState(() => _showPass = !_showPass),
                                                child: Icon(
                                                  _showPass ? Icons.visibility : Icons.visibility_off,
                                                  color: Colors.white.withOpacity(0.4),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ]);
                                        },
                                      ),
                                      const SizedBox(height: 28),

                                      // Continue button
                                      SizedBox(
                                        width:  double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed:
                                          _isLoading ? null : _continue,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            disabledBackgroundColor:
                                            Colors.white.withOpacity(0.6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(16)),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                              width: 22, height: 22,
                                              child:
                                              CircularProgressIndicator(
                                                color:
                                                AppColors.primary,
                                                strokeWidth: 2.5,
                                              ))
                                              : Text('Continue',
                                              style: TextStyle(
                                                fontFamily:  'Inter',
                                                fontSize:    17,
                                                fontWeight:  FontWeight.w700,
                                                color:
                                                AppColors.primary,
                                              )),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Skip
                                      SizedBox(
                                        width:  double.infinity,
                                        height: 48,
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
                                                BorderRadius.circular(16)),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text('Skip for now',
                                              style: TextStyle(
                                                fontFamily:  'Inter',
                                                fontSize:    15,
                                                fontWeight:  FontWeight.w500,
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                              )),
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
                        Text('PROTECTED BY HAYABOOK SECURITY',
                            style: TextStyle(
                              fontFamily:    'Inter', fontSize: 10,
                              fontWeight:    FontWeight.w600,
                              color:         Colors.white.withOpacity(0.35),
                              letterSpacing: 1.5,
                            )),
                        const SizedBox(height: 28),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _glassField({
    required String label, required String hint,
    required TextEditingController controller,
    required IconData icon, required TextInputType keyboardType,
    bool obscure = false, Widget? suffix,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13,
          fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.90))),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.20), width: 1),
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(icon, color: Colors.white.withOpacity(0.45), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                        filled: true, fillColor: Colors.transparent),
                  ),
                  child: TextField(
                    controller: controller, keyboardType: keyboardType,
                    obscureText: obscure,
                    cursorColor: Colors.white, cursorWidth: 1.5,
                    style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 15, color: Colors.white),
                    decoration: InputDecoration(
                      hintText:       hint,
                      hintStyle:      TextStyle(fontFamily: 'Inter',
                          fontSize: 15, color: Colors.white.withOpacity(0.35)),
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
              if (suffix != null)
                Padding(padding: const EdgeInsets.only(right: 14), child: suffix),
              const SizedBox(width: 14),
            ]),
          ),
        ),
      ),
    ]);
  }
}

// ── Image source bottom sheet ─────────────────────────────────
class _SourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(99))),
        const SizedBox(height: 16),
        const Text('Add Profile Photo', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16,
            fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 14),
        _tile(context, Icons.camera_alt_rounded,
            'Take Photo', ImageSource.camera),
        const SizedBox(height: 10),
        _tile(context, Icons.photo_library_rounded,
            'Choose from Gallery', ImageSource.gallery),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String label,
      ImageSource source) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, source),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 18)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontFamily: 'Inter',
              fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFF111827))),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF), size: 18),
        ]),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size, opacity;
  const _Blob({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity)));
  }
}