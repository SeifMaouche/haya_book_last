import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../models/provider_model.dart';
import '../models/category_model.dart' as cat;
import '../widgets/bottom_nav_bar.dart';
import 'location_picker.dart';
import '../widgets/glass_kit.dart';
import '../widgets/haya_avatar.dart';
import '../providers/notification_provider.dart';
import 'package:geolocator/geolocator.dart';

// ── Filter state shared between the main screen and the filter sheet ──
class _FilterState {
  String sortBy;
  String category;       // 'All' or a category name
  double minRating;      // 0 = no filter
  double maxPrice;       // 0 = no filter (unlimited)
  int maxDistanceKm;     // 0 = no filter; > 0 = max km
  double? userLat;
  double? userLng;

  _FilterState({
    this.sortBy      = 'default',
    this.category    = 'All',
    this.minRating   = 0,
    this.maxPrice    = 0,
    this.maxDistanceKm = 0,
    this.userLat,
    this.userLng,
  });

  _FilterState copyWith({
    String? sortBy,
    String? category,
    double? minRating,
    double? maxPrice,
    int? maxDistanceKm,
    double? userLat,
    double? userLng,
  }) =>
      _FilterState(
        sortBy:          sortBy          ?? this.sortBy,
        category:        category        ?? this.category,
        minRating:       minRating       ?? this.minRating,
        maxPrice:        maxPrice        ?? this.maxPrice,
        maxDistanceKm:   maxDistanceKm   ?? this.maxDistanceKm,
        userLat:         userLat         ?? this.userLat,
        userLng:         userLng         ?? this.userLng,
      );

  /// How many non-default filter values are active
  int get activeCount {
    int n = 0;
    if (sortBy != 'default') n++;
    if (category != 'All') n++;
    if (minRating > 0) n++;
    if (maxPrice > 0) n++;
    if (maxDistanceKm > 0) n++;
    return n;
  }
}

