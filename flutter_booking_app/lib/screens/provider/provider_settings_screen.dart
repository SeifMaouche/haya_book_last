// lib/screens/provider/provider_settings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../providers/auth_provider.dart'; // ✅ needed for logout()
import '../../widgets/haya_avatar.dart';
import '../../providers/provider_profile_provider.dart';
import '../../widgets/provider_bottom_nav_bar.dart';


// ─── Design tokens ────────────────────────────────────────────
const _kPrimary    = Color(0xFF6D28D9);
const _kBg         = Color(0xFFF8FAFC);
const _kTextDark   = Color(0xFF111827);
const _kTextMuted  = Color(0xFF6B7280);
const _kTextLight  = Color(0xFF9CA3AF);

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      extendBody: true,
      body: Stack(
        children: [
          // ── Radial bg blobs ───────────────────────────
          Positioned(
            top: -60, right: -60,
            child: _Blob(size: 260,
                color: _kPrimary.withOpacity(0.10)),
          ),
          Positioned(
            bottom: -60, left: -60,
            child: _Blob(size: 240,
                color: _kPrimary.withOpacity(0.05)),
          ),

          Column(
            children: [
              // ── Glass header ──────────────────────────
              _StickyHeader(),
              // ── Body ──────────────────────────────────
              Expanded(
                child: Consumer2<ProviderStateProvider, ProviderProfileProvider>(
                  builder: (_, ps, pp, __) => SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        16, 24, 16,
                        MediaQuery.of(context).padding.bottom + 110),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [

                        // ── Avatar section ────────────
                        _AvatarSection(profile: pp),
                        const SizedBox(height: 32),

                        // ── Section label ─────────────
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 14),
                            child: Text('ACCOUNT PREFERENCES',
                                style: TextStyle(
                                  fontFamily:    'Inter',
                                  fontSize:      11,
                                  fontWeight:    FontWeight.w700,
                                  color:         _kTextMuted,
                                  letterSpacing: 1.5,
                                )),
                          ),
                        ),

                        // ── Settings rows — each separate card ──
                        _ToggleRow(
                          icon:      Icons.notifications_rounded,
                          label:     'Notifications',
                          value:     ps.notificationsEnabled,
                          onChanged: ps.toggleNotifications,
                        ),
                        const SizedBox(height: 12),

                        _ToggleRow(
                          icon:      Icons.beach_access_rounded,
                          label:     'Vacation Mode',
                          value:     ps.vacationMode,
                          onChanged: ps.toggleVacationMode,
                        ),
                        const SizedBox(height: 12),

                        _NavRow(
                          icon:  Icons.security_rounded,
                          label: 'Security',
                          onTap: () => Navigator.pushNamed(
                              context, '/provider/security'),
                        ),
                        const SizedBox(height: 12),

                        _NavRow(
                          icon:  Icons.help_rounded,
                          label: 'Help & Support',
                          onTap: () => Navigator.pushNamed(
                              context, '/provider/help-support'),
                        ),
                        const SizedBox(height: 32),

                        // ── Logout ────────────────────
                        _LogoutButton(
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar:
      const ProviderBottomNavBar(currentIndex: 4),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(
              fontFamily:  'Inter',
              fontWeight:  FontWeight.w800,
              color:       _kTextDark,
            )),
        content: const Text(
          'Are you sure you want to logout from your provider account?',
          style: TextStyle(
              fontFamily: 'Inter', color: _kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Inter', color: _kTextMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // ✅ FIX: Call auth.logout() to clear JWT, secure storage,
              // socket connection, and favorites before navigating.
              // Previously this just pushed /login without cleaning up.
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            child: const Text('Logout',
                style: TextStyle(
                  fontFamily:  'Inter',
                  color:       Colors.red,
                  fontWeight:  FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STICKY GLASS HEADER
// ══════════════════════════════════════════════════════════════
class _StickyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.50),
            border: Border(
              bottom: BorderSide(
                  color: Colors.white.withOpacity(0.30), width: 1),
            ),
          ),
          child: Row(
            children: [
              // Bare back arrow — no circle bg
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _kTextDark,
                    size:  20,
                  ),
                ),
              ),
              // Title centered
              const Expanded(
                child: Text('General Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily:    'Inter',
                      fontSize:      19,
                      fontWeight:    FontWeight.w700,
                      color:         _kTextDark,
                      letterSpacing: -0.2,
                    )),
              ),
              // Spacer
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AVATAR SECTION
// ══════════════════════════════════════════════════════════════
class _AvatarSection extends StatelessWidget {
  final ProviderProfileProvider profile;
  const _AvatarSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final logo = profile.logoUrl;
    final initial = profile.businessName.isNotEmpty 
        ? profile.businessName[0].toUpperCase() 
        : 'P';

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/provider/edit-profile'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar circle
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape:  BoxShape.circle,
                  color:  _kPrimary.withOpacity(0.20),
                  border: Border.all(
                      color: _kPrimary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color:      _kPrimary.withOpacity(0.20),
                      blurRadius: 20,
                      offset:     const Offset(0, 6),
                    ),
                  ],
                ),
                child: HayaAvatar(
                  avatarUrl: logo,
                  size: 96,
                  borderRadius: 99,
                  isProvider: true,
                ),
              ),
              // Edit button — purple circle bottom-right
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color:  _kPrimary,
                    shape:  BoxShape.circle,
                    border: Border.all(
                        color: _kBg, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color:      _kPrimary.withOpacity(0.30),
                        blurRadius: 8,
                        offset:     const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(profile.businessName,
            style: const TextStyle(
              fontFamily:  'Inter',
              fontSize:    18,
              fontWeight:  FontWeight.w700,
              color:       _kTextDark,
            )),
        const SizedBox(height: 3),
        Text(profile.category,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize:   14,
              color:      _kTextDark.withOpacity(0.55),
            )),
      ],
    );
  }

}

