// lib/screens/provider_detail_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/provider_profile_provider.dart';
import '../models/provider_model.dart';
import 'provider/chat_provider.dart';
import 'chat_screen.dart';
import 'reviews_screen.dart';
import '../widgets/glass_kit.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProvider? provider;
  const ProviderDetailScreen({Key? key, this.provider}) : super(key: key);

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {

  ServiceProvider? get _p =>
      widget.provider ??
          Provider.of<BookingProvider>(context, listen: false).selectedProvider;

  List<Map<String, dynamic>> _services(String cat) {
    if (cat == 'Clinic' || cat == 'Medical / Clinic') {
      return [
        {'name': 'General Consultation', 'abbr': 'GC',  'price': 3000.0, 'duration': 30},
        {'name': 'EEG Brain Mapping',    'abbr': 'EEG', 'price': 8500.0, 'duration': 60},
        {'name': 'Blood Test Panel',     'abbr': 'BT',  'price': 2500.0, 'duration': 15},
      ];
    } else if (cat == 'Salon' || cat == 'Beauty & Salon' ||
        cat == 'Beauty & Grooming') {
      return [
        {'name': 'Hair Cut & Style', 'abbr': 'HC', 'price': 1500.0, 'duration': 45},
        {'name': 'Hair Coloring',    'abbr': 'CO', 'price': 4000.0, 'duration': 90},
        {'name': 'Facial Treatment', 'abbr': 'FT', 'price': 2500.0, 'duration': 60},
      ];
    } else if (cat == 'Tutor' || cat == 'Tutoring') {
      return [
        {'name': 'Math Tutoring',    'abbr': 'MT', 'price': 2000.0, 'duration': 60},
        {'name': 'Physics Tutoring', 'abbr': 'PT', 'price': 2000.0, 'duration': 60},
        {'name': 'Test Preparation', 'abbr': 'TP', 'price': 3000.0, 'duration': 90},
      ];
    } else {
      return [
        {'name': 'Initial Consultation', 'abbr': 'IC', 'price': 2500.0, 'duration': 45},
        {'name': 'Full Session',         'abbr': 'FS', 'price': 5000.0, 'duration': 90},
        {'name': 'Follow-up',            'abbr': 'FU', 'price': 1500.0, 'duration': 30},
      ];
    }
  }

  void _openChat(ServiceProvider provider) {
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final conv = chat.getOrCreate(
      providerName:     provider.name,
      providerCategory: provider.category,
      clientName:       'Ahmed Benali',
    );
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatScreen(
        providerName: provider.name,
        providerAvatar: provider.localImage,
        isProvider: false,
      ),
    ));
  }

  void _doShare(ServiceProvider p) {
    Clipboard.setData(ClipboardData(
      text: '📅 Check out ${p.name} on HayaBook!\n'
          '⭐ ${p.rating} · ${p.category}\n'
          '📍 ${p.location}\n'
          '📞 ${p.phone}',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.copy, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('Provider info copied!',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _bookService(ServiceProvider provider, Map<String, dynamic> s) {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    bp.selectProvider(provider);
    bp.selectService(Service(
      id:              (s['name'] as String).toLowerCase().replaceAll(' ', '_'),
      name:            s['name'] as String,
      description:     'Duration: ${s['duration']} mins',
      price:           s['price'] as double,
      durationMinutes: s['duration'] as int,
    ));
    Navigator.pushNamed(context, '/booking');
  }

  String _specialtyFor(ServiceProvider p) {
    switch (p.category) {
      case 'Salon':
      case 'Beauty & Salon':
      case 'Beauty & Grooming': return 'BEAUTY SPECIALIST';
      case 'Tutor':
      case 'Tutoring':          return 'PRIVATE TUTOR';
      case 'Fitness':           return 'FITNESS TRAINER';
      case 'Spa & Relaxation':  return 'SPA THERAPIST';
      default:                  return 'HEALTH PROFESSIONAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _p;
    if (provider == null) {
      return const Scaffold(body: Center(child: Text('Provider not found')));
    }

    final profile         = Provider.of<ProviderProfileProvider>(context);
    final displayName     = profile.businessName;
    final displayBio      = profile.bio;
    final displayLoc      = profile.locationText;
    final displayLogo     = profile.logoFile;
    final displayPortfolio = profile.portfolioPhotos;

    return Consumer<FavoritesProvider>(
      builder: (_, fp, __) {
        final isFav = fp.isFavorite(provider.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(children: [

            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero ──────────────────────────────
                      _HeroSection(
                        provider:       provider,
                        displayName:    displayName,
                        specialtyLabel: _specialtyFor(provider),
                        isFav:          isFav,
                        logoFile:       displayLogo,
                        onBack:        () => Navigator.pop(context),
                        onShare:       () => _doShare(provider),
                        onChat:        () => _openChat(provider),
                        onFavToggle:   () {
                          fp.toggleFavorite(provider);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(isFav
                                ? 'Removed from favorites'
                                : '$displayName added to favorites!',
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: isFav
                                ? AppColors.textMuted : AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ));
                        },
                      ),

                      // ── Rating strip ──────────────────────
                      _RatingStrip(
                        rating:      profile.rating,
                        reviewCount: profile.reviewCount,
                        category:    provider.category,
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ── About ──────────────────────
                            const _SectionLabel('About'),
                            const SizedBox(height: 8),
                            Text(displayBio,
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:   14,
                                    color:      AppColors.textMuted,
                                    height:     1.65)),
                            const SizedBox(height: 28),

                            // ── Portfolio — ALWAYS visible ─
                            _PortfolioSection(photos: displayPortfolio),
                            const SizedBox(height: 28),

                            // ── Services ───────────────────
                            const _SectionLabel('Services'),
                            const SizedBox(height: 12),
                            ..._services(provider.category).map((s) =>
                                _ServiceRow(
                                  service: s,
                                  onBook:  () => _bookService(provider, s),
                                )),
                            const SizedBox(height: 28),

                            // ── Location ───────────────────
                            const _SectionLabel('Location'),
                            const SizedBox(height: 12),
                            _LocationSection(addressText: displayLoc),
                            const SizedBox(height: 28),

                            // ── Reviews ────────────────────
                            _ReviewsSection(provider: provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Sticky bottom bar ──────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _BottomActionBar(
                onMessage: () => _openChat(provider),
                onBook:    () {
                  Provider.of<BookingProvider>(context, listen: false)
                      .selectProvider(provider);
                  Navigator.pushNamed(context, '/booking');
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PORTFOLIO SECTION  — always rendered
// Shows a grid when photos exist, a friendly placeholder when empty.
// ══════════════════════════════════════════════════════════════
class _PortfolioSection extends StatefulWidget {
  final List<File> photos;
  const _PortfolioSection({required this.photos});
  @override
  State<_PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<_PortfolioSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasPhotos = widget.photos.isNotEmpty;
    final shown     = _expanded
        ? widget.photos
        : widget.photos.take(6).toList();
    final hasMore   = widget.photos.length > 6;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SectionLabel('Portfolio'),
          if (hasPhotos)
            Text('${widget.photos.length} PHOTOS',
                style: const TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      11,
                  fontWeight:    FontWeight.w700,
                  color:         AppColors.primary,
                  letterSpacing: 0.5,
                )),
        ],
      ),
      const SizedBox(height: 12),

      // ── Photos grid ───────────────────────────────────────
      if (hasPhotos) ...[
        GridView.builder(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   3,
            crossAxisSpacing: 8,
            mainAxisSpacing:  8,
          ),
          itemCount: shown.length,
          itemBuilder: (_, i) {
            final isLastAndMore = !_expanded && hasMore && i == 5;
            return GestureDetector(
              onTap: () => _openViewer(context, i),
              child: Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(shown[i], fit: BoxFit.cover),
                ),
                if (isLastAndMore)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                      child: Center(child: Text(
                        '+${widget.photos.length - 5}',
                        style: const TextStyle(
                          fontFamily:  'Inter',
                          fontSize:    22,
                          fontWeight:  FontWeight.w800,
                          color:       Colors.white,
                        ),
                      )),
                    ),
                  ),
              ]),
            );
          },
        ),
        if (hasMore) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded
                        ? 'Show less'
                        : 'Show all ${widget.photos.length} photos',
                    style: const TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    13,
                      fontWeight:  FontWeight.w700,
                      color:       AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary, size: 18,
                  ),
                ]),
          ),
        ],
      ]

      // ── Empty placeholder ──────────────────────────────────
      else
        Container(
          width:  double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color:        AppColors.primaryLight.withOpacity(0.40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.12), width: 1.5),
          ),
          child: Column(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 10),
            const Text('No portfolio photos yet',
                style: TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    13,
                  fontWeight:  FontWeight.w600,
                  color:       AppColors.textDark,
                )),
            const SizedBox(height: 4),
            Text('The provider hasn\'t added photos yet',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize:   12,
                  color:      AppColors.textMuted.withOpacity(0.80),
                )),
          ]),
        ),
    ]);
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _PhotoViewer(
        photos:       widget.photos,
        initialIndex: index,
      ),
    ));
  }
}