// ────────────────────────────────────────────────────────────────────────
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _location    = 'Algiers, Algeria';
  _FilterState _filter = _FilterState();

  List<cat.Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bp  = Provider.of<BookingProvider>(context, listen: false);
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      String? initCategory;
      if (args != null && args.containsKey('category')) {
        initCategory = args['category'] as String;
        setState(() => _filter = _filter.copyWith(category: initCategory ?? 'All'));
      } else if (bp.currentCategory != null) {
        initCategory = bp.currentCategory;
        setState(() => _filter = _filter.copyWith(category: initCategory ?? 'All'));
      }

      if (bp.providers.isEmpty) {
        _applyFilters();
      }
      _fetchCategories();
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final bp = Provider.of<BookingProvider>(context, listen: false);
      if (bp.categories.isEmpty) await bp.fetchCategories();
      if (mounted) {
        setState(() {
          _categories         = bp.categories;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Build the full fetchProviders call using current filter state ──
  void _applyFilters({_FilterState? newFilter}) {
    final f = newFilter ?? _filter;
    if (newFilter != null) setState(() => _filter = newFilter);

    final q = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();

    // NOTE: _location (the location pill) is a UI context indicator — it is NOT sent as
    // an address filter. It is only used as the reference position for distance sorting
    // when the user explicitly enables the distance toggle AND GPS has been acquired.
    // Without this fix, every query would silently filter by city address.
    final bool distanceActive = f.maxDistanceKm > 0 && f.userLat != null && f.userLng != null;

    Provider.of<BookingProvider>(context, listen: false).fetchProviders(
      category:      f.category == 'All' ? null : f.category,
      searchQuery:   q,
      minRating:     f.minRating > 0 ? f.minRating : null,
      maxPrice:      f.maxPrice  > 0 ? f.maxPrice  : null,
      sortBy:        f.sortBy == 'default' ? null : f.sortBy,
      // Only pass GPS/distance params when the distance filter is actually on
      lat:           distanceActive ? f.userLat : null,
      lng:           distanceActive ? f.userLng : null,
      maxDistanceKm: distanceActive ? f.maxDistanceKm : null,
    );
  }


  void _onSearchTap() {
    _searchFocus.unfocus();
    _applyFilters();
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
    if (picked != null && mounted) {
      setState(() => _location = picked);
      _applyFilters(); // re-fetch with new city
    }
  }

  void _showFilters() async {
    final result = await showModalBottomSheet<_FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(
        initial:    _filter,
        categories: _categories,
        location:   _location,
      ),
    );
    if (result != null && mounted) {
      _applyFilters(newFilter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryBar(),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (_, bp, __) {
                if (bp.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2));
                }
                if (bp.providers.isEmpty) return _buildEmpty();
                return _buildProviderGrid(bp.providers);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (i) => navigateToTab(context, i),
      ),
    );
  }

  Widget _buildHeader() {
    final activeFilters = _filter.activeCount;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.book_online_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('HayaBook',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      )),
                  const Spacer(),
                  // Notification badge
                  Consumer<NotificationProvider>(builder: (_, np, __) {
                    final n = np.unreadCount;
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/notifications'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardBorder, width: 1.5),
                              color: Colors.white,
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: AppColors.textDark, size: 20),
                          ),
                          if (n > 0)
                            Positioned(
                              top: -2, right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: AppColors.secondary, shape: BoxShape.circle),
                                constraints:
                                    const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Center(
                                  child: Text(n > 9 ? '9+' : '$n',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // Location pill
              GestureDetector(
                onTap: _changeLocation,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _location.split(',').first,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textMuted, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Search bar + Filter button
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 1))
                  ],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Icon(Icons.search,
                          color: AppColors.textLight, size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onSubmitted: (_) => _onSearchTap(),
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textDark),
                        decoration: const InputDecoration(
                          hintText: 'Search providers...',
                          hintStyle: TextStyle(
                              color: AppColors.textLight, fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    // Filter button — shows badge when active
                    GestureDetector(
                      onTap: _showFilters,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: activeFilters > 0
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1))
                              ],
                            ),
                            child: Icon(Icons.tune_rounded,
                                color: activeFilters > 0
                                    ? Colors.white
                                    : AppColors.primary,
                                size: 18),
                          ),
                          if (activeFilters > 0)
                            Positioned(
                              top: -4,
                              right: 1,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    '$activeFilters',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryPill('All', Icons.apps_rounded, _filter.category == 'All'),
            if (_isLoadingCategories)
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)))
            else
              ..._categories.map((c) {
                final label  = c.name;
                final sel    = _filter.category == label;
                IconData icon = Icons.business_outlined;
                final l = label.toLowerCase();
                if (l.contains('barber') || l.contains('coiffure'))
                  icon = Icons.content_cut_rounded;
                else if (l.contains('esthétique') || l.contains('beauty') || l.contains('salon'))
                  icon = Icons.face_retouching_natural_rounded;
                else if (l.contains('déménagement') || l.contains('transport') || l.contains('shipping'))
                  icon = Icons.local_shipping_rounded;
                else if (l.contains('garde') || l.contains('enfant') || l.contains('child'))
                  icon = Icons.child_care_rounded;
                else if (l.contains('lavage') || l.contains('wash'))
                  icon = Icons.local_car_wash_rounded;
                else if (l.contains('mécanique') || l.contains('auto') || l.contains('car'))
                  icon = Icons.build_circle_rounded;
                else if (l.contains('nettoyage') || l.contains('ménage') || l.contains('clean'))
                  icon = Icons.cleaning_services_rounded;
                else if (l.contains('fête') || l.contains('celebration') || l.contains('event'))
                  icon = Icons.celebration_rounded;
                else if (l.contains('photo') || l.contains('vidéo') || l.contains('camera'))
                  icon = Icons.camera_alt_rounded;
                else if (l.contains('plomb') || l.contains('chauffage'))
                  icon = Icons.plumbing_rounded;
                else if (l.contains('répar') || l.contains('électroménager') || l.contains('fix'))
                  icon = Icons.settings_suggest_rounded;
                else if (l.contains('tutor') || l.contains('edu'))
                  icon = Icons.school_outlined;
                else if (l.contains('fit') || l.contains('gym') || l.contains('sport'))
                  icon = Icons.fitness_center;
                else if (l.contains('legal') || l.contains('law'))
                  icon = Icons.gavel_outlined;
                else if (l.contains('clinic') || l.contains('health') || l.contains('medical'))
                  icon = Icons.medical_services_outlined;

                return _buildCategoryPill(label, icon, sel);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, IconData icon, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          final newCat = selected ? 'All' : label;
          setState(() => _filter = _filter.copyWith(category: newCat));
          _applyFilters();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.textDark : AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderGrid(List<ServiceProvider> providers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${providers.length} Provider${providers.length == 1 ? '' : 's'} Found',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
              ),
              if (_filter.activeCount > 0)
                GestureDetector(
                  onTap: () {
                    setState(() => _filter = _FilterState());
                    _applyFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text('Clear Filters',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: providers.length,
            itemBuilder: (ctx, i) => FadeSlide(
              delay: Duration(milliseconds: 60 + i * 60),
              child: _buildProviderCard(ctx, providers[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, ServiceProvider provider) {
    return ScaleTap(
      onTap: () {
        Provider.of<BookingProvider>(context, listen: false)
            .selectProvider(provider);
        Navigator.pushNamed(context, '/provider',
            arguments: {'provider': provider});
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.white.withOpacity(0.6), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: HayaAvatar(
                    avatarUrl:    provider.imageUrl,
                    size:         80,
                    borderRadius: 99,
                    isProvider:   true,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 10, color: Colors.white),
                        const SizedBox(width: 2),
                        Text('${provider.rating}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              provider.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              provider.category,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<BookingProvider>(context, listen: false)
                      .selectProvider(provider);
                  Navigator.pushNamed(context, '/booking');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.search_off, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          const Text('No providers found',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('Try adjusting your search or filters',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textMuted)),
          if (_filter.activeCount > 0) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() => _filter = _FilterState());
                _applyFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text('Clear All Filters',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Filters Bottom Sheet ─────────────────────────────────────────────
class _FiltersSheet extends StatefulWidget {
  final _FilterState initial;
  final List<cat.Category> categories;
  final String location;

  const _FiltersSheet({
    required this.initial,
    required this.categories,
    required this.location,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String   _sortBy;
  late String   _category;
  late double   _minRating;
  late double   _maxPrice;    // 0 = off
  late int      _maxDistanceKm;
  double?       _userLat;
  double?       _userLng;
  bool          _locating = false;
  String?       _gpsError;

  // Slider raw values
  late double _distanceSlider; // 0..1 → 1..50 km
  late double _priceSlider;    // 0..20000 DZD

  @override
  void initState() {
    super.initState();
    final f        = widget.initial;
    _sortBy        = f.sortBy;
    _category      = f.category;
    _minRating     = f.minRating;
    _maxPrice      = f.maxPrice;
    _maxDistanceKm = f.maxDistanceKm;
    _userLat       = f.userLat;
    _userLng       = f.userLng;

    // Map stored values back to slider positions
    _distanceSlider = _maxDistanceKm > 0
        ? ((_maxDistanceKm - 1) / 49.0).clamp(0.0, 1.0)
        : 0.6;
    _priceSlider    = _maxPrice > 0 ? _maxPrice : 10000;
  }

  int    get _distanceKmDisplay => (1 + _distanceSlider * 49).round();
  double get _maxPriceDisplay   => _priceSlider;

  Future<void> _getGps() async {
    setState(() { _locating = true; _gpsError = null; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() { _gpsError = 'GPS is off. Enable Location Services.'; _locating = false; });
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() { _gpsError = 'Location permission denied.'; _locating = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );
      setState(() {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
        _locating = false;
        _gpsError = null;
      });
    } catch (_) {
      setState(() { _gpsError = 'Could not get location. Try again.'; _locating = false; });
    }
  }

  void _reset() => setState(() {
    _sortBy        = 'default';
    _category      = 'All';
    _minRating     = 0;
    _maxPrice      = 0;
    _maxDistanceKm = 0;
    _distanceSlider = 0.6;
    _priceSlider    = 10000;
    _userLat        = null;
    _userLng        = null;
    _gpsError       = null;
  });

  void _apply() {
    // Persist slider values as real filter values
    final effectiveMaxPrice = _maxPrice > 0 ? _maxPriceDisplay : 0.0;
    final effectiveDist     = _maxDistanceKm > 0 ? _distanceKmDisplay : 0;

    Navigator.pop(
      context,
      _FilterState(
        sortBy:          _sortBy,
        category:        _category,
        minRating:       _minRating,
        maxPrice:        effectiveMaxPrice,
        maxDistanceKm:   effectiveDist,
        userLat:         _userLat,
        userLng:         _userLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool distanceEnabled = _maxDistanceKm > 0;
    final bool priceEnabled    = _maxPrice > 0;

    // Build sort options
    const sortOptions = [
      {'key': 'default',    'label': 'Default',      'icon': Icons.sort},
      {'key': 'rating',     'label': 'Top Rated',    'icon': Icons.star_rounded},
      {'key': 'most_booked','label': 'Most Booked',  'icon': Icons.trending_up},
      {'key': 'price_asc',  'label': 'Price: Low–High','icon': Icons.attach_money},
      {'key': 'distance',   'label': 'Nearest First', 'icon': Icons.near_me},
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.97,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // ── Handle ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Icon(Icons.close,
                              color: AppColors.primary, size: 18),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('Filters',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark)),
                        ),
                      ),
                      GestureDetector(
                        onTap: _reset,
                        child: const Text('Reset',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // ── Scrollable content ───────────────────────────────
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    children: [

                      // ══ SORT BY ════════════════════════════════════
                      _sectionLabel('SORT BY'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: sortOptions.map((opt) {
                          final key   = opt['key'] as String;
                          final label = opt['label'] as String;
                          final icon  = opt['icon'] as IconData;
                          final sel   = _sortBy == key;
                          // Disable "Nearest First" if no GPS
                          final disabled = key == 'distance' && _userLat == null;
                          return GestureDetector(
                            onTap: disabled ? null : () => setState(() => _sortBy = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: disabled
                                    ? const Color(0xFFF1F5F9)
                                    : sel
                                        ? AppColors.primary
                                        : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(99),
                                border: sel
                                    ? null
                                    : Border.all(color: disabled
                                        ? Colors.grey.shade300
                                        : AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon,
                                      size: 14,
                                      color: disabled
                                          ? AppColors.textMuted
                                          : sel ? Colors.white : AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(label,
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: disabled
                                              ? AppColors.textMuted
                                              : sel ? Colors.white : AppColors.primary)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ══ CATEGORY ═══════════════════════════════════
                      _sectionLabel('CATEGORY'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          _categoryChip('All'),
                          ...widget.categories.map((c) => _categoryChip(c.name)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ══ MINIMUM RATING ════════════════════════════
                      _sectionLabel('MINIMUM RATING'),
                      const SizedBox(height: 10),
                      Row(
                        children: [0.0, 3.5, 4.0, 4.5].map((r) {
                          final label = r == 0 ? 'Any' : '${r}+';
                          final sel   = _minRating == r;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _minRating = r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.primary : AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                  border: sel
                                      ? null
                                      : Border.all(color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(r == 0 ? Icons.star_border : Icons.star_rounded,
                                        color: sel ? Colors.white : AppColors.primary,
                                        size: 20),
                                    const SizedBox(height: 4),
                                    Text(label,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: sel ? Colors.white : AppColors.primary,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ══ DISTANCE ══════════════════════════════════
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel('DISTANCE'),
                          // Toggle switch
                          Row(
                            children: [
                              Text(
                                distanceEnabled ? 'Up to $_distanceKmDisplay km' : 'Off',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: distanceEnabled ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                  if (distanceEnabled) {
                                    _maxDistanceKm = 0;
                                  } else {
                                    _maxDistanceKm = _distanceKmDisplay;
                                    if (_userLat == null) _getGps();
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: distanceEnabled
                                        ? AppColors.primary
                                        : AppColors.cardBorder,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: distanceEnabled
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // GPS status row
                      if (distanceEnabled) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _locating ? null : _getGps,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _userLat != null
                                  ? const Color(0xFFECFDF5)
                                  : _gpsError != null
                                      ? const Color(0xFFFEF2F2)
                                      : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _userLat != null
                                      ? const Color(0xFF10B981)
                                      : _gpsError != null
                                          ? AppColors.error.withOpacity(0.3)
                                          : AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                _locating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: AppColors.primary))
                                    : Icon(
                                        _userLat != null
                                            ? Icons.my_location_rounded
                                            : _gpsError != null
                                                ? Icons.gps_off
                                                : Icons.location_searching_rounded,
                                        size: 16,
                                        color: _userLat != null
                                            ? const Color(0xFF10B981)
                                            : _gpsError != null
                                                ? AppColors.error
                                                : AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _locating
                                        ? 'Getting your location...'
                                        : _userLat != null
                                            ? 'GPS location acquired ✓  Tap to refresh'
                                            : _gpsError ?? 'Tap to get your GPS location',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _userLat != null
                                          ? const Color(0xFF10B981)
                                          : _gpsError != null
                                              ? AppColors.error
                                              : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          ),
                          child: Slider(
                            value: _distanceSlider,
                            onChanged: (v) => setState(() {
                              _distanceSlider = v;
                              _maxDistanceKm  = (1 + v * 49).round();
                            }),
                            activeColor:   AppColors.primary,
                            inactiveColor: AppColors.primary.withOpacity(0.2),
                            thumbColor: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1 km',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textMuted)),
                              Text('50 km',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ══ PRICE RANGE ════════════════════════════════
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel('MAX SERVICE PRICE'),
                          Row(
                            children: [
                              Text(
                                priceEnabled ? 'DZD ${_maxPriceDisplay.round()}' : 'Off',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: priceEnabled ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _maxPrice = priceEnabled ? 0 : _maxPriceDisplay;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40, height: 22,
                                  decoration: BoxDecoration(
                                    color: priceEnabled ? AppColors.primary : AppColors.cardBorder,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: priceEnabled
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        width: 18, height: 18,
                                        decoration: const BoxDecoration(
                                            color: Colors.white, shape: BoxShape.circle),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (priceEnabled) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _priceBox('MIN', 'DZD 0'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 20, height: 1,
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            Expanded(
                              child: _priceBox(
                                  'MAX', 'DZD ${_maxPriceDisplay.round()}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          ),
                          child: Slider(
                            value: _priceSlider,
                            min: 500,
                            max: 30000,
                            divisions: 59,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.primary.withOpacity(0.2),
                            thumbColor: Colors.white,
                            onChanged: (v) => setState(() {
                              _priceSlider = v;
                              _maxPrice    = v;
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('DZD 500',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textMuted)),
                              Text('DZD 30,000',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // ── Apply button pinned ──────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFF8F7FF).withOpacity(0),
                      const Color(0xFFF8F7FF),
                    ],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
                  label: const Text('Apply Filters',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String name) {
    final sel = _category == name;
    return GestureDetector(
      onTap: () => setState(() => _category = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(99),
          border: sel
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sel ? Colors.white : AppColors.primary,
            )),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      );

  Widget _priceBox(String label, String value) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                )),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                )),
          ],
        ),
      );
}