// ══════════════════════════════════════════════════════════════
// TOGGLE ROW  —  individual glass card
// ══════════════════════════════════════════════════════════════
class _ToggleRow extends StatelessWidget {
  final IconData           icon;
  final String             label;
  final bool               value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(0.30), width: 1),
          ),
          child: Row(
            children: [
              // Icon in lavender square
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color:        _kPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kPrimary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    15,
                      fontWeight:  FontWeight.w600,
                      color:       _kTextDark,
                    )),
              ),
              // iOS-style switch
              Transform.scale(
                scale: 0.88,
                child: Switch(
                  value:              value,
                  onChanged:          onChanged,
                  activeColor:        Colors.white,
                  activeTrackColor:   _kPrimary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor:
                  Colors.grey.withOpacity(0.30),
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
// NAV ROW  —  individual glass card with chevron
// ══════════════════════════════════════════════════════════════
class _NavRow extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:        Colors.white.withOpacity(0.50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withOpacity(0.30), width: 1),
            ),
            child: Row(
              children: [
                // Icon in lavender square
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color:        _kPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _kPrimary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                        fontFamily:  'Inter',
                        fontSize:    15,
                        fontWeight:  FontWeight.w600,
                        color:       _kTextDark,
                      )),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _kTextLight.withOpacity(0.60), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LOGOUT BUTTON  —  glass red
// ══════════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color:        Colors.red.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.red.withOpacity(0.20), width: 1),
              boxShadow: [
                BoxShadow(
                  color:      Colors.red.withOpacity(0.05),
                  blurRadius: 16,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded,
                    color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Text('Logout',
                    style: TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    16,
                      fontWeight:  FontWeight.w700,
                      color:       Color(0xFFEF4444),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BACKGROUND BLOB
// ══════════════════════════════════════════════════════════════
class _Blob extends StatelessWidget {
  final double size;
  final Color  color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size, height: size,
        decoration:
        BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}