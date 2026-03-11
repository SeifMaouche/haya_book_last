import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/provider_model.dart';
import 'reviews_screen.dart';
import '../widgets/glass_kit.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProvider? provider;
  const ProviderDetailScreen({Key? key, this.provider}) : super(key: key);

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  // Resolve provider from widget arg OR BookingProvider.selectedProvider
  ServiceProvider? get _p =>
      widget.provider ??
          Provider.of<BookingProvider>(context, listen: false).selectedProvider;

  List<Map<String, dynamic>> _services(String cat) {
    if (cat == 'Clinic') {
      return [
        {'name': 'General Consultation', 'abbr': 'GC',  'price': 3000.0, 'duration': 30},
        {'name': 'EEG Brain Mapping',    'abbr': 'EEG', 'price': 8500.0, 'duration': 60},
        {'name': 'Blood Test Panel',     'abbr': 'BT',  'price': 2500.0, 'duration': 15},
      ];
    } else if (cat == 'Salon') {
      return [
        {'name': 'Hair Cut & Style', 'abbr': 'HC', 'price': 1500.0, 'duration': 45},
        {'name': 'Hair Coloring',    'abbr': 'CO', 'price': 4000.0, 'duration': 90},
        {'name': 'Facial Treatment', 'abbr': 'FT', 'price': 2500.0, 'duration': 60},
      ];
    } else {
      return [
        {'name': 'Math Tutoring',    'abbr': 'MT', 'price': 2000.0, 'duration': 60},
        {'name': 'Physics Tutoring', 'abbr': 'PT', 'price': 2000.0, 'duration': 60},
        {'name': 'Test Preparation', 'abbr': 'TP', 'price': 3000.0, 'duration': 90},
      ];
    }
  }

  // Share: copies provider info to clipboard and shows snackbar
  void _doShare(ServiceProvider p) {
    final text =
        '📅 Check out ${p.name} on HayaBook!\n'
        '⭐ ${p.rating} · ${p.category}\n'
        '📍 ${p.location}\n'
        '📞 ${p.phone}';
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.copy, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('Provider info copied!',
            style: TextStyle(
                fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  // Selects a service AND the current provider, then navigates to booking
  void _bookService(ServiceProvider provider, Map<String, dynamic> s) {
    final bp =
    Provider.of<BookingProvider>(context, listen: false);
    bp.selectProvider(provider); // ensure provider is set
    bp.selectService(Service(
      id: (s['name'] as String).toLowerCase().replaceAll(' ', '_'),
      name: s['name'] as String,
      description: 'Duration: ${s['duration']} mins',
      price: s['price'] as double,
      durationMinutes: s['duration'] as int,
    ));
    Navigator.pushNamed(context, '/booking');
  }

  String _specialtyFor(ServiceProvider p) {
    switch (p.category) {
      case 'Salon': return 'BEAUTY SPECIALIST';
      case 'Tutor': return 'PRIVATE TUTOR';
      default:      return 'NEUROLOGIST';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _p;
    if (provider == null) {
      return const Scaffold(
          body: Center(child: Text('Provider not found')));
    }
    final cat = provider.category;

    return Consumer<FavoritesProvider>(
      builder: (_, fp, __) {
        final isFav = fp.isFavorite(provider.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // ── SCROLLABLE CONTENT ──────────────────────
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero
                        _HeroSection(
                          provider: provider,
                          specialtyLabel: _specialtyFor(provider),
                          isFav: isFav,
                          onBack: () => Navigator.pop(context),
                          onShare: () => _doShare(provider),
                          onFavToggle: () {
                            fp.toggleFavorite(provider);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                isFav
                                    ? 'Removed from favorites'
                                    : '${provider.name} added to favorites!',
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: isFav
                                  ? AppColors.textMuted
                                  : AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ));
                          },
                        ),

                        // Stats card
                        _StatsRow(provider: provider),

                        // Body content
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // About
                              const _SectionLabel('About'),
                              const SizedBox(height: 8),
                              Text(provider.bio,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                      height: 1.65)),
                              const SizedBox(height: 28),

                              // Services
                              const _SectionLabel('Services'),
                              const SizedBox(height: 12),
                              ..._services(cat).map((s) =>
                                  _serviceRow(provider, s)),
                              const SizedBox(height: 28),

                              // Location
                              const _SectionLabel('Location'),
                              const SizedBox(height: 12),
                              _locationSection(provider),
                              const SizedBox(height: 28),

                              // Reviews — last section
                              _ReviewsSection(provider: provider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── STICKY BOOK APPOINTMENT CTA ─────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding:
                  const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Select provider then go to booking (no service
                        // pre-selected — user picks on booking screen)
                        Provider.of<BookingProvider>(context,
                            listen: false)
                            .selectProvider(provider);
                        Navigator.pushNamed(context, '/booking');
                      },
                      icon: const Icon(Icons.calendar_today_outlined,
                          color: Colors.white, size: 18),
                      label: const Text('Book Appointment',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── SERVICE ROW ─────────────────────────────────────────────────
  Widget _serviceRow(ServiceProvider provider, Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Abbreviation chip
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(s['abbr'] as String,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(s['name'] as String,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
          ),
          // Price tap → pre-select this service and go to booking
          GestureDetector(
            onTap: () => _bookService(provider, s),
            child: Text(
              'DZD ${(s['price'] as double).toStringAsFixed(0)}',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── LOCATION SECTION ────────────────────────────────────────────
  Widget _locationSection(ServiceProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address row
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.secondary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(p.location,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Map placeholder — matches screenshot style
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MapPainter(), child: Container()),
              // Large teardrop pin — matches screenshot
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on,
                          color: AppColors.primary, size: 28),
                    ),
                    // Pin stem
                    Container(
                        width: 3,
                        height: 10,
                        color: Colors.white),
                    // Pin dot base
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO SECTION
// ═══════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final ServiceProvider provider;
  final String specialtyLabel;
  final bool isFav;
  final VoidCallback onBack;
  final VoidCallback onShare;   // wired to _doShare in parent
  final VoidCallback onFavToggle;

  const _HeroSection({
    required this.provider,
    required this.specialtyLabel,
    required this.isFav,
    required this.onBack,
    required this.onShare,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            children: [
              // Top nav row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBtn(icon: Icons.chevron_left, onTap: onBack),
                  _NavBtn(
                    icon: isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor:
                    isFav ? const Color(0xFFFF6B6B) : null,
                    onTap: onFavToggle,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Glass card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                          width: 1),
                    ),
                    child: Column(
                      children: [
                        // Avatar + green online dot
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundImage:
                                AssetImage(provider.localImage),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Name
                        Text(provider.name,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),

                        // Specialty label
                        Text(specialtyLabel,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                                color:
                                Colors.white.withOpacity(0.78))),
                        const SizedBox(height: 16),

                        // Bottom row: verified pill + action buttons
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            // Verified badge
                            if (provider.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                  Colors.white.withOpacity(0.18),
                                  borderRadius:
                                  BorderRadius.circular(99),
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.28)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        Icons.verified_rounded,
                                        color: Colors.white,
                                        size: 14),
                                    const SizedBox(width: 5),
                                    Text('VERIFIED',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: Colors.white
                                                .withOpacity(0.95))),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),

                            // Chat + Share buttons
                            Row(
                              children: [
                                _ActionBtn(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  onTap: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text(
                                          'Chat coming soon!',
                                          style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight:
                                              FontWeight.w600)),
                                      backgroundColor:
                                      AppColors.primary,
                                      behavior:
                                      SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              12)),
                                      duration: const Duration(
                                          seconds: 2),
                                    ));
                                  },
                                ),
                                const SizedBox(width: 10),
                                // Share button correctly calls onShare
                                _ActionBtn(
                                    icon: Icons.share_outlined,
                                    onTap: onShare),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav button (back / favorite) ────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _NavBtn(
      {required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.20),
        border:
        Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child:
      Icon(icon, color: iconColor ?? Colors.white, size: 20),
    ),
  );
}

// ── Action button inside card (chat / share) ─────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.20),
        border: Border.all(
            color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// STATS ROW CARD
// ═══════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final ServiceProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
              icon: Icons.work_outline_rounded,
              value: '8 yrs',
              label: 'EXP.'),
          Container(width: 1, height: 36, color: const Color(0xFFE9ECEF)),
          _StatItem(
              icon: Icons.people_outline_rounded,
              value: '2.7K+',
              label: 'PATIENTS'),
          Container(width: 1, height: 36, color: const Color(0xFFE9ECEF)),
          _StatItem(
              icon: Icons.star_border_rounded,
              value: '${provider.rating}',
              label: 'REVIEWS'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Plain teal icon — NO circle container, matches screenshot
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.textMuted)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REVIEWS SECTION
// ═══════════════════════════════════════════════════════════════
class _ReviewsSection extends StatelessWidget {
  final ServiceProvider provider;
  const _ReviewsSection({required this.provider});

  static const List<Map<String, dynamic>> _mockReviews = [
    {
      'name': 'Sarah M.',
      'initials': 'SM',
      'stars': 5,
      'text':
      '"Dr. Clifford was incredibly patient and thorough with my initial screening. Highly recommend!"',
      'date': '2 days ago',
    },
    {
      'name': 'Karim B.',
      'initials': 'KB',
      'stars': 5,
      'text':
      '"Excellent service. Very professional and knowledgeable."',
      'date': '1 week ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel('Reviews'),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewsScreen(
                    providerName: provider.name,
                    providerId: provider.id,
                  ),
                ),
              ),
              child: const Text('SEE ALL',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._mockReviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final int stars = review['stars'] as int;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar circle with initials
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(review['initials'] as String,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['name'] as String,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    Text(review['date'] as String,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              // Rating — orange, right aligned
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$stars.0',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B))),
                  const SizedBox(width: 3),
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review['text'] as String,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                  height: 1.5)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark));
}

// ═══════════════════════════════════════════════════════════════
// MAP PAINTER
// ═══════════════════════════════════════════════════════════════
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light teal background matching screenshot
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFEDE9FE));

    final road = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final minor = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    for (double y = 36; y < size.height; y += 56)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    for (double y = 64; y < size.height; y += 56)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);

    // Vertical roads
    for (double x = 50; x < size.width; x += 70)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    for (double x = 85; x < size.width; x += 70)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);

    // City blocks — slightly darker teal rectangles
    final block = Paint()..color = const Color(0xFFC4B5FD);
    for (final r in [
      Rect.fromLTWH(5, 4, 42, 28),    Rect.fromLTWH(55, 4, 38, 28),
      Rect.fromLTWH(101, 4, 46, 28),  Rect.fromLTWH(155, 4, 40, 28),
      Rect.fromLTWH(205, 4, 48, 28),  Rect.fromLTWH(261, 4, 36, 28),
      Rect.fromLTWH(5, 44, 42, 16),   Rect.fromLTWH(55, 44, 38, 16),
      Rect.fromLTWH(101, 44, 46, 16), Rect.fromLTWH(205, 44, 48, 16),
      Rect.fromLTWH(5, 68, 42, 26),   Rect.fromLTWH(55, 68, 38, 26),
      Rect.fromLTWH(155, 68, 40, 26), Rect.fromLTWH(205, 68, 48, 26),
      Rect.fromLTWH(5, 104, 42, 28),  Rect.fromLTWH(101, 104, 46, 28),
      Rect.fromLTWH(205, 104, 48, 28),Rect.fromLTWH(261, 104, 36, 28),
      Rect.fromLTWH(5, 144, 42, 28),  Rect.fromLTWH(55, 144, 38, 28),
      Rect.fromLTWH(155, 144, 40, 28),Rect.fromLTWH(205, 144, 48, 28),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(3)), block);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}