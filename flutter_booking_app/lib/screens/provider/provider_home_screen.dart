// lib/screens/provider/provider_home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';
import '../../widgets/haya_avatar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/app_config.dart';
import '../../providers/notification_provider.dart';

const _kPrimary     = Color(0xFF6D28D9);
const _kPrimaryMid  = Color(0xFF7C3AED);
const _kPrimaryDeep = Color(0xFF5B21B6);
const _kPrimaryDark = Color(0xFF2E1065);
const _kLavender    = Color(0xFFA78BFA);
const _kTextDark    = Color(0xFF1E1B4B);
const _kTextMuted   = Color(0xFF6B7280);

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ProviderStateProvider>(context, listen: false);
      prov.loadInitialData();
      prov.initSocket(); // Connect to real-time booking updates
      final chat = Provider.of<ChatProvider>(context, listen: false);
      chat.initSocket();
      chat.fetchMyConversations();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

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
                  // ── Quick Access ──
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: const Duration(milliseconds: 100),
                      child: _QuickAccessSection())),
                  // ── Today's appointments (horizontal) ──
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: const Duration(milliseconds: 140),
                      child: _TodayBookingsSection(ps: ps))),
                  // ── Upcoming bookings (vertical) ──
                  SliverToBoxAdapter(child: FadeSlide(
                      delay: const Duration(milliseconds: 180),
                      child: _UpcomingBookingsSection(ps: ps))),
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
        Consumer<AuthProvider>(
          builder: (_, auth, __) => HayaAvatar(
            avatarUrl: auth.photoPath,
            size: 46,
            isProvider: true,
            borderRadius: 99,
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
        Consumer<NotificationProvider>(
          builder: (_, np, __) => Stack(
            clipBehavior: Clip.none,
            children: [
              ScaleTap(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: _WhiteCircle(
                  size: 40,
                  child: const Icon(Icons.notifications_outlined,
                      color: _kPrimaryMid, size: 19),
                ),
              ),
              if (np.unreadCount > 0)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      np.unreadCount > 9 ? '9+' : '${np.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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
// TODAY'S BOOKINGS (Horizontal Strip)
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Today", style: TextStyle(
            fontFamily: 'Inter', fontSize: 16,
            fontWeight: FontWeight.w900, color: _kTextDark,
            letterSpacing: -0.3,
          )),
        ),
        const SizedBox(height: 12),
        if (todayBookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                'No appointments scheduled for today.',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w500, color: _kTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 115,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: todayBookings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _TodayCardCompact(booking: todayBookings[i]),
            ),
          ),
      ]),
    );
  }
}

class _TodayCardCompact extends StatelessWidget {
  final ProviderBooking booking;
  const _TodayCardCompact({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, '/provider/booking-detail', arguments: booking),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.08),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              HayaAvatar(
                avatarUrl: booking.clientAvatar,
                name: booking.clientName,
                size: 32,
                borderRadius: 99,
                isProvider: false,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(booking.clientName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w800, color: _kTextDark,
                ))),
            ]),
            const Spacer(),
            Text(booking.serviceName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w500, color: _kTextMuted,
              )),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, size: 10, color: Color(0xFF16A34A)),
                  const SizedBox(width: 4),
                  Text(booking.timeSlot, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w700, color: Color(0xFF16A34A),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// UPCOMING BOOKINGS (Vertical List)
// ══════════════════════════════════════════════════════════════
class _UpcomingBookingsSection extends StatelessWidget {
  final ProviderStateProvider ps;
  const _UpcomingBookingsSection({required this.ps});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Exclude today to get purely "upcoming future"
    var futureBookings = ps.upcomingBookings.where((b) {
      final isToday = b.bookingDate.day == today.day &&
          b.bookingDate.month == today.month &&
          b.bookingDate.year == today.year;
      return !isToday && b.bookingDate.isAfter(today);
    }).toList();

    futureBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    final nextFive = futureBookings.take(5).toList();

    if (nextFive.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Upcoming", style: TextStyle(
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
        ...nextFive.map((b) => _TodayBookingCard(booking: b)),
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
            HayaAvatar(
              avatarUrl:    b.clientAvatar,
              name:         b.clientName,
              size:         46,
              borderRadius: 99,
              isProvider:   true, // Forces the purple brand color for the portal
            ),
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
                  const Icon(Icons.calendar_today_rounded,
                      size: 11, color: _kPrimary),
                  const SizedBox(width: 4),
                  Text('${b.bookingDate.day} ${_mon(b.bookingDate.month)} • ${b.timeSlot}', style: const TextStyle(
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
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Access', style: TextStyle(
          fontFamily: 'Inter', fontSize: 16,
          fontWeight: FontWeight.w900, color: _kTextDark,
          letterSpacing: -0.3,
        )),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _QuickItem(
            icon: Icons.event_available_rounded, label: 'Availability',
            onTap: () =>
                Navigator.pushNamed(context, '/provider/availability'),
          ),
          _QuickItem(
            icon: Icons.settings_rounded, label: 'Settings',
            onTap: () =>
                Navigator.pushNamed(context, '/provider/settings'),
          ),
          _QuickItem(
            icon: Icons.star_rounded, label: 'Reviews',
            onTap: () => Navigator.pushNamed(context, '/provider/reviews'),
          ),
          _QuickItem(
            icon: Icons.bar_chart_rounded, label: 'Earnings',
            onTap: () =>
                Navigator.pushNamed(context, '/provider/earnings'),
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