// ── Full-screen photo viewer ──────────────────────────────────
class _PhotoViewer extends StatefulWidget {
  final List<File> photos;
  final int        initialIndex;
  const _PhotoViewer({required this.photos, required this.initialIndex});
  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl    = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        PageView.builder(
          controller:    _ctrl,
          itemCount:     widget.photos.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder:   (_, i) => InteractiveViewer(
            child: Center(
                child: Image.file(widget.photos[i], fit: BoxFit.contain)),
          ),
        ),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color:        Colors.black.withOpacity(0.50),
                  borderRadius: BorderRadius.circular(99)),
              child: Text('${_current + 1} / ${widget.photos.length}',
                  style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ]),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTTOM ACTION BAR
// ══════════════════════════════════════════════════════════════
class _BottomActionBar extends StatelessWidget {
  final VoidCallback onMessage;
  final VoidCallback onBook;
  const _BottomActionBar({required this.onMessage, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(children: [
        // Message button
        GestureDetector(
          onTap: onMessage,
          child: Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.25), width: 1.5),
            ),
            child: const Icon(Icons.chat_bubble_rounded,
                color: AppColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        // Book button
        Expanded(child: GestureDetector(
          onTap: onBook,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color:        AppColors.primary,
              borderRadius: BorderRadius.circular(99),
              boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Book Appointment',
                    style: TextStyle(
                        fontFamily:  'Inter',
                        fontSize:    16,
                        fontWeight:  FontWeight.w700,
                        color:       Colors.white)),
              ],
            ),
          ),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HERO SECTION
// ══════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final ServiceProvider provider;
  final String          displayName;
  final String          specialtyLabel;
  final bool            isFav;
  final File?           logoFile;
  final VoidCallback    onBack, onShare, onChat, onFavToggle;

  const _HeroSection({
    required this.provider,
    required this.displayName,
    required this.specialtyLabel,
    required this.isFav,
    required this.logoFile,
    required this.onBack,
    required this.onShare,
    required this.onChat,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavBtn(icon: Icons.chevron_left, onTap: onBack),
                _NavBtn(
                  icon: isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: isFav ? const Color(0xFFFF6B6B) : null,
                  onTap: onFavToggle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.28), width: 1),
                  ),
                  child: Column(children: [
                    Stack(children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ClipOval(child: SizedBox(
                          width: 88, height: 88,
                          child: logoFile != null
                              ? Image.file(logoFile!,
                              fit: BoxFit.cover, width: 88, height: 88)
                              : Image.asset(provider.localImage,
                              fit: BoxFit.cover, width: 88, height: 88),
                        )),
                      ),
                      Positioned(bottom: 4, right: 4,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border:
                            Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Text(displayName,
                        style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 22,
                            fontWeight: FontWeight.w700, color: Colors.white),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(specialtyLabel,
                        style: TextStyle(
                            fontFamily:    'Inter', fontSize: 12,
                            fontWeight:    FontWeight.w500,
                            letterSpacing: 1.2,
                            color: Colors.white.withOpacity(0.78))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (provider.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.28)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text('VERIFIED',
                                      style: TextStyle(
                                          fontFamily:    'Inter', fontSize: 11,
                                          fontWeight:    FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: Colors.white.withOpacity(0.95))),
                                ]),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(children: [
                          _ActionBtn(
                              icon: Icons.chat_bubble_outline_rounded,
                              onTap: onChat),
                          const SizedBox(width: 10),
                          _ActionBtn(
                              icon: Icons.share_outlined, onTap: onShare),
                        ]),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final Color? iconColor;
  const _NavBtn({required this.icon, required this.onTap, this.iconColor});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.white.withOpacity(0.20),
        border: Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.white.withOpacity(0.20),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// RATING STRIP
// ══════════════════════════════════════════════════════════════
class _RatingStrip extends StatelessWidget {
  final double rating; final int reviewCount; final String category;
  const _RatingStrip({required this.rating, required this.reviewCount,
    required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:   const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding:  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22),
        const SizedBox(width: 5),
        Text('$rating',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 18,
                fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(width: 4),
        Text('($reviewCount reviews)',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                color: AppColors.textMuted)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight, borderRadius: BorderRadius.circular(99),
          ),
          child: Text(category,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SERVICE ROW
// ══════════════════════════════════════════════════════════════
class _ServiceRow extends StatelessWidget {
  final Map<String, dynamic> service; final VoidCallback onBook;
  const _ServiceRow({required this.service, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(service['abbr'] as String,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: AppColors.primary))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service['name'] as String,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w500, color: AppColors.textDark)),
            Text('${service['duration']} min',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.textMuted)),
          ],
        )),
        GestureDetector(
          onTap: onBook,
          child: Text('DZD ${(service['price'] as double).toStringAsFixed(0)}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LOCATION SECTION
// ══════════════════════════════════════════════════════════════
class _LocationSection extends StatelessWidget {
  final String addressText;
  const _LocationSection({required this.addressText});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(children: [
          const Icon(Icons.location_on, color: AppColors.secondary, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(addressText,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.textMuted))),
        ]),
      ),
      const SizedBox(height: 10),
      Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          CustomPaint(painter: _MapPainter(), child: Container()),
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Icon(Icons.location_on,
                    color: AppColors.primary, size: 28),
              ),
              Container(width: 3, height: 10, color: Colors.white),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle),
              ),
            ],
          )),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// REVIEWS SECTION
