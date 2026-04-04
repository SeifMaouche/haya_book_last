// lib/screens/profile_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass_kit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  bool   _notificationsOn = true;
  String _language        = 'English';

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
    _cardCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 520));
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardCtrl,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _cardSlide = Tween<double>(begin: 32.0, end: 0.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardCtrl.forward();
  }

  @override
  void dispose() { _cardCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BookingProvider>(
      builder: (_, auth, bp, __) {
        final name      = auth.userName ?? 'User';
        final photoPath = auth.photoPath; // ← from AuthProvider

        // ── Real stats ────────────────────────────────────────
        final totalBookings    = bp.bookings.length;
        final upcomingBookings = bp.getUpcomingBookings().length;

        // Favorites count — read from BookingProvider favorites list
        // Falls back to 0 if no favorites property exists yet
        int totalFavorites = 0;
        try { totalFavorites = bp.favorites?.length ?? 0; } catch (_) {}

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor:          Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: AnimatedBuilder(
              animation: _cardCtrl,
              builder: (_, child) => Opacity(
                opacity: _cardOpacity.value,
                child:   Transform.translate(
                    offset: Offset(0, _cardSlide.value), child: child),
              ),
              child: SingleChildScrollView(
                child: Column(children: [

                  // ══════════════════════════════════════════
                  // PURPLE HEADER
                  // ══════════════════════════════════════════
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin:  Alignment.topLeft,
                        end:    Alignment.bottomRight,
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft:  Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Stack(children: [
                      Positioned(top: -40, right: -40,
                          child: _GlowBlob(size: 220,
                              color: Colors.white.withOpacity(0.18))),
                      Positioned(top: 80, left: -40,
                          child: _GlowBlob(size: 160,
                              color: Colors.white.withOpacity(0.12))),

                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
                          child: Column(children: [

                            // Top bar
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(Icons.arrow_back_ios,
                                      color: Colors.white, size: 20),
                                ),
                                const Text('Profile', style: TextStyle(
                                  fontFamily:  'Inter', fontSize: 18,
                                  fontWeight:  FontWeight.w700,
                                  color:       Colors.white,
                                )),
                                const Icon(Icons.more_horiz,
                                    color: Colors.white, size: 22),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Avatar — real photo if set ────
                            Stack(children: [
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.45),
                                      width: 3),
                                ),
                                child: ClipOval(
                                  child: photoPath != null
                                  // Real picked photo
                                      ? Image.file(
                                    File(photoPath),
                                    fit:    BoxFit.cover,
                                    width:  100,
                                    height: 100,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(name),
                                  )
                                  // Default initials avatar
                                      : _defaultAvatar(name),
                                ),
                              ),
                              // Edit badge
                              Positioned(right: 0, bottom: 0,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/edit-profile'),
                                  child: Container(
                                    width: 30, height: 30,
                                    decoration: BoxDecoration(
                                      color:  AppColors.primary,
                                      shape:  BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 14),

                            // Name
                            Text(name, style: const TextStyle(
                              fontFamily:  'Inter', fontSize: 22,
                              fontWeight:  FontWeight.w700,
                              color:       Colors.white,
                            )),
                            const SizedBox(height: 4),
                            Text(
                              '@${name.toLowerCase().replaceAll(' ', '_')}_haya • Pro Member',
                              style: TextStyle(fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.82)),
                            ),
                            const SizedBox(height: 20),

                            // Edit Profile pill
                            ScaleTap(
                              onTap: () => Navigator.pushNamed(
                                  context, '/edit-profile'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.22),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.40),
                                          width: 1.2),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit Profile', style: TextStyle(
                                          fontFamily:  'Inter', fontSize: 14,
                                          fontWeight:  FontWeight.w600,
                                          color:       Colors.white,
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),

                  // ══════════════════════════════════════════
                  // REAL STATS CARD — tappable
                  // ══════════════════════════════════════════
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.70),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.70),
                                  width: 1.5),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16, offset: const Offset(0, 4))],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 8),
                            child: Row(children: [
                              // Total bookings → /bookings
                              _statItem(
                                value: '$totalBookings',
                                label: 'BOOKINGS',
                                onTap: () => Navigator.pushNamed(
                                    context, '/bookings'),
                              ),
                              Container(width: 1, height: 32,
                                  color: AppColors.cardBorder),
                              // Upcoming → /bookings (upcoming tab)
                              _statItem(
                                value: '$upcomingBookings',
                                label: 'UPCOMING',
                                onTap: () => Navigator.pushNamed(
                                    context, '/bookings'),
                              ),
                              Container(width: 1, height: 32,
                                  color: AppColors.cardBorder),
                              // Favorites → /favorites
                              _statItem(
                                value: '$totalFavorites',
                                label: 'FAVORITES',
                                onTap: () => Navigator.pushNamed(
                                    context, '/favorites'),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ══════════════════════════════════════════
                  // SECTIONS
                  // ══════════════════════════════════════════
                  Transform.translate(
                    offset: const Offset(0, -14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _sectionLabel('SETTINGS'),
                          const SizedBox(height: 8),
                          FadeSlide(
                            delay: const Duration(milliseconds: 80),
                            child: _glassSection([
                              _rowSwitch(
                                Icons.notifications_outlined,
                                'Notifications', _notificationsOn,
                                    (v) => setState(() => _notificationsOn = v),
                              ),
                              _divider(),
                              _rowArrow(Icons.language_outlined, 'Language',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_language, style: const TextStyle(
                                        fontFamily: 'Inter', fontSize: 13,
                                        color: AppColors.textMuted)),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.chevron_right,
                                        color: AppColors.textLight, size: 20),
                                  ],
                                ),
                                onTap: _pickLanguage,
                              ),
                            ]),
                          ),
                          const SizedBox(height: 18),

                          _sectionLabel('ACCOUNT'),
                          const SizedBox(height: 8),
                          FadeSlide(
                            delay: const Duration(milliseconds: 140),
                            child: _glassSection([
                              _rowArrow(Icons.payments_outlined,
                                  'Payment Methods',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/add-card')),
                              _divider(),
                              _rowArrow(Icons.verified_user_outlined,
                                  'Privacy Policy',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/privacy-policy')),
                            ]),
                          ),
                          const SizedBox(height: 18),

                          _sectionLabel('SUPPORT'),
                          const SizedBox(height: 8),
                          FadeSlide(
                            delay: const Duration(milliseconds: 200),
                            child: _glassSection([
                              _rowArrow(Icons.help_outline, 'Help Center',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/help-faq')),
                              _divider(),
                              _rowArrow(Icons.mail_outline,
                                  'Contact Support',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/contact-us')),
                            ]),
                          ),
                          const SizedBox(height: 20),

                          // LOG OUT
                          FadeSlide(
                            delay: const Duration(milliseconds: 260),
                            child: ScaleTap(
                              onTap: _confirmLogout,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 17),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF4444),
                                      Color(0xFFDC2626)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.38),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6))],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout_rounded,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Log Out', style: TextStyle(
                                      fontFamily:  'Inter', fontSize: 15,
                                      fontWeight:  FontWeight.w700,
                                      color:       Colors.white,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 4,
              onTap: (i) => navigateToTab(context, i),
            ),
          ),
        );
      },
    );
  }

  // ── Avatar fallback — initials on purple ─────────────────────
  Widget _defaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: Colors.white.withOpacity(0.25),
      child: Center(child: Text(initial, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 38,
        fontWeight: FontWeight.w700, color: Colors.white,
      ))),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(children: [
          Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 22,
            fontWeight: FontWeight.w800, color: AppColors.primary,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            fontFamily:    'Inter', fontSize: 10,
            fontWeight:    FontWeight.w700,
            color:         AppColors.textMuted,
            letterSpacing: 0.8,
          )),
          const SizedBox(height: 3),
          // Tap indicator dot
          Container(
            width: 4, height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.35),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: const TextStyle(
        fontFamily:    'Inter', fontSize: 11,
        fontWeight:    FontWeight.w700, color: AppColors.textLight,
        letterSpacing: 0.8,
      )),
    );
  }

  Widget _glassSection(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.white.withOpacity(0.60), width: 1.2),
            boxShadow: [BoxShadow(
                color:      Colors.black.withOpacity(0.05),
                blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 56,
      color: Colors.black.withOpacity(0.06));

  Widget _iconBox(IconData icon) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.primary, size: 18),
    );
  }

  Widget _rowSwitch(IconData icon, String label, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        _iconBox(icon),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 15,
          fontWeight: FontWeight.w500, color: AppColors.textDark,
        ))),
        Switch(value: value, onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary),
      ]),
    );
  }

  Widget _rowArrow(IconData icon, String label,
      {required VoidCallback onTap, Widget? trailing}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          _iconBox(icon),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            fontWeight: FontWeight.w500, color: AppColors.textDark,
          ))),
          trailing ?? const Icon(Icons.chevron_right,
              color: AppColors.textLight, size: 20),
        ]),
      ),
    );
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 20),
          const Text('Select Language', style: TextStyle(
            fontFamily: 'Inter', fontSize: 18,
            fontWeight: FontWeight.w700, color: AppColors.textDark,
          )),
          const SizedBox(height: 12),
          ...['English', 'Français', 'العربية'].map((lang) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(lang,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 15)),
            trailing: _language == lang
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              setState(() => _language = lang);
              Navigator.pop(context);
            },
          )),
        ]),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Log Out', style: TextStyle(
          fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700)),
      content: const Text('Are you sure you want to log out?',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              color: AppColors.textMuted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(
              fontFamily: 'Inter', color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99)),
            elevation: 0,
          ),
          child: const Text('Log Out', style: TextStyle(
              fontFamily: 'Inter', color: Colors.white,
              fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }
}

class _GlowBlob extends StatelessWidget {
  final double size; final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    );
  }
}