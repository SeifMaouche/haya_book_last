// lib/screens/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../models/provider_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass_kit.dart';
import 'location_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _location = 'Algiers, Algeria';

  static const List<Map<String, dynamic>> _quickCategories = [
    {
      'label': 'Clinic',
      'icon': Icons.health_and_safety_rounded,
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      'emoji': '🏥',
    },
    {
      'label': 'Salon',
      'icon': Icons.auto_fix_high_rounded,
      'gradient': [Color(0xFFFF8A65), Color(0xFFE53935)],
      'emoji': '✂️',
    },
    {
      'label': 'Tutor',
      'icon': Icons.menu_book_rounded,
      'gradient': [Color(0xFF7C83FF), Color(0xFF5152CC)],
      'emoji': '📚',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchProviders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final q = _searchCtrl.text.trim();
    Provider.of<BookingProvider>(context, listen: false)
        .fetchProviders(searchQuery: q.isEmpty ? null : q);
    Navigator.pushNamed(context, '/browse');
  }

  Future<void> _changeLocation() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => LocationPickerSheet(
        currentLocation: _location,
        onSelected: (city) => Navigator.pop(context, city),
      ),
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  String _imageFor(String cat) {
    switch (cat) {
      case 'Salon': return 'assets/images/salon.png';
      case 'Tutor': return 'assets/images/tutop.png';
      default:      return 'assets/images/doc.png';
    }
  }

  List<Color> _gradientFor(String cat) {
    switch (cat) {
      case 'Salon': return const [Color(0xFFFF8A65), Color(0xFFE53935)];
      case 'Tutor': return const [Color(0xFF7C83FF), Color(0xFF5152CC)];
      default:      return const [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
    }
  }

  IconData _iconFor(String cat) {
    switch (cat) {
      case 'Salon': return Icons.auto_fix_high_rounded;
      case 'Tutor': return Icons.menu_book_rounded;
      default:      return Icons.health_and_safety_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsing header ──────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Body content ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Quick Access
                FadeSlide(delay: const Duration(milliseconds: 60),
                    child: _sectionHeader('Quick Access',
                            () => Navigator.pushNamed(context, '/browse'))),
                const SizedBox(height: 12),
                FadeSlide(delay: const Duration(milliseconds: 100),
                    child: _buildQuickAccess()),

                const SizedBox(height: 26),

                // Upcoming
                FadeSlide(delay: const Duration(milliseconds: 140),
                    child: _buildUpcomingSection()),

                // Featured Providers
                FadeSlide(delay: const Duration(milliseconds: 180),
                    child: _sectionHeader('Featured Providers',
                            () => Navigator.pushNamed(context, '/browse'))),
                const SizedBox(height: 12),
                FadeSlide(delay: const Duration(milliseconds: 220),
                    child: _buildFeaturedProviders()),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (i) => navigateToTab(context, i),
      ),
    );
  }

  // ── SECTION HEADER ──────────────────────────────────────────
  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 17,
              fontWeight: FontWeight.w800, color: AppColors.textDark,
              letterSpacing: -0.2,
            )),
        ScaleTap(
          onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text('See all',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.primary,
                )),
          ),
        ),
      ],
    );
  }

  // ── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B6DFF), Color(0xFF6D28D9)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Row 1: Logo + Bell + Favorites
              FadeSlide(delay: Duration.zero, dy: 14, child:
              Row(children: [
                const Text('MAWIDI',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 22,
                      fontWeight: FontWeight.w900, color: Colors.white,
                      letterSpacing: -0.8,
                    )),
                const Spacer(),
                // Bell
                Consumer<BookingProvider>(builder: (_, bp, __) {
                  final n = bp.getUpcomingBookings().length;
                  return GlassButton(
                    size: 44,
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Stack(children: [
                      const Center(child: Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 22)),
                      if (n > 0)
                        Positioned(top: 8, right: 8,
                          child: Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 1.5),
                            ),
                            child: Center(child: Text('$n',
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ))),
                          ),
                        ),
                    ]),
                  );
                }),
                const SizedBox(width: 10),
                // Favorites
                GlassButton(
                  size: 44,
                  onTap: () => Navigator.pushNamed(context, '/favorites'),
                  child: const Icon(Icons.favorite_border_rounded,
                      color: Colors.white, size: 21),
                ),
              ]),
              ),

              const SizedBox(height: 14),

              // Row 2: Location pill (GlassBox)
              FadeSlide(delay: const Duration(milliseconds: 80), dy: 14, child:
              ScaleTap(
                onTap: _changeLocation,
                child: GlassBox(
                  radius: 99, blur: 18, tintOpacity: 0.20,
                  borderOpacity: 0.30, shadows: [],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(_location,
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w500, color: Colors.white,
                        )),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 16),
                  ]),
                ),
              ),
              ),

              const SizedBox(height: 16),

              // Row 3: Search bar
              FadeSlide(delay: const Duration(milliseconds: 110), dy: 14, child:
              _SearchBar(
                controller: _searchCtrl,
                onSearch: _search,
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QUICK ACCESS ─────────────────────────────────────────────
  Widget _buildQuickAccess() {
    return Row(
      children: List.generate(_quickCategories.length, (i) {
        final cat   = _quickCategories[i];
        final grad  = cat['gradient'] as List<Color>;
        final icon  = cat['icon']     as IconData;
        final label = cat['label']    as String;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
            child: ScaleTap(
              onTap: () {
                Provider.of<BookingProvider>(context, listen: false)
                    .fetchProviders(category: label);
                Navigator.pushNamed(context, '/browse');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: grad[0].withOpacity(0.12), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: grad[0].withOpacity(0.12),
                      blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  GlassAppIcon(icon: icon, gradient: grad, size: 54, radius: 17),
                  const SizedBox(height: 11),
                  Text(label,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w700, color: AppColors.textDark,
                      )),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── UPCOMING ─────────────────────────────────────────────────
  Widget _buildUpcomingSection() {
    return Consumer<BookingProvider>(builder: (context, bp, _) {
      final upcoming = bp.getUpcomingBookings();
      if (upcoming.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Text('Upcoming',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 17,
                  fontWeight: FontWeight.w800, color: AppColors.textDark,
                  letterSpacing: -0.2,
                )),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text('${upcoming.length}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w800, color: Colors.white,
                  )),
            ),
          ]),
          ScaleTap(
            onTap: () => Navigator.pushNamed(context, '/bookings'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text('See all',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700, color: AppColors.primary,
                  )),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ...upcoming.take(2).map(_upcomingCard),
        const SizedBox(height: 22),
      ]);
    });
  }

  Widget _upcomingCard(booking) {
    final catStr = booking.providerName.toLowerCase().contains('salon')
        ? 'Salon'
        : booking.providerName.toLowerCase().contains('tutor') ||
        booking.providerName.toLowerCase().contains('prof')
        ? 'Tutor'
        : 'Clinic';
    final grad = _gradientFor(catStr);
    final icon = _iconFor(catStr);

    return ScaleTap(
      onTap: () => Navigator.pushNamed(context, '/bookings'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [BoxShadow(
              color: grad[0].withOpacity(0.07),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          // Icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [grad[0], grad[1]],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                  color: grad[0].withOpacity(0.28),
                  blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 11),
          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.serviceName,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.textDark,
                  )),
              const SizedBox(height: 1),
              Text(booking.providerName,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.textMuted,
                  )),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 10, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM d').format(booking.bookingDate)} · ${booking.timeSlot}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600, color: AppColors.primary,
                  ),
                ),
              ]),
            ],
          )),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text('Confirmed',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w800, color: AppColors.success,
                  letterSpacing: 0.2,
                )),
          ),
        ]),
      ),
    );
  }

  // ── FEATURED PROVIDERS ────────────────────────────────────────
  Widget _buildFeaturedProviders() {
    return Consumer<BookingProvider>(builder: (context, bp, _) {
      if (bp.isLoading) {
        return const Center(child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ));
      }
      if (bp.providers.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: Text('No providers available',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  color: AppColors.textMuted))),
        );
      }
      return SizedBox(
        height: 226,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: bp.providers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (ctx, i) => _providerCard(ctx, bp.providers[i]),
        ),
      );
    });
  }

  Widget _providerCard(BuildContext context, ServiceProvider p) {
    final grad = _gradientFor(p.category);
    return ScaleTap(
      onTap: () {
        Provider.of<BookingProvider>(context, listen: false).selectProvider(p);
        Navigator.pushNamed(context, '/provider', arguments: {'provider': p});
      },
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [BoxShadow(
              color: grad[0].withOpacity(0.09),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          const SizedBox(height: 16),
          // Avatar
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [grad[0], grad[1]],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(
                  color: grad[0].withOpacity(0.28),
                  blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: ClipOval(child: Image.asset(
                _imageFor(p.category),
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
              )),
            ),
          ),
          const SizedBox(height: 9),
          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(p.name,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.textDark,
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 4),
          // Rating
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
            const SizedBox(width: 3),
            Text('${p.rating}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w600, color: AppColors.textDark,
                )),
          ]),
          const Spacer(),
          // Book Now button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            child: ScaleTap(
              onTap: () {
                Provider.of<BookingProvider>(context, listen: false)
                    .selectProvider(p);
                Navigator.pushNamed(context, '/booking');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [grad[0], grad[1]],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [BoxShadow(
                      color: grad[0].withOpacity(0.30),
                      blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: const Center(child: Text('Book Now',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11,
                      fontWeight: FontWeight.w700, color: Colors.white,
                    ))),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}



// ══════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        const Padding(
          padding: EdgeInsets.only(left: 14),
          child: Icon(Icons.search_rounded,
              color: AppColors.textLight, size: 19),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onSearch(),
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.textDark,
            ),
            decoration: const InputDecoration(
              hintText: 'Search providers, services...',
              hintStyle: TextStyle(
                fontFamily: 'Inter', fontSize: 13, color: AppColors.textLight,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 13),
            ),
          ),
        ),
        GestureDetector(
          onTap: onSearch,
          child: Container(
            margin: const EdgeInsets.all(5),
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: AppColors.secondary, shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 17),
          ),
        ),
      ]),
    );
  }
}