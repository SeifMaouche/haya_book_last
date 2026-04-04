// lib/screens/provider/provider_home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary     = Color(0xFF6D28D9);
const _kPrimaryMid  = Color(0xFF7C3AED);
const _kPrimaryDeep = Color(0xFF5B21B6);
const _kPrimaryDark = Color(0xFF2E1065);
const _kLavender    = Color(0xFFA78BFA);
const _kTextDark    = Color(0xFF1E1B4B);
const _kTextMuted   = Color(0xFF6B7280);

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [Color(0xFFEDE9FE), Color(0xFFF8F7FF)],
          ),
        ),
        child: Stack(children: [
          SafeArea(
            bottom: false,
            child: Consumer<ProviderStateProvider>(
              builder: (_, ps, __) => CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: Duration.zero, child: _Header())),
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: const Duration(milliseconds: 60),
                      child: _StatsSection(ps: ps))),
                  // ── Today's upcoming bookings (replaces pending section) ──
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: _TodayBookingsSection(ps: ps))),
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: const Duration(milliseconds: 180),
                      child: _QuickAccessSection())),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 0),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), _kPrimaryDeep, _kPrimaryDark],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.5), width: 1.5),
              color: const Color(0xFF0D9488),
            ),
            child: const Icon(Icons.store_rounded,
                color: Colors.white, size: 19),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('HayaBook', style: TextStyle(
              fontFamily: 'Inter', fontSize: 19,
              fontWeight: FontWeight.w800, color: _kTextDark,
              letterSpacing: -0.5,
            )),
            Text('PROVIDER ELITE', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, color: _kPrimary,
              letterSpacing: 2.2,
            )),
          ],
        )),
        _WhiteCircle(
          size: 40,
          child: const Icon(Icons.notifications_outlined,
              color: _kPrimaryMid, size: 19),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STATS SECTION
// ══════════════════════════════════════════════════════════════
class _StatsSection extends StatelessWidget {
  final ProviderStateProvider ps;
  const _StatsSection({required this.ps});

  @override
  Widget build(BuildContext context) {
    final s = ps.stats;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(children: [
        Row(children: [
          Expanded(child: _StatCard(
            label: 'TODAY',
            value: '${s.todayBookings}',
            badge: '+${s.todayChange}',
          )),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(
            label: 'EARNINGS',
            value: 'DZD ${(s.earnings / 1000).toStringAsFixed(1)}k',
            badge: '+${s.earningsChangePercent.toInt()}%',
          )),
        ]),
        const SizedBox(height: 10),
        _RatingCard(rating: s.rating),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, badge;
  const _StatCard(
      {required this.label, required this.value, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.08),
              blurRadius: 18, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.white.withOpacity(0.80),
              blurRadius: 0, offset: const Offset(0, -1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 9,
            fontWeight: FontWeight.w700, color: _kTextMuted,
            letterSpacing: 1.5,
          )),
          const SizedBox(height: 5),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Flexible(child: Text(value,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 22,
                  fontWeight: FontWeight.w900, color: _kTextDark,
                ))),
            const SizedBox(width: 4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.trending_up_rounded,
                  color: Color(0xFF059669), size: 12),
              const SizedBox(width: 2),
              Text(badge, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w700, color: Color(0xFF059669),
              )),
            ]),
          ]),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final double rating;
  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFFDDD6FE), Color(0xFFC4B5FD)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.15),
            blurRadius: 18, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PROVIDER RATING', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, color: Color(0xFF5B21B6),
              letterSpacing: 1.5,
            )),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$rating', style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 24,
                  fontWeight: FontWeight.w900, color: Color(0xFF1E1B4B),
                )),
                const Text(' / 5', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w500, color: Color(0xFF5B21B6),
                )),
              ],
            ),
          ],
        )),
        SizedBox(width: 64, height: 38,
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                boxShadow: [BoxShadow(color: Color(0x557C3AED),
                    blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: const Icon(Icons.star_rounded,
                  color: Colors.white, size: 18),
            ),
            Positioned(
              left: 24,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.75),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(child: Text('+2k', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w900, color: _kPrimary,
                    ))),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TODAY'S BOOKINGS  —  replaces the old "Pending Requests" section.
// Shows today's confirmed upcoming bookings so the provider can
// see at a glance who is coming in.
// ══════════════════════════════════════════════════════════════
class _TodayBookingsSection extends StatelessWidget {
  final ProviderStateProvider ps;
  const _TodayBookingsSection({required this.ps});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayBookings = ps.upcomingBookings.where((b) =>
    b.bookingDate.day   == today.day &&
        b.bookingDate.month == today.month &&
        b.bookingDate.year  == today.year,
    ).toList();

    if (todayBookings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Today's Appointments", style: TextStyle(
            fontFamily: 'Inter', fontSize: 16,
            fontWeight: FontWeight.w900, color: _kTextDark,
            letterSpacing: -0.3,
          )),
          ScaleTap(
            onTap: () => Navigator.pushNamed(context, '/provider/bookings'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [BoxShadow(
                    color: _kPrimaryMid.withOpacity(0.10),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Text('View All', style: TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w700, color: _kPrimary,
              )),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ...todayBookings.asMap().entries.map((e) => FadeSlide(
          delay: Duration(milliseconds: 200 + e.key * 60),
          child: _TodayBookingCard(booking: e.value),
        )),
      ]),
    );
  }
}

