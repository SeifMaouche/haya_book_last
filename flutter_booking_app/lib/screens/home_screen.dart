// lib/screens/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../providers/notification_provider.dart';
import '../models/provider_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/glass_kit.dart';
import 'location_picker.dart';
import '../widgets/haya_avatar.dart';
import '../providers/chat_provider.dart';
import '../models/global_search_result.dart';
import '../services/provider_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _location = 'Algiers, Algeria';

  // Dynamic categories will be fetched from BookingProvider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadData();
    });
  }

  void _preloadData() {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    final np = Provider.of<NotificationProvider>(context, listen: false);
    final cp = Provider.of<ChatProvider>(context, listen: false);

    // Initial data refresh
    bp.fetchProviders();       // Refresh provider list
    bp.fetchUserBookings();    // Populate the 'Upcoming' section
    bp.initSocket();           // Connect to real-time booking updates
    np.fetchNotifications();   // Sync notification unread count
    cp.fetchMyConversations(); // Sync chat conversations
    cp.initSocket();           // Connect to real-time messaging
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

  Map<String, dynamic> _getCategoryStyle(String catName) {
    final lower = catName.toLowerCase();
    
    if (lower.contains('barber') || lower.contains('coiffure')) {
      return {
        'icon': Icons.content_cut_rounded,
        'grad': [const Color(0xFFFF8A65), const Color(0xFFE53935)],
        'image': 'assets/images/salon.png'
      };
    }
    if (lower.contains('esthétique') || lower.contains('beauty') || lower.contains('salon')) {
      return {
        'icon': Icons.face_retouching_natural_rounded,
        'grad': [const Color(0xFFF472B6), const Color(0xFFDB2777)],
        'image': 'assets/images/salon.png'
      };
    }
    if (lower.contains('déménagement') || lower.contains('transport') || lower.contains('shipping')) {
      return {
        'icon': Icons.local_shipping_rounded,
        'grad': [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
        'image': 'assets/images/doc.png'
      };
    }
    if (lower.contains('garde') || lower.contains('enfant') || lower.contains('child')) {
      return {
        'icon': Icons.child_care_rounded,
        'grad': [const Color(0xFFFCD34D), const Color(0xFFD97706)],
        'image': 'assets/images/tutop.png'
      };
    }
    if (lower.contains('lavage') || lower.contains('wash')) {
      return {
        'icon': Icons.local_car_wash_rounded,
        'grad': [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
        'image': 'assets/images/doc.png'
      };
    }
    if (lower.contains('mécanique') || lower.contains('auto') || lower.contains('car')) {
      return {
        'icon': Icons.build_circle_rounded,
        'grad': [const Color(0xFF9CA3AF), const Color(0xFF4B5563)],
        'image': 'assets/images/doc.png'
      };
    }
    if (lower.contains('nettoyage') || lower.contains('ménage') || lower.contains('clean')) {
      return {
        'icon': Icons.cleaning_services_rounded,
        'grad': [const Color(0xFF34D399), const Color(0xFF059669)],
        'image': 'assets/images/salon.png'
      };
    }
    if (lower.contains('fête') || lower.contains('celebration') || lower.contains('event')) {
      return {
        'icon': Icons.celebration_rounded,
        'grad': [const Color(0xFFA78BFA), const Color(0xFF7C3AED)],
        'image': 'assets/images/salon.png'
      };
    }
    if (lower.contains('photo') || lower.contains('vidéo') || lower.contains('camera')) {
      return {
        'icon': Icons.camera_alt_rounded,
        'grad': [const Color(0xFFF87171), const Color(0xFFDC2626)],
        'image': 'assets/images/tutop.png'
      };
    }
    if (lower.contains('plomb') || lower.contains('chauffage')) {
      return {
        'icon': Icons.plumbing_rounded,
        'grad': [const Color(0xFF93C5FD), const Color(0xFF1D4ED8)],
        'image': 'assets/images/doc.png'
      };
    }
    if (lower.contains('répar') || lower.contains('électroménager') || lower.contains('fix')) {
      return {
        'icon': Icons.settings_suggest_rounded,
        'grad': [const Color(0xFF818CF8), const Color(0xFF4338CA)],
        'image': 'assets/images/doc.png'
      };
    }
    
    // Existing English fallbacks
    if (lower.contains('clinic') || lower.contains('doc') || lower.contains('health')) {
      return {
        'icon': Icons.medication_liquid_rounded,
        'grad': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        'image': 'assets/images/doc.png'
      };
    }
    if (lower.contains('tutor') || lower.contains('prof') || lower.contains('learn')) {
      return {
        'icon': Icons.psychology_alt_rounded,
        'grad': [const Color(0xFF7C83FF), const Color(0xFF5152CC)],
        'image': 'assets/images/tutop.png'
      };
    }
    if (lower.contains('spa') || lower.contains('wellness')) {
      return {
        'icon': Icons.spa_rounded,
        'grad': [const Color(0xFF10B981), const Color(0xFF059669)],
        'image': 'assets/images/salon.png'
      };
    }
    if (lower.contains('fit') || lower.contains('gym') || lower.contains('sport')) {
      return {
        'icon': Icons.bolt_rounded,
        'grad': [const Color(0xFFF97316), const Color(0xFFEA580C)],
        'image': 'assets/images/tutop.png'
      };
    }
    
    // Default
    return {
      'icon': Icons.category_rounded,
      'grad': [const Color(0xFF94A3B8), const Color(0xFF64748B)],
      'image': 'assets/images/doc.png'
    };
  }

  List<Color> _gradientFor(String cat) => _getCategoryStyle(cat)['grad'];

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
                Consumer<NotificationProvider>(builder: (_, np, __) {
                  final n = np.unreadCount;
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
                            child: Center(child: Text(n > 9 ? '9+' : '$n',
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
                location: _location,
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Consumer<BookingProvider>(builder: (context, bp, _) {
      final cats = bp.categories;
      if (cats.isEmpty && bp.isLoading) {
        return const Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ));
      }
      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: cats.length,
          itemBuilder: (context, i) {
            final category = cats[i];
            final style = _getCategoryStyle(category.name);
            
            return _GlassCategoryTile(
              label: category.name,
              icon:  style['icon'] as IconData,
              gradient: style['grad'] as List<Color>,
              onTap: () {
                bp.fetchProviders(category: category.name);
                Navigator.pushNamed(context, '/browse', arguments: {'category': category.name});
              },
            );
          },
        ),
      );
    });
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
          // Provider Image / Icon
          HayaAvatar(
            avatarUrl:    booking.providerAvatar,
            size:         42,
            borderRadius: 12,
            isProvider:   true,
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
        height: 250, // Increased to fix bottom overflow
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8), // Zero horizontal to align with headers
          itemCount: bp.providers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (ctx, i) => _providerCard(ctx, bp.providers[i]),
        ),
      );
    });
  }

  Widget _providerCard(BuildContext context, ServiceProvider p) {
    return ScaleTap(
      onTap: () {
        Provider.of<BookingProvider>(context, listen: false).selectProvider(p);
        Navigator.pushNamed(context, '/provider', arguments: {'provider': p});
      },
      child: Container(
        width: 175, // Increased width for better impact
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── Avatar ──
            HayaAvatar(
              avatarUrl:    p.imageUrl,
              size:         68,
              borderRadius: 99,
              isProvider:   true,
            ),
            const SizedBox(height: 12),
            
            // ── Info ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w800, color: AppColors.textDark,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.category.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 8,
                      fontWeight: FontWeight.w800, color: AppColors.primary.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // ── Rating ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        '${p.rating}',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w700, color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            // ── Action Button (Bigger) ──
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Text('Book Now',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ══════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final String location;

  const _SearchBar({required this.controller, required this.onSearch, required this.location});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  
  List<GlobalSearchResult> _results = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) async {
    if (text.trim().length < 2) {
      setState(() { _results = []; _isLoading = false; });
      _overlayEntry?.markNeedsBuild();
      return;
    }
    
    setState(() => _isLoading = true);
    _overlayEntry?.markNeedsBuild();

    try {
      final res = await ProviderService().globalSearch(
        query: text,
        city: widget.location,
      );
      if (mounted) {
        setState(() {
          _results = res;
          _isLoading = false;
        });
        _overlayEntry?.markNeedsBuild();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: _buildDropdown(),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  Widget _buildDropdown() {
    if (widget.controller.text.trim().length < 2) {
      return const SizedBox.shrink();
    }
    if (_isLoading && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
      );
    }
    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No providers or services found.', style: TextStyle(fontFamily: 'Inter', color: AppColors.textMuted, fontSize: 13)),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _results.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.cardBorder),
        itemBuilder: (context, i) {
          final res = _results[i];
          final p = res.provider;
          final isService = res.type == 'service' && res.service != null;
          
          return InkWell(
            onTap: () {
              _focusNode.unfocus();
              widget.controller.clear();
              Provider.of<BookingProvider>(context, listen: false).selectProvider(p);
              Navigator.pushNamed(context, '/provider', arguments: {'provider': p});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  HayaAvatar(
                    avatarUrl: p.imageUrl,
                    size: 40,
                    borderRadius: 8,
                    isProvider: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isService ? res.service!.name : p.name,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isService ? 'Service by ${p.name}' : p.category,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textLight),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, color: AppColors.textLight, size: 19),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: _onTextChanged,
              onSubmitted: (_) { 
                 _focusNode.unfocus();
                 widget.onSearch();
              },
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText: 'Search providers, services...',
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textLight),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 13),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
               _focusNode.unfocus();
               widget.onSearch();
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              width: 36, height: 36,
              decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GLASS CATEGORY TILE
// ══════════════════════════════════════════════════════════════
class _GlassCategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GlassCategoryTile({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: ScaleTap(
        onTap: onTap,
        child: Container(
          width: 105, // Increased width for better text visibility
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Bubble
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark.withOpacity(0.9),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
