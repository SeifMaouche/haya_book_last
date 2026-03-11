// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/favorites_provider.dart';
import '../providers/booking_provider.dart';
import '../models/provider_model.dart';
import '../widgets/glass_kit.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selected = 'All';
  final _categories = ['All', 'Clinics', 'Salons', 'Tutors'];

  // Category meta — iOS 26 SF-symbol style
  static const Map<String, Map<String, dynamic>> _catMeta = {
    'Clinics': {
      'icon': Icons.health_and_safety_rounded,
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    },
    'Salons': {
      'icon': Icons.auto_fix_high_rounded,
      'gradient': [Color(0xFFFF8A65), Color(0xFFE53935)],
    },
    'Tutors': {
      'icon': Icons.menu_book_rounded,
      'gradient': [Color(0xFF7C83FF), Color(0xFF5152CC)],
    },
  };

  String? get _apiCat {
    switch (_selected) {
      case 'Clinics': return 'Clinic';
      case 'Salons':  return 'Salon';
      case 'Tutors':  return 'Tutor';
      default:        return null;
    }
  }

  List<Color> _gradientFor(String cat) {
    switch (cat) {
      case 'Salon': return const [Color(0xFFFF8A65), Color(0xFFE53935)];
      case 'Tutor': return const [Color(0xFF7C83FF), Color(0xFF5152CC)];
      default:      return const [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryBar(),
          const SizedBox(height: 4),
          Expanded(
            child: Consumer<FavoritesProvider>(builder: (_, fp, __) {
              final list = fp.getByCategory(_apiCat);
              if (list.isEmpty) return _buildEmpty();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: list.length,
                itemBuilder: (ctx, i) => FadeSlide(
                  delay: Duration(milliseconds: 60 + i * 70),
                  child: _card(ctx, list[i], fp),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── GRADIENT HEADER ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 22),
          child: FadeSlide(delay: Duration.zero, dy: 16, child:
          Row(children: [
            // Back
            GlassButton(
              size: 44,
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            // Title + subtitle
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Favorites',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 24,
                        fontWeight: FontWeight.w800, color: Colors.white,
                        letterSpacing: -0.5)),
                Text('Saved providers',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        color: Colors.white70)),
              ],
            )),
            // Heart icon accent
            GlassButton(
              size: 44,
              onTap: () {},
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ]),
          ),
        ),
      ),
    );
  }

  // ── CATEGORY BAR ─────────────────────────────────────────────
  Widget _buildCategoryBar() {
    return FadeSlide(delay: const Duration(milliseconds: 80), child:
    Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final sel = cat == _selected;
            final meta = _catMeta[cat];
            final grad = meta != null
                ? meta['gradient'] as List<Color>
                : [AppColors.primary, const Color(0xFF0A7A70)];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ScaleTap(
                onTap: () => setState(() => _selected = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? LinearGradient(colors: grad,
                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                    color: sel ? null : const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: sel
                        ? [BoxShadow(color: grad[0].withOpacity(0.30),
                        blurRadius: 10, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (meta != null) ...[
                      Icon(meta['icon'] as IconData,
                          size: 14,
                          color: sel ? Colors.white : AppColors.textMuted),
                      const SizedBox(width: 6),
                    ],
                    Text(cat,
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : AppColors.textMuted)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
    );
  }

  // ── PROVIDER CARD ────────────────────────────────────────────
  Widget _card(BuildContext context, ServiceProvider p, FavoritesProvider fp) {
    final grad = _gradientFor(p.category);
    final sub = p.category == 'Clinic'
        ? 'Medical Clinic'
        : p.category == 'Salon'
        ? 'Salon & Spa'
        : 'Education';

    return ScaleTap(
      onTap: () {
        Provider.of<BookingProvider>(context, listen: false).selectProvider(p);
        Navigator.pushNamed(context, '/provider', arguments: {'provider': p});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [BoxShadow(
              color: grad[0].withOpacity(0.08),
              blurRadius: 14, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Photo with gradient ring
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: grad,
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(
                      color: grad[0].withOpacity(0.28),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: ClipOval(child: Image.asset(p.localImage,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.3))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(p.name,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(sub,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w500, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text('${p.rating} (${p.reviewCount} reviews)',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                            color: AppColors.textMuted)),
                  ]),
                ],
              )),

              // Animated heart toggle
              ScaleTap(
                scale: 0.80,
                onTap: () => fp.toggleFavorite(p),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.15)),
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite, color: AppColors.secondary, size: 20),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          // Bottom CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: ScaleTap(
              onTap: () {
                Provider.of<BookingProvider>(context, listen: false).selectProvider(p);
                Navigator.pushNamed(context, '/booking');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: grad,
                      begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [BoxShadow(
                      color: grad[0].withOpacity(0.32),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Center(child: Text('Book Now',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── EMPTY STATE ──────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: FadeSlide(delay: const Duration(milliseconds: 80), child:
      Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          GlassAppIcon(
            icon: Icons.favorite_border_rounded,
            gradient: const [Color(0xFFFF8A65), Color(0xFFE53935)],
            size: 80, radius: 24, iconSize: 38,
          ),
          const SizedBox(height: 20),
          const Text('No Favorites Yet',
              style: TextStyle(fontFamily: 'Inter', fontSize: 19,
                  fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Tap the ♥ on any provider to save them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  color: AppColors.textMuted)),
        ]),
      ),
      ),
    );
  }
}