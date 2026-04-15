// lib/screens/provider_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/provider_model.dart' as pm;
import 'chat_screen.dart';
import 'reviews_screen.dart';
import '../config/app_config.dart';
import '../widgets/haya_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ProviderDetailScreen extends StatefulWidget {
  final pm.ServiceProvider? provider;
  const ProviderDetailScreen({Key? key, this.provider}) : super(key: key);

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {

  pm.ServiceProvider? get _p =>
      widget.provider ??
          Provider.of<BookingProvider>(context, listen: false).selectedProvider;


  void _openChat(pm.ServiceProvider provider) {
    // Simply navigate; ChatScreen handles enterConversation on initState
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatScreen(
        receiverName: provider.name,
        receiverId:   provider.userId,
        receiverAvatar: provider.localImage,
        isProvider:   false,
      ),
    ));
  }

  void _doShare(pm.ServiceProvider p) {
    Share.share(
      '📅 Check out ${p.name} on HayaBook!\n'
      '⭐ ${p.rating.toStringAsFixed(1)} · ${p.category}\n'
      '📍 ${p.location}\n'
      '📞 ${p.phone}\n\n'
      'Book them now on the HayaBook App!',
      subject: 'Book ${p.name} on HayaBook'
    );
  }


  String _specialtyFor(pm.ServiceProvider p) {
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

  Widget _buildSectionCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = _p;
    if (provider == null) {
      return const Scaffold(body: Center(child: Text('Provider not found')));
    }

    final displayName     = provider.name;
    final displayBio      = provider.bio;
    final displayLoc      = provider.location;
    final displayLogo     = provider.imageUrl; // Use remote imageUrl instead of local File
    final displayPortfolio = provider.portfolio.map((e) => e.url).toList(); // Use remote urls from the model

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
                        logoUrl:        displayLogo,
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
                        rating:      provider.rating,
                        reviewCount: provider.reviewCount,
                        category:    provider.category,
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ── About ──────────────────────
                            _buildSectionCard(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionLabel('About'),
                                  const SizedBox(height: 12),
                                  Text(displayBio,
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize:   14,
                                          color:      AppColors.textMuted,
                                          height:     1.65)),
                                ],
                              ),
                            ),

                            // ── Portfolio — ALWAYS visible ─
                            _buildSectionCard(_PortfolioSection(photos: displayPortfolio)),

                            // ── Services ───────────────────
                            _buildSectionCard(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionLabel('Services'),
                                  const SizedBox(height: 16),
                                  if (provider.services.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Text('No services listed.',
                                          style: TextStyle(color: AppColors.textMuted)),
                                    )
                                  else
                                    ...provider.services.map((s) => Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                                color: Colors.grey.withOpacity(0.08)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(s.name,
                                                        style: const TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15,
                                                            color: AppColors.textDark)),
                                                    if (s.description.isNotEmpty) ...[
                                                      const SizedBox(height: 4),
                                                      Text(s.description,
                                                          style: const TextStyle(
                                                              fontFamily: 'Inter',
                                                              color: AppColors.textMuted,
                                                              fontSize: 13,
                                                              height: 1.4)),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text('\$${s.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 16)),
                                            ],
                                          ),
                                        )),
                                ],
                              ),
                            ),

                            // ── Location ───────────────────
                            _buildSectionCard(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionLabel('Location'),
                                  const SizedBox(height: 16),
                                  _LocationSection(addressText: displayLoc),
                                ],
                              ),
                            ),

                            // ── Reviews ────────────────────
                            _buildSectionCard(_ReviewsSection(provider: provider)),
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
  final List<String> photos;
  const _PortfolioSection({required this.photos});
  @override
  State<_PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<_PortfolioSection> {

  @override
  Widget build(BuildContext context) {
    final hasPhotos = widget.photos.isNotEmpty;

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

      // ── Photos carousel ───────────────────────────────────────
      if (hasPhotos)
        SizedBox(
          height: 180, // Height of the modern carousel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.photos.length,
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _openViewer(context, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 140,
                      child: Image.network(
                        AppConfig.getMediaUrl(widget.photos[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )

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
  final List<String> photos;
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
                child: Image.network(AppConfig.getMediaUrl(widget.photos[i]), fit: BoxFit.contain)),
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
  final pm.ServiceProvider provider;
  final String          displayName;
  final String          specialtyLabel;
  final bool            isFav;
  final String          logoUrl;
  final VoidCallback    onBack, onShare, onChat, onFavToggle;

  const _HeroSection({
    required this.provider,
    required this.displayName,
    required this.specialtyLabel,
    required this.isFav,
    required this.logoUrl,
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
                        child: HayaAvatar(
                          avatarUrl:    logoUrl,
                          size:         88,
                          borderRadius: 99,
                          isProvider:   true,
                        ),
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
// LOCATION SECTION
// ══════════════════════════════════════════════════════════════
class _LocationSection extends StatelessWidget {
  final String addressText;
  const _LocationSection({required this.addressText});

  void _openInMaps() async {
    final query = Uri.encodeComponent(addressText);
    // Universal maps search URI
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(children: [
          const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(addressText,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w500, color: AppColors.textDark))),
        ]),
      ),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: _openInMaps,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
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
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.location_on,
                          color: AppColors.primary, size: 28),
                    ),
                    Container(width: 3, height: 12, color: Colors.white),
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle),
                    ),
                  ],
                )),
              ]),
            ),
            
            // "Open in Maps" floating button
            Positioned(
              bottom: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 4),
                  )],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Open in Maps', style: TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w700,
                      color: Colors.white, fontSize: 12
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ]);
  }
}


// ══════════════════════════════════════════════════════════════
// REVIEWS SECTION
// ══════════════════════════════════════════════════════════════
class _ReviewsSection extends StatelessWidget {
  final pm.ServiceProvider provider;
  const _ReviewsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final reviews = provider.reviews;
    final hasReviews = reviews.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SectionLabel('Reviews'),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ReviewsScreen(
                      providerName: provider.name, providerId: provider.id),
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text('+ ADD REVIEW',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w800, letterSpacing: 0.5,
                          color: AppColors.primary)),
                ),
              ),
              if (hasReviews) ...[
                const SizedBox(width: 12),
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
              ]
            ],
          ),

        ],
      ),
      const SizedBox(height: 14),
      if (!hasReviews)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text('No reviews yet. Be the first to review!',
                style: TextStyle(fontFamily: 'Inter', color: AppColors.textMuted)),
          ),
        )
      else
        ...reviews.take(3).map((r) => _ReviewCard(review: r)),
    ]);
  }
}

class _ReviewCard extends StatelessWidget {
  final pm.Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: ClipOval(
              child: review.userImage.isNotEmpty
                  ? Image.network(AppConfig.getMediaUrl(review.userImage), fit: BoxFit.cover)
                  : Center(child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w700, color: AppColors.primary))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.userName,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(_formatTimeAgo(review.createdAt),
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                      color: AppColors.textMuted)),
            ],
          )),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text('${review.rating}', style: const TextStyle(fontFamily: 'Inter',
                fontSize: 13, fontWeight: FontWeight.w700,
                color: Color(0xFFF59E0B))),
            const SizedBox(width: 3),
            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
          ]),
        ]),
        const SizedBox(height: 8),
        Text(review.comment,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontStyle: FontStyle.italic, color: AppColors.textMuted,
                height: 1.5)),
      ]),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'just now';
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