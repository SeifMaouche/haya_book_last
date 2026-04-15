// lib/screens/provider/provider_profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../providers/provider_profile_provider.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/haya_avatar.dart';
import '../../providers/auth_provider.dart';

// ─── Design tokens ────────────────────────────────────────────
const _kPrimary     = Color(0xFF7C3AED);
const _kPrimaryDeep = Color(0xFF6D28D9);
const _kLavender    = Color(0xFFA78BFA);
const _kBg          = Color(0xFFFFFFFF);
const _kSurface     = Color(0xFFF9FAFB);
const _kTextDark    = Color(0xFF111827);
const _kTextMuted   = Color(0xFF6B7280);
const _kBorder      = Color(0xFFE5E7EB);

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch provider data on screen entry (both providers)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProviderStateProvider>(context, listen: false).loadInitialData();
      Provider.of<ProviderProfileProvider>(context, listen: false).loadProfile();
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
          // ── Subtle radial bg gradients ────────────────
          Positioned(
            top: -40, right: -60,
            child: _Blob(
                size:  280,
                color: _kPrimary.withOpacity(0.05)),
          ),
          Positioned(
            top: -40, left: -60,
            child: _Blob(
                size:  280,
                color: _kLavender.withOpacity(0.05)),
          ),

          Column(
            children: [
              // ── Sticky header ─────────────────────────
              _StickyHeader(),
              // ── Scrollable content ────────────────────
              Expanded(
                child: Consumer<ProviderStateProvider>(
                  builder: (_, ps, __) {
                    final stats = ps.stats;
                    final profile = ps.profile;
                    
                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                          20, 24, 20,
                          MediaQuery.of(context).padding.bottom + 110),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // ── Profile section ──────────────
                        _ProfileSection(
                          stats: stats,
                          businessName: profile?.name ?? 'HayaBook Provider',
                          category: profile?.category ?? 'Service Provider',
                        ),
                        const SizedBox(height: 24),

                        // ── Stats row ────────────────────
                        _StatsRow(stats: stats),
                        const SizedBox(height: 24),

                        // ── Action rows ──────────────────
                        _ActionRow(
                          icon:    Icons.person_rounded,
                          label:   'Edit Profile',
                          onTap:   () => Navigator.pushNamed(
                              context, '/provider/edit-profile'),
                        ),
                        const SizedBox(height: 12),
                        _ActionRow(
                          icon:    Icons.medical_services_rounded,
                          label:   'My Services',
                          onTap:   () => Navigator.pushReplacementNamed(
                              context, '/provider/services'),
                        ),
                        const SizedBox(height: 12),
                        _ActionRow(
                          icon:    Icons.event_available_rounded,
                          label:   'Availability',
                          onTap:   () => Navigator.pushNamed(
                              context, '/provider/availability'),
                        ),
                        const SizedBox(height: 12),
                        _ActionRow(
                          icon:    Icons.settings_rounded,
                          label:   'General Settings',
                          onTap:   () => Navigator.pushNamed(
                              context, '/provider/settings'),
                        ),
                        const SizedBox(height: 24),

                        // ── Logout ───────────────────────
                        _LogoutButton(),
                      ],
                    );
                  },
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
}

// ══════════════════════════════════════════════════════════════
// STICKY HEADER  —  "HayaBook" + bell
// ══════════════════════════════════════════════════════════════
class _StickyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, top + 14, 24, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.80),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo text
              Text('HayaBook',
                  style: TextStyle(
                    fontFamily:    'Inter',
                    fontSize:      22,
                    fontWeight:    FontWeight.w700,
                    color:         _kPrimary,
                    letterSpacing: -0.3,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PROFILE SECTION  —  avatar + name + category + rating
// ══════════════════════════════════════════════════════════════
class _ProfileSection extends StatelessWidget {
  final dynamic stats;
  final String businessName;
  final String category;
  
  const _ProfileSection({
    required this.stats,
    required this.businessName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar with HayaAvatar System
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _kPrimary.withOpacity(0.10), width: 4),
                color:  Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:      _kPrimary.withOpacity(0.08),
                    blurRadius: 24,
                    offset:     const Offset(0, 8),
                  ),
                ],
              ),
              child: Consumer<AuthProvider>(
                builder: (_, auth, __) => HayaAvatar(
                  avatarUrl: auth.photoPath,
                  size: 120,
                  borderRadius: 99,
                  isProvider: true,
                ),
              ),
            ),
            // Green online dot
            Positioned(
              bottom: 4, right: 4,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color:  const Color(0xFF22C55E),
                  shape:  BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color:      const Color(0xFF22C55E)
                          .withOpacity(0.40),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name
        Text(businessName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily:    'Inter',
              fontSize:      24,
              fontWeight:    FontWeight.w700,
              color:         _kTextDark,
              letterSpacing: -0.3,
            )),
        const SizedBox(height: 4),

        // Category
        Text(category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily:  'Inter',
              fontSize:    15,
              fontWeight:  FontWeight.w500,
              color:       _kPrimary,
            )),
        const SizedBox(height: 10),

        // Rating badge
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color:        const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
                color: const Color(0xFFFEF08A), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFCA8A04), size: 16),
              const SizedBox(width: 5),
              Text(
                '${stats.rating.toStringAsFixed(1)} RATING',
                style: const TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      12,
                  fontWeight:    FontWeight.w700,
                  color:         Color(0xFF854D0E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STATS ROW  —  Bookings | Rating | Reviews
// ══════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final dynamic stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color:        _kLavender.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _kPrimary.withOpacity(0.10), width: 1),
          ),
          child: Row(
            children: [
              _StatItem(
                  value: '${stats.todayBookings}',
                  label: 'TODAY'),
              _VerticalDivider(),
              _StatItem(
                  value: '${stats.rating.toStringAsFixed(1)}',
                  label: 'RATING'),
              _VerticalDivider(),
              _StatItem(
                  value: '${stats.totalReviews}',
                  label: 'REVIEWS'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontFamily:  'Inter',
                fontSize:    20,
                fontWeight:  FontWeight.w700,
                color:       _kTextDark,
              )),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                fontFamily:    'Inter',
                fontSize:      10,
                fontWeight:    FontWeight.w600,
                color:         _kTextMuted,
                letterSpacing: 1.0,
              )),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 40,
      color: _kPrimary.withOpacity(0.10),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ACTION ROW  —  icon + label + chevron
// ══════════════════════════════════════════════════════════════
class _ActionRow extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset:     const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon in lavender square
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:        _kPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _kPrimary, size: 22),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontFamily:  'Inter',
                    fontSize:    16,
                    fontWeight:  FontWeight.w600,
                    color:       Color(0xFF1F2937),
                  )),
            ),
            // Chevron
            Icon(Icons.chevron_right_rounded,
                color: _kBorder, size: 22),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LOGOUT BUTTON
// ══════════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:        const Color(0xFFFEF2F2).withOpacity(0.30),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFFFECACA), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text('Log Out',
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    15,
                  fontWeight:  FontWeight.w700,
                  color:       Color(0xFFEF4444),
                )),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(
              fontFamily:  'Inter',
              fontWeight:  FontWeight.w800,
              color:       Color(0xFF111827),
            )),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
              fontFamily: 'Inter',
              color:      Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color:      Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false),
            child: const Text('Log Out',
                style: TextStyle(
                  fontFamily:  'Inter',
                  color:       Color(0xFFEF4444),
                  fontWeight:  FontWeight.w700,
                )),
          ),
        ],
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