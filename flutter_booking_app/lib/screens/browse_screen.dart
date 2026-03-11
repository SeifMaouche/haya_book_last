import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../models/provider_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'location_picker.dart';
import '../widgets/glass_kit.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _selectedCategory = 'All';
  String _location = 'Algiers, Algeria';

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Clinics', 'icon': Icons.medical_services_outlined},
    {'label': 'Salons', 'icon': Icons.content_cut},
    {'label': 'Tutors', 'icon': Icons.school_outlined},
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
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String? get _apiCategory {
    switch (_selectedCategory) {
      case 'Clinics':
        return 'Clinic';
      case 'Salons':
        return 'Salon';
      case 'Tutors':
        return 'Tutor';
      default:
        return null;
    }
  }

  void _applyFilters() {
    final q = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();
    Provider.of<BookingProvider>(context, listen: false)
        .fetchProviders(category: _apiCategory, searchQuery: q);
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
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => LocationPickerSheet(
        currentLocation: _location,
        onSelected: (city) => Navigator.pop(context, city),
      ),
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FiltersSheet(),
    );
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
                  // Logo
                  Container(
                    width: 38,
                    height: 38,
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
                  // Notification button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.cardBorder, width: 1.5),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: AppColors.textDark, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Location pill
              GestureDetector(
                onTap: _changeLocation,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: AppColors.cardBorder, width: 1.5),
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

              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border:
                  Border.all(color: AppColors.cardBorder, width: 1.5),
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
                    // Filter button
                    GestureDetector(
                      onTap: _showFilters,
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 4,
                                offset: const Offset(0, 1))
                          ],
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: AppColors.primary, size: 18),
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
          children: _categories.map((cat) {
            final label = cat['label'] as String;
            final icon = cat['icon'] as IconData;
            final selected = _selectedCategory == label;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory =
                  selected ? 'All' : label);
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
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
                          color: selected
                              ? AppColors.primary
                              : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(label,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.textDark
                                  : AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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
              const Text('Featured Providers',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              GestureDetector(
                onTap: () {},
                child: Text('VIEW ALL',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildProviderCard(
      BuildContext context, ServiceProvider provider) {
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
          border: Border.all(
              color: Colors.white.withOpacity(0.6), width: 1),
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
            // Photo with rating badge
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      provider.localImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 10, color: Colors.white),
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

            // Name
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

            // Book Now
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
            child: const Icon(Icons.search_off,
                size: 36, color: AppColors.primary),
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
        ],
      ),
    );
  }
}

// ── Filters Bottom Sheet ──────────────────────────────────────
class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet();

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String _sortBy = 'Nearest';
  String _category = 'Clinics';
  String _rating = '4.0+';
  double _distance = 0.6; // 0..1 maps to 1..20
  RangeValues _priceRange = const RangeValues(500, 10000);

  int get _distanceKm => (1 + _distance * 19).round();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                // Header
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius:
                            BorderRadius.circular(99),
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
                        onTap: () => setState(() {
                          _sortBy = 'Nearest';
                          _category = 'Clinics';
                          _rating = '4.0+';
                          _distance = 0.6;
                          _priceRange =
                          const RangeValues(500, 10000);
                        }),
                        child: Text('Reset',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            )),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    children: [
                      // Sort By
                      _filterLabel('SORT BY'),
                      const SizedBox(height: 10),
                      _chipGroup(
                        ['Nearest', 'Top Rated', 'Most Booked'],
                        _sortBy,
                            (v) => setState(() => _sortBy = v),
                      ),
                      const SizedBox(height: 24),

                      // Category
                      _filterLabel('CATEGORY'),
                      const SizedBox(height: 10),
                      _chipGroup(
                        ['Clinics', 'Salons', 'Tutors'],
                        _category,
                            (v) => setState(() => _category = v),
                      ),
                      const SizedBox(height: 24),

                      // Rating
                      _filterLabel('RATING'),
                      const SizedBox(height: 10),
                      Row(
                        children: ['4.5+', '4.0+', '3.5+']
                            .map((r) {
                          final sel = r == _rating;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _rating = r),
                              child: Container(
                                margin: const EdgeInsets.only(
                                    right: 8),
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.primaryLight,
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: sel
                                      ? null
                                      : Border.all(
                                      color: AppColors.primary
                                          .withOpacity(0.2)),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        color: sel
                                            ? Colors.white
                                            : AppColors.primary,
                                        size: 20),
                                    const SizedBox(height: 4),
                                    Text(r,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.w700,
                                          color: sel
                                              ? Colors.white
                                              : AppColors.primary,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Distance
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _filterLabel('DISTANCE'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                              BorderRadius.circular(99),
                            ),
                            child: Text(
                              'Up to $_distanceKm km',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _distance,
                        onChanged: (v) =>
                            setState(() => _distance = v),
                        activeColor: AppColors.primary,
                        inactiveColor:
                        AppColors.primary.withOpacity(0.2),
                        thumbColor: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1km',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: AppColors.textMuted)),
                            Text('20km',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price Range
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _filterLabel('PRICE RANGE'),
                          Text(
                            'DZD ${_priceRange.start.round()} - ${_priceRange.end.round()}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _priceBox(
                                'MIN',
                                'DZD ${_priceRange.start.round()}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Container(
                              width: 20,
                              height: 1,
                              color: AppColors.primary
                                  .withOpacity(0.3),
                            ),
                          ),
                          Expanded(
                            child: _priceBox(
                                'MAX',
                                'DZD ${_priceRange.end.round()}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 20000,
                        divisions: 40,
                        activeColor: AppColors.primary,
                        inactiveColor:
                        AppColors.primary.withOpacity(0.2),
                        onChanged: (v) =>
                            setState(() => _priceRange = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Apply button pinned to bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
                  onPressed: () => Navigator.pop(context),
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

  Widget _filterLabel(String label) {
    return Text(label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1,
        ));
  }

  Widget _chipGroup(
      List<String> items, String selected, ValueChanged<String> onSel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final sel = item == selected;
        return GestureDetector(
          onTap: () => onSel(item),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(99),
              border: sel
                  ? null
                  : Border.all(
                  color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(item,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                  sel ? Colors.white : AppColors.primary,
                )),
          ),
        );
      }).toList(),
    );
  }

  Widget _priceBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
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
}