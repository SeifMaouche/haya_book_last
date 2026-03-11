import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Category data model used by [CategoryCard] and [CategoryGridCard].
class CategoryData {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final String? subtitle;

  const CategoryData({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.borderColor,
    this.subtitle,
  });

  // ── Preset categories matching HayaBook design system ──────

  static const clinic = CategoryData(
    label: 'Clinics',
    icon: Icons.medical_services_outlined,
    backgroundColor: AppColors.primaryLight,
    iconColor: AppColors.primary,
    subtitle: 'Medical care',
  );

  static const salon = CategoryData(
    label: 'Salons',
    icon: Icons.content_cut_outlined,
    backgroundColor: AppColors.secondaryLight,
    iconColor: AppColors.secondary,
    subtitle: 'Beauty & style',
  );

  static const tutor = CategoryData(
    label: 'Tutors',
    icon: Icons.menu_book_outlined,
    backgroundColor: Color(0x1A3B82F6),
    iconColor: Color(0xFF3B82F6),
    subtitle: 'Education',
  );

  static const fitness = CategoryData(
    label: 'Fitness',
    icon: Icons.fitness_center_outlined,
    backgroundColor: Color(0x1A10B981),
    iconColor: Color(0xFF10B981),
    subtitle: 'Health & gym',
  );

  static const spa = CategoryData(
    label: 'Spa',
    icon: Icons.spa_outlined,
    backgroundColor: Color(0x1AF97316),
    iconColor: Color(0xFFF97316),
    subtitle: 'Relax & unwind',
  );

  static const dental = CategoryData(
    label: 'Dental',
    icon: Icons.local_hospital_outlined,
    backgroundColor: AppColors.primaryLight,
    iconColor: AppColors.primary,
    subtitle: 'Dental care',
  );

  static List<CategoryData> get all =>
      [clinic, salon, tutor, fitness, spa, dental];
}

// ══════════════════════════════════════════════════════════════
/// Square icon card used in Quick Access grid on HomeScreen.
/// Shows icon + label stacked vertically.
// ══════════════════════════════════════════════════════════════
class CategoryCard extends StatelessWidget {
  final CategoryData category;
  final double size;
  final VoidCallback? onTap;
  final bool showSubtitle;

  const CategoryCard({
    Key? key,
    required this.category,
    this.size = 100,
    this.onTap,
    this.showSubtitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: category.borderColor != null
                  ? Border.all(
                  color: category.borderColor!.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Center(
              child: Icon(
                category.icon,
                size: size * 0.32,
                color: category.iconColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            category.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          // Optional subtitle
          if (showSubtitle && category.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              category.subtitle!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
/// Horizontal list card — icon on left, label + subtitle on right.
/// Useful for settings-style or list views.
// ══════════════════════════════════════════════════════════════
class CategoryListCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback? onTap;
  final String? providerCount;

  const CategoryListCard({
    Key? key,
    required this.category,
    this.onTap,
    this.providerCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  category.icon,
                  size: 22,
                  color: category.iconColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (category.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      category.subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Provider count badge (optional)
            if (providerCount != null)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: category.backgroundColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  providerCount!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: category.iconColor,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
/// Filter chip — compact horizontal pill used in BrowseScreen.
// ══════════════════════════════════════════════════════════════
class CategoryFilterChip extends StatelessWidget {
  final CategoryData category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryFilterChip({
    Key? key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(99),
          border: isSelected
              ? null
              : Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 13,
              color: isSelected ? Colors.white : category.iconColor,
            ),
            const SizedBox(width: 5),
            Text(
              category.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}