import 'package:flutter/material.dart';
import '../config/theme.dart';

// ── GPS via geolocator package ─────────────────────────────────────
// Add to pubspec.yaml under dependencies:
//   geolocator: ^11.0.0
//
// Add to android/app/src/main/AndroidManifest.xml (inside <manifest>):
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';

// ── All 58 Algerian wilayas ────────────────────────────────────────
const _kCities = [
  {'name': 'Adrar', 'country': 'Algeria', 'lat': 27.8742, 'lng': -0.2939},
  {'name': 'Aïn Defla', 'country': 'Algeria', 'lat': 36.2642, 'lng': 1.9656},
  {
    'name': 'Aïn Témouchent',
    'country': 'Algeria',
    'lat': 35.2980,
    'lng': -1.1397
  },
  {'name': 'Algiers', 'country': 'Algeria', 'lat': 36.7372, 'lng': 3.0865},
  {'name': 'Annaba', 'country': 'Algeria', 'lat': 36.9000, 'lng': 7.7667},
  {'name': 'Batna', 'country': 'Algeria', 'lat': 35.5559, 'lng': 6.1742},
  {'name': 'Béchar', 'country': 'Algeria', 'lat': 31.6238, 'lng': -2.2167},
  {'name': 'Béjaïa', 'country': 'Algeria', 'lat': 36.7539, 'lng': 5.0561},
  {'name': 'Béni Abbès', 'country': 'Algeria', 'lat': 30.1278, 'lng': -2.1631},
  {'name': 'Biskra', 'country': 'Algeria', 'lat': 34.8500, 'lng': 5.7333},
  {'name': 'Blida', 'country': 'Algeria', 'lat': 36.4700, 'lng': 2.8300},
  {
    'name': 'Bordj Bou Arréridj',
    'country': 'Algeria',
    'lat': 36.0731,
    'lng': 4.7631
  },
  {
    'name': 'Bordj Badji Mokhtar',
    'country': 'Algeria',
    'lat': 21.3294,
    'lng': 0.9231
  },
  {'name': 'Bouira', 'country': 'Algeria', 'lat': 36.3697, 'lng': 3.9019},
  {'name': 'Boumerdès', 'country': 'Algeria', 'lat': 36.7694, 'lng': 3.4769},
  {'name': 'Chlef', 'country': 'Algeria', 'lat': 36.1647, 'lng': 1.3317},
  {'name': 'Constantine', 'country': 'Algeria', 'lat': 36.3650, 'lng': 6.6147},
  {'name': 'Djanet', 'country': 'Algeria', 'lat': 24.5553, 'lng': 9.4844},
  {'name': 'Djelfa', 'country': 'Algeria', 'lat': 34.6748, 'lng': 3.2630},
  {'name': 'El Bayadh', 'country': 'Algeria', 'lat': 33.6833, 'lng': 1.0167},
  {'name': 'El Mghair', 'country': 'Algeria', 'lat': 33.9500, 'lng': 5.9167},
  {'name': 'El Menia', 'country': 'Algeria', 'lat': 30.5833, 'lng': 2.8833},
  {'name': 'El Oued', 'country': 'Algeria', 'lat': 33.3683, 'lng': 6.8633},
  {'name': 'El Tarf', 'country': 'Algeria', 'lat': 36.7667, 'lng': 8.3167},
  {'name': 'Ghardaïa', 'country': 'Algeria', 'lat': 32.4908, 'lng': 3.6736},
  {'name': 'Guelma', 'country': 'Algeria', 'lat': 36.4619, 'lng': 7.4317},
  {'name': 'Illizi', 'country': 'Algeria', 'lat': 26.5069, 'lng': 8.4736},
  {'name': 'In Guezzam', 'country': 'Algeria', 'lat': 19.5667, 'lng': 5.7667},
  {'name': 'In Salah', 'country': 'Algeria', 'lat': 27.1956, 'lng': 2.4644},
  {'name': 'Jijel', 'country': 'Algeria', 'lat': 36.8219, 'lng': 5.7658},
  {'name': 'Khenchela', 'country': 'Algeria', 'lat': 35.4353, 'lng': 7.1425},
  {'name': 'Laghouat', 'country': 'Algeria', 'lat': 33.8000, 'lng': 2.8833},
  {'name': 'M\'Sila', 'country': 'Algeria', 'lat': 35.7019, 'lng': 4.5389},
  {'name': 'Mascara', 'country': 'Algeria', 'lat': 35.3958, 'lng': 0.1408},
  {'name': 'Médéa', 'country': 'Algeria', 'lat': 36.2636, 'lng': 2.7528},
  {'name': 'Mila', 'country': 'Algeria', 'lat': 36.4503, 'lng': 6.2639},
  {'name': 'Mostaganem', 'country': 'Algeria', 'lat': 35.9319, 'lng': 0.0889},
  {'name': 'Naâma', 'country': 'Algeria', 'lat': 33.2667, 'lng': -0.3167},
  {'name': 'Oran', 'country': 'Algeria', 'lat': 35.6969, 'lng': -0.6331},
  {'name': 'Ouargla', 'country': 'Algeria', 'lat': 31.9539, 'lng': 5.3242},
  {
    'name': 'Ouled Djellal',
    'country': 'Algeria',
    'lat': 34.4167,
    'lng': 5.0667
  },
  {
    'name': 'Oum El Bouaghi',
    'country': 'Algeria',
    'lat': 35.8700,
    'lng': 7.1131
  },
  {'name': 'Relizane', 'country': 'Algeria', 'lat': 35.7369, 'lng': 0.5564},
  {'name': 'Saïda', 'country': 'Algeria', 'lat': 34.8306, 'lng': 0.1517},
  {'name': 'Sétif', 'country': 'Algeria', 'lat': 36.1898, 'lng': 5.4108},
  {
    'name': 'Sidi Bel Abbès',
    'country': 'Algeria',
    'lat': 35.1897,
    'lng': -0.6306
  },
  {'name': 'Skikda', 'country': 'Algeria', 'lat': 36.8781, 'lng': 6.9058},
  {'name': 'Souk Ahras', 'country': 'Algeria', 'lat': 36.2864, 'lng': 7.9514},
  {'name': 'Tamanrasset', 'country': 'Algeria', 'lat': 22.7853, 'lng': 5.5228},
  {'name': 'Tébessa', 'country': 'Algeria', 'lat': 35.4044, 'lng': 8.1197},
  {'name': 'Tiaret', 'country': 'Algeria', 'lat': 35.3706, 'lng': 1.3217},
  {'name': 'Timimoun', 'country': 'Algeria', 'lat': 29.2639, 'lng': 0.2306},
  {'name': 'Tindouf', 'country': 'Algeria', 'lat': 27.6742, 'lng': -8.1478},
  {'name': 'Tipaza', 'country': 'Algeria', 'lat': 36.5894, 'lng': 2.4472},
  {'name': 'Tissemsilt', 'country': 'Algeria', 'lat': 35.6075, 'lng': 1.8119},
  {'name': 'Tizi Ouzou', 'country': 'Algeria', 'lat': 36.7167, 'lng': 4.0500},
  {'name': 'Tlemcen', 'country': 'Algeria', 'lat': 34.8828, 'lng': -1.3152},
  {'name': 'Touggourt', 'country': 'Algeria', 'lat': 33.1000, 'lng': 6.0667},
];

class LocationPickerSheet extends StatefulWidget {
  final String currentLocation;
  final ValueChanged<String> onSelected;

  const LocationPickerSheet({
    super.key,
    required this.currentLocation,
    required this.onSelected,
  });

  /// Convenience: show as bottom sheet and return selected city
  static Future<String?> show(BuildContext ctx, String current) {
    return showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => LocationPickerSheet(
        currentLocation: current,
        onSelected: (city) => Navigator.of(ctx).pop(city),
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final _searchCtrl = TextEditingController();
  bool _locating = false;
  String? _gpsError;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return List.from(_kCities);
    return _kCities
        .where((c) => (c['name'] as String).toLowerCase().contains(q))
        .toList();
  }

  // ── GPS location ─────────────────────────────────────────────────
  Future<void> _useGps() async {
    setState(() {
      _locating = true;
      _gpsError = null;
    });

    try {
      // 1. Services enabled?
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _gpsError = 'GPS is off. Please enable Location Services.';
          _locating = false;
        });
        return;
      }

      // 2. Permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          _gpsError = perm == LocationPermission.deniedForever
              ? 'Permission denied. Enable in phone Settings → Apps → HayaBook.'
              : 'Location permission denied.';
          _locating = false;
        });
        return;
      }

      // 3. Get position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );

      // 4. Nearest city
      final city = _nearest(pos.latitude, pos.longitude);
      if (mounted) widget.onSelected(city);
    } catch (e) {
      if (mounted) {
        setState(() {
          _gpsError = 'Could not get location. Try again.';
          _locating = false;
        });
      }
    }
  }

  String _nearest(double lat, double lng) {
    Map<String, dynamic>? best;
    double minD = double.infinity;
    for (final c in _kCities) {
      final dLat = (c['lat'] as double) - lat;
      final dLng = (c['lng'] as double) - lng;
      final d = dLat * dLat + dLng * dLng;
      if (d < minD) {
        minD = d;
        best = c;
      }
    }
    return best != null
        ? '${best['name']}, ${best['country']}'
        : 'Algiers, Algeria';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.93,
      builder: (_, scrollCtrl) => Column(
        children: [
          // ── Fixed header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 18),

                // Title + close
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textMuted),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Select Location',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                      ),
                    ),
                    const SizedBox(width: 32), // balance
                  ],
                ),
                const SizedBox(height: 18),

                // ── Search bar ─────────────────────────────
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Icon(Icons.search,
                            color: AppColors.primary, size: 20),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textDark),
                          decoration: const InputDecoration(
                            hintText: 'Search city or area...',
                            hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textLight),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14),
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _searchCtrl.clear()),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.cancel,
                                size: 18, color: AppColors.textLight),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Use Current Location ───────────────────
                GestureDetector(
                  onTap: _locating ? null : _useGps,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _gpsError != null
                              ? AppColors.error.withOpacity(0.4)
                              : AppColors.primary.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        // GPS icon circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _gpsError != null
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: _locating
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  _gpsError != null
                                      ? Icons.gps_off_outlined
                                      : Icons.my_location_rounded,
                                  color: _gpsError != null
                                      ? AppColors.error
                                      : AppColors.primary,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _locating
                                    ? 'Detecting location...'
                                    : 'Use Current Location',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _gpsError != null
                                        ? AppColors.error
                                        : AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _gpsError ?? 'Enable GPS for better accuracy',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: _gpsError != null
                                        ? AppColors.error
                                        : AppColors.textMuted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (!_locating)
                          Icon(
                            Icons.chevron_right,
                            color: _gpsError != null
                                ? AppColors.error.withOpacity(0.5)
                                : AppColors.textLight,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section label
                Text(
                  _searchCtrl.text.isNotEmpty
                      ? 'SEARCH RESULTS'
                      : 'POPULAR CITIES',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Scrollable city list ───────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No cities found',
                        style: TextStyle(
                            fontFamily: 'Inter', color: AppColors.textMuted)))
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length + 1,
                    itemBuilder: (_, i) {
                      // Footer
                      if (i == filtered.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Wrap(
                              children: [
                                const Text(
                                  "Can't find your city? ",
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.textMuted),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/contact-us');
                                  },
                                  child: const Text(
                                    'Contact support',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final city = filtered[i];
                      final isSelected = widget.currentLocation
                          .contains(city['name'] as String);

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => widget.onSelected(
                                '${city['name']}, ${city['country']}'),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      city['name'] as String,
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textDark),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textLight,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (i < filtered.length - 1)
                            const Divider(
                                height: 1, color: AppColors.cardBorder),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
