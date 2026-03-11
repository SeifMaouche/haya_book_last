import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/provider_model.dart';

/// A reusable provider card widget used in horizontal lists and grids.
/// Displays a gradient hero image, provider name, rating, distance,
/// and a "Book Now" CTA — all matching the HayaBook design system.
class ProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  /// Card width. Defaults to 240 (horizontal scroll size).
  final double width;

  /// Card height. Defaults to 254.
  final double height;

  const ProviderCard({
    Key? key,
    required this.provider,
    this.onTap,
    this.onBookNow,
    this.width = 240,
    this.height = 254,
  }) : super(key: key);

  // ── Gradient colours per category ──────────────────────────
  List<Color> get _gradientColors {
    switch (provider.category) {
      case 'Salon':
        return [const Color(0xFFF97316), const Color(0xFFE55D00)];
      case 'Tutor':
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      default: // Clinic
        return [AppColors.primary, const Color(0xFF0A7A70)];
    }
  }

  IconData get _categoryIcon {
    switch (provider.category) {
      case 'Salon':
        return Icons.content_cut;
      case 'Tutor':
        return Icons.school_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Hero image area ─────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradientColors,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _categoryIcon,
                        size: 56,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Dark overlay at bottom
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                  // Verified badge (top-right)
                  if (provider.isVerified)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                size: 11, color: AppColors.success),
                            SizedBox(width: 3),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Category chip (top-left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        provider.category,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Provider name (bottom overlay)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Text(
                      provider.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // ── Bottom info ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Rating
                      const Icon(Icons.star,
                          size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        '${provider.rating}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${provider.reviewCount})',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                      const Spacer(),
                      // Distance
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${provider.distance}km',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Book Now button
                  GestureDetector(
                    onTap: onBookNow ?? onTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
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
    );
  }
}

/// Compact list-view version of ProviderCard used in BrowseScreen.
class ProviderListCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const ProviderListCard({
    Key? key,
    required this.provider,
    this.onTap,
    this.onBookNow,
  }) : super(key: key);

  List<Color> get _gradientColors {
    switch (provider.category) {
      case 'Salon':
        return [const Color(0xFFF97316), const Color(0xFFE55D00)];
      case 'Tutor':
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      default:
        return [AppColors.primary, const Color(0xFF0A7A70)];
    }
  }

  IconData get _categoryIcon {
    switch (provider.category) {
      case 'Salon':
        return Icons.content_cut;
      case 'Tutor':
        return Icons.school_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradientColors,
                ),
              ),
              child: Center(
                child: Icon(
                  _categoryIcon,
                  size: 36,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.isVerified)
                          const Icon(Icons.verified,
                              size: 14, color: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.category,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          '${provider.rating}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${provider.reviewCount})',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${provider.distance}km',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From DZD ${provider.averagePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: onBookNow ?? onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}