// ══════════════════════════════════════════════════════════════
class _ReviewsSection extends StatelessWidget {
  final ServiceProvider provider;
  const _ReviewsSection({required this.provider});

  static const List<Map<String, dynamic>> _mockReviews = [
    {'name': 'Sarah M.',  'initials': 'SM', 'stars': 5,
      'text': '"Incredibly patient and thorough. Highly recommend!"',
      'date': '2 days ago'},
    {'name': 'Karim B.',  'initials': 'KB', 'stars': 5,
      'text': '"Excellent service. Very professional and knowledgeable."',
      'date': '1 week ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SectionLabel('Reviews'),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ReviewsScreen(
                  providerName: provider.name, providerId: provider.id),
            )),
            child: const Text('SEE ALL',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5,
                    color: AppColors.primary)),
          ),
        ],
      ),
      const SizedBox(height: 14),
      ..._mockReviews.map((r) => _ReviewCard(review: r)),
    ]);
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Center(child: Text(review['initials'] as String,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.primary))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review['name'] as String,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(review['date'] as String,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                      color: AppColors.textMuted)),
            ],
          )),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text('$stars.0', style: const TextStyle(fontFamily: 'Inter',
                fontSize: 13, fontWeight: FontWeight.w700,
                color: Color(0xFFF59E0B))),
            const SizedBox(width: 3),
            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
          ]),
        ]),
        const SizedBox(height: 8),
        Text(review['text'] as String,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontStyle: FontStyle.italic, color: AppColors.textMuted,
                height: 1.5)),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 18,
          fontWeight: FontWeight.w700, color: AppColors.textDark));
}

// ══════════════════════════════════════════════════════════════
// MAP PAINTER
// ══════════════════════════════════════════════════════════════
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFEDE9FE));
    final road  = Paint()..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 10..style = PaintingStyle.stroke;
    final minor = Paint()..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 4..style = PaintingStyle.stroke;
    for (double y = 36; y < size.height; y += 56)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    for (double y = 64; y < size.height; y += 56)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    for (double x = 50; x < size.width; x += 70)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    for (double x = 85; x < size.width; x += 70)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    final block = Paint()..color = const Color(0xFFC4B5FD);
    for (final r in [
      Rect.fromLTWH(5,4,42,28), Rect.fromLTWH(55,4,38,28),
      Rect.fromLTWH(101,4,46,28), Rect.fromLTWH(155,4,40,28),
      Rect.fromLTWH(205,4,48,28), Rect.fromLTWH(261,4,36,28),
      Rect.fromLTWH(5,68,42,26), Rect.fromLTWH(55,68,38,26),
      Rect.fromLTWH(205,68,48,26), Rect.fromLTWH(5,104,42,28),
      Rect.fromLTWH(101,104,46,28), Rect.fromLTWH(205,104,48,28),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(3)), block);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}