class _TodayBookingCard extends StatelessWidget {
  final ProviderBooking booking;
  const _TodayBookingCard({required this.booking});

  static String _mon(int m) {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
            context, '/provider/booking-detail', arguments: b),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.07),
                blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            // Left purple accent bar
            Container(
              width: 4, height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [Color(0xFF8B5CF6), _kPrimaryDeep],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            ClipOval(child: Container(
              width: 46, height: 46,
              color: const Color(0xFFEDE9FE),
              child: const Icon(Icons.person_rounded,
                  color: _kPrimaryMid, size: 23),
            )),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.clientName, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w800, color: _kTextDark,
                  letterSpacing: -0.2,
                )),
                const SizedBox(height: 2),
                Text(b.serviceName, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w500, color: _kTextMuted,
                )),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time_rounded,
                      size: 11, color: _kPrimary),
                  const SizedBox(width: 4),
                  Text(b.timeSlot, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    fontWeight: FontWeight.w700, color: _kPrimary,
                  )),
                ]),
              ],
            )),
            // Confirmed badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text('Confirmed', style: TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w700, color: Color(0xFF16A34A),
              )),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// QUICK ACCESS
// ══════════════════════════════════════════════════════════════
class _QuickAccessSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Access', style: TextStyle(
          fontFamily: 'Inter', fontSize: 16,
          fontWeight: FontWeight.w900, color: _kTextDark,
          letterSpacing: -0.3,
        )),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _QuickItem(
            icon: Icons.add_box_rounded, label: 'New Slot',
            onTap: () =>
                Navigator.pushNamed(context, '/provider/add-service'),
          ),
          _QuickItem(
            icon: Icons.history_rounded, label: 'History',
            onTap: () =>
                Navigator.pushNamed(context, '/provider/bookings'),
          ),
          _QuickItem(
            icon: Icons.chat_bubble_rounded, label: 'Messages',
            onTap: () => Navigator.pushNamed(context, '/messages'),
          ),
          _QuickItem(
            icon: Icons.settings_rounded, label: 'Settings',
            onTap: () =>
                Navigator.pushNamed(context, '/provider/settings'),
          ),
        ]),
      ]),
    );
  }
}

class _QuickItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  const _QuickItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.10),
                blurRadius: 14, offset: const Offset(0, 3))],
          ),
          child: Icon(icon, color: _kPrimary, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 10,
          fontWeight: FontWeight.w700, color: Color(0xFF4B5563),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WHITE CIRCLE BUTTON
// ══════════════════════════════════════════════════════════════
class _WhiteCircle extends StatelessWidget {
  final double size;
  final Widget child;
  const _WhiteCircle({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.10),
            blurRadius: 14, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}