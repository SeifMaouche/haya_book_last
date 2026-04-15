// lib/screens/provider/provider_complete_profile_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/provider_state.dart';
import '../../providers/provider_profile_provider.dart';
import '../../services/provider_service.dart';

const _kPrimary   = Color(0xFF6B46C1);
const _kBg        = Color(0xFFF8FAFC);
const _kTextDark  = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kTextLight = Color(0xFF94A3B8);

class ProviderCompleteProfileScreen extends StatefulWidget {
  const ProviderCompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProviderCompleteProfileScreen> createState() =>
      _ProviderCompleteProfileScreenState();
}

class _ProviderCompleteProfileScreenState
    extends State<ProviderCompleteProfileScreen> {

  // ── Controllers ───────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _locCtrl  = TextEditingController();
  final _bioCtrl  = TextEditingController();

  // ── Focus nodes ───────────────────────────────────────────
  final _nameFocus = FocusNode();
  final _locFocus  = FocusNode();
  final _bioFocus  = FocusNode();

  // ── Scroll ────────────────────────────────────────────────
  final _scroll = ScrollController();

  // ── Section keys ──────────────────────────────────────────
  final _nameKey   = GlobalKey();
  final _catKey    = GlobalKey();
  final _addrKey   = GlobalKey();
  final _photosKey = GlobalKey();
  final _bioKey    = GlobalKey();

  // ── Data ──────────────────────────────────────────────────
  String         _category = '';
  final List<File?> _photos = []; // real picked images
  int            _step    = 0;
  bool           _saving  = false;
  LatLng         _location = const LatLng(36.7372, 3.0865);

  static const _totalSteps = 5;
  List<String> _categories = [];
  static const _stepLabels = [
    'Business Name', 'Category', 'Address',
    'Portfolio Photos', 'About Your Business',
  ];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ── Enforce Strict Role Policy ────────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userType != 'provider') {
        _showRoleErrorAndExit();
        return;
      }
      
      // Fetch categories from backend
      _fetchInitialData();
    });

    _nameCtrl.addListener(_recalcStep);
    _locCtrl.addListener(_recalcStep);
    _bioCtrl.addListener(_recalcStep);

    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) _scrollToKey(_nameKey);
    });
    _locFocus.addListener(() {
      if (_locFocus.hasFocus) _scrollToKey(_addrKey);
    });
    _bioFocus.addListener(() {
      if (_bioFocus.hasFocus) _scrollToKey(_bioKey);
    });

    _getLocation();
  }

  void _showRoleErrorAndExit() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Strict Role Policy', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'Your account is registered as a Client. HayaBook policy does not allow switching roles once registered. Please create a new account if you wish to be a Provider.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
            ),
            child: const Text('Back to Home', style: TextStyle(fontFamily: 'Inter', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchInitialData() async {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    if (bp.categories.isEmpty) {
      await bp.fetchCategories();
    }
    if (mounted) {
      setState(() {
        _categories = bp.categories.map((c) => c.name).toList();
        if (_categories.isNotEmpty) {
          _category = _categories[0];
        }
      });
      _recalcStep();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _locCtrl.dispose(); _bioCtrl.dispose();
    _nameFocus.dispose(); _locFocus.dispose(); _bioFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Get GPS location ──────────────────────────────────────
  Future<void> _getLocation() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      if (mounted) {
        setState(() {
          _location = LatLng(pos.latitude, pos.longitude);
          _locCtrl.text =
          '${pos.latitude.toStringAsFixed(4)}° N, '
              '${pos.longitude.toStringAsFixed(4)}° E';
        });
      }
    } catch (_) {}
  }

  // ── Step calc ─────────────────────────────────────────────
  void _recalcStep() {
    int s = 0;
    if (_nameCtrl.text.trim().isNotEmpty) s = 1;
    if (s == 1) s = 2;
    if (s == 2 && _locCtrl.text.trim().isNotEmpty) s = 3;
    if (s == 3 && _photos.isNotEmpty) s = 4;
    if (s == 4 && _bioCtrl.text.trim().isNotEmpty) s = 5;
    if (mounted) setState(() => _step = s.clamp(0, _totalSteps));
  }

  // ── Auto-scroll ───────────────────────────────────────────
  void _scrollToKey(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration:  const Duration(milliseconds: 400),
          curve:     Curves.easeOutCubic,
          alignment: 0.3);
    });
  }

  // ── Image picker ──────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await _sourceSheet();
    if (source == null) return;
    try {
      final img = await _picker.pickImage(
          source: source, maxWidth: 800, imageQuality: 80);
      if (img != null && mounted) {
        setState(() => _photos.add(File(img.path)));
        _recalcStep();
      }
    } catch (e) {
      _toast('Could not pick image. Check permissions.');
    }
  }

  void _removePhoto(int i) {
    setState(() => _photos.removeAt(i));
    _recalcStep();
  }

  Future<ImageSource?> _sourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 14),
            const Text('Add Photo', style: TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                fontWeight: FontWeight.w700, color: _kTextDark)),
            const SizedBox(height: 14),
            _SourceTile(icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                onTap: () => Navigator.pop(context, ImageSource.camera)),
            const SizedBox(height: 10),
            _SourceTile(icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () => Navigator.pop(context, ImageSource.gallery)),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  // ── Map picker ────────────────────────────────────────────
  Future<void> _openMap() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<LatLng>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _MapPickerSheet(initial: _location),
    );
    if (result != null && mounted) {
      setState(() {
        _location = result;
        _locCtrl.text =
        '${result.latitude.toStringAsFixed(4)}° N, '
            '${result.longitude.toStringAsFixed(4)}° E';
      });
      _recalcStep();
    }
  }

  // ── Validate + save ───────────────────────────────────────
  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return 'Please enter your business name.';
    if (_locCtrl.text.trim().isEmpty)  return 'Please enter your address.';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final err = _validate();
    if (err != null) {
      _toast(err);
      return;
    }
    setState(() => _saving = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final providerService = ProviderService();

      final newToken = await providerService.becomeProvider(
        businessName: _nameCtrl.text.trim(),
        category: _category,
        description: _bioCtrl.text.trim(),
        address: _locCtrl.text.trim(),
        latitude: _location.latitude,
        longitude: _location.longitude,
      );

      // Force AuthProvider to sync the new Token and 'PROVIDER' role locally.
      if (newToken != null) {
        await auth.updateToken(newToken);
      } else {
        await auth.loadAuthState();
      }

      // Initialize provider state before navigating
      if (mounted) {
        final ps = Provider.of<ProviderStateProvider>(context, listen: false);
        final pp = Provider.of<ProviderProfileProvider>(context, listen: false);
        await Future.wait<dynamic>([
          ps.loadInitialData(),
          pp.loadProfile(),
        ]);
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/provider/home', (_) => false);
    } catch (e) {
      if (mounted) {
        _toast('Registration failed. Please try again.');
        setState(() => _saving = false);
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  double get _progress => (_step / _totalSteps).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: _kBg,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        _MeshBg(),
        Column(children: [
          _Header(topPad: pad.top, onBack: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          }),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(20, 8, 20, pad.bottom + 120),
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _ProgressSection(
                    step:        _step,
                    total:       _totalSteps,
                    progress:    _progress,
                    activeLabel: _step < _totalSteps
                        ? _stepLabels[_step] : 'All Done!',
                  ),
                  const SizedBox(height: 20),

                  // Business Name
                  _SectionCard(key: _nameKey,
                    label: 'BUSINESS NAME', isActive: _step == 0,
                    child: _LightInput(
                      controller: _nameCtrl, focusNode: _nameFocus,
                      hint: 'e.g. Lavender Spa & Wellness',
                      onSubmit: () =>
                          FocusScope.of(context).requestFocus(_locFocus),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category
                  _SectionCard(key: _catKey,
                    label: 'CATEGORY', isActive: _step == 1,
                    child: _categories.isEmpty 
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
                        ))
                      : _DropdownInput(
                          value: _category.isEmpty ? _categories[0] : _category, 
                          items: _categories,
                          onChanged: (v) {
                            setState(() => _category = v!);
                            _recalcStep();
                          },
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Address + map
                  _SectionCard(key: _addrKey,
                    label: 'ADDRESS', isActive: _step == 2,
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: _LightInput(
                          controller: _locCtrl, focusNode: _locFocus,
                          hint: 'Search or pick from map',
                          prefixIcon: Icons.location_on_rounded,
                          onSubmit: () =>
                              FocusScope.of(context).requestFocus(_bioFocus),
                        )),
                        const SizedBox(width: 8),
                        // Map picker button
                        GestureDetector(
                          onTap: _openMap,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), _kPrimary]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(
                                  color: _kPrimary.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))],
                            ),
                            child: const Icon(Icons.map_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // Live map preview — tappable
                      GestureDetector(
                        onTap: _openMap,
                        child: _MapPreview(location: _location),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Portfolio Photos — real picker
                  _SectionCard(key: _photosKey,
                    label: 'PORTFOLIO PHOTOS', isActive: _step == 3,
                    child: _PhotoRow(
                      photos:   _photos,
                      onRemove: _removePhoto,
                      onAdd:    _pickPhoto,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // About
                  _SectionCard(key: _bioKey,
                    label: 'ABOUT YOUR BUSINESS', isActive: _step == 4,
                    child: _LightInput(
                      controller: _bioCtrl, focusNode: _bioFocus,
                      hint: 'Tell clients what makes you special...',
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _ContinueBar(
            allFilled: _step >= _totalSteps,
            saving:    _saving,
            onSave:    _saving ? null : _save,
            bottomPad: pad.bottom,
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MAP PREVIEW  — live OSM preview
// ══════════════════════════════════════════════════════════════
class _MapPreview extends StatelessWidget {
  final LatLng location;
  const _MapPreview({required this.location});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        child: Stack(children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: location,
              initialZoom:   14.0,
              interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.booking_app.app',
                maxZoom: 19,
              ),
              MarkerLayer(markers: [
                Marker(
                  point: location, width: 36, height: 36,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _kPrimary, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(
                          color: _kPrimary.withOpacity(0.45),
                          blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ]),
            ],
          ),
          Positioned(bottom: 6, right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6)],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.touch_app_rounded,
                    size: 11, color: _kPrimary),
                SizedBox(width: 3),
                Text('Tap to change', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w600, color: _kPrimary,
                )),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MAP PICKER SHEET
// ══════════════════════════════════════════════════════════════
class _MapPickerSheet extends StatefulWidget {
  final LatLng initial;
  const _MapPickerSheet({required this.initial});

  @override
  State<_MapPickerSheet> createState() => _MapPickerSheetState();
}

class _MapPickerSheetState extends State<_MapPickerSheet> {
  late LatLng _selected;
  late final MapController _mapCtrl;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _mapCtrl  = MapController();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() { _selected = loc; _locating = false; });
      _mapCtrl.move(loc, 15.0);
    } catch (_) {
      setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(99))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(children: [
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pick Location', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 16,
                    fontWeight: FontWeight.w700, color: _kTextDark)),
                SizedBox(height: 2),
                Text('Tap the map to set your location',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: _kTextMuted)),
              ],
            )),
            // My location
            GestureDetector(
              onTap: _goToMyLocation,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _kPrimary.withOpacity(0.20), width: 1),
                ),
                child: _locating
                    ? const Padding(padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kPrimary))
                    : const Icon(Icons.my_location_rounded,
                    color: _kPrimary, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            // Confirm
            GestureDetector(
              onTap: () => Navigator.pop(context, _selected),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), _kPrimary]),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [BoxShadow(
                      color: _kPrimary.withOpacity(0.35),
                      blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: const Text('Confirm', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
        Expanded(child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24)),
          child: FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _selected,
              initialZoom:   14.0,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.booking_app.app',
                maxZoom: 19,
              ),
              MarkerLayer(markers: [
                Marker(
                  point: _selected, width: 44, height: 44,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _kPrimary, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(
                          color: _kPrimary.withOpacity(0.50),
                          blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ],
          ),
        )),
        SizedBox(height: pad.bottom),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PHOTO ROW  — real File images
// ══════════════════════════════════════════════════════════════
class _PhotoRow extends StatelessWidget {
  final List<File?>     photos;
  final ValueChanged<int> onRemove;
  final VoidCallback    onAdd;
  const _PhotoRow({required this.photos, required this.onRemove,
    required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        // ADD slot
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 80, height: 80,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color:        _kPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _kPrimary.withOpacity(0.30), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_rounded,
                    color: _kPrimary, size: 22),
                const SizedBox(height: 3),
                Text('ADD', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary.withOpacity(0.70),
                  letterSpacing: 0.8,
                )),
              ],
            ),
          ),
        ),
        // Filled slots
        ...List.generate(photos.length, (i) {
          final file = photos[i];
          return Container(
            width: 80, height: 80,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color:        _kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: file != null
                    ? Image.file(file, fit: BoxFit.cover,
                    width: 80, height: 80)
                    : const Center(child: Icon(Icons.image_rounded,
                    color: _kPrimary, size: 28)),
              ),
              Positioned(top: 5, right: 5,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 11),
                  ),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SOURCE TILE
// ══════════════════════════════════════════════════════════════
class _SourceTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SourceTile({required this.icon, required this.label,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: _kPrimary, size: 18)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontFamily: 'Inter',
              fontSize: 14, fontWeight: FontWeight.w600,
              color: _kTextDark)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: _kTextLight, size: 18),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PROGRESS SECTION — kept exactly from original
// ══════════════════════════════════════════════════════════════
class _ProgressSection extends StatelessWidget {
  final int step, total; final double progress; final String activeLabel;
  const _ProgressSection({required this.step, required this.total,
    required this.progress, required this.activeLabel});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Business', style: TextStyle(
              fontFamily: 'Inter', fontSize: 26,
              fontWeight: FontWeight.w800, color: _kTextDark,
              letterSpacing: -0.4, height: 1.1,
            )),
            const SizedBox(height: 3),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                key: ValueKey(activeLabel),
                step < 5 ? 'Now filling: $activeLabel' : '✓ All fields complete!',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: step < 5 ? _kTextMuted : _kPrimary),
              ),
            ),
          ],
        )),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(key: ValueKey(step),
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w700, color: _kPrimary)),
        ),
      ]),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(children: [
          Container(height: 8,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.50),
                  borderRadius: BorderRadius.circular(99))),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            widthFactor: progress,
            child: Container(height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), _kPrimary]),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [BoxShadow(
                      color: _kPrimary.withOpacity(0.40), blurRadius: 10)],
                )),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: i < step ? Colors.white
                        : Colors.white.withOpacity(0.30)),
              ))),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION CARD
// ══════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final String label; final Widget child; final bool isActive;
  const _SectionCard({super.key, required this.label,
    required this.child, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isActive ? _kPrimary.withOpacity(0.40) : Colors.transparent,
            width: 1.5),
        boxShadow: [BoxShadow(
            color: isActive ? _kPrimary.withOpacity(0.10)
                : Colors.black.withOpacity(0.05),
            blurRadius: isActive ? 16 : 8,
            offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: isActive ? _kPrimary : _kPrimary.withOpacity(0.20))),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? _kPrimary : _kTextLight,
              letterSpacing: 1.0)),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LIGHT INPUT
// ══════════════════════════════════════════════════════════════
class _LightInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode; final String hint;
  final IconData? prefixIcon; final int maxLines;
  final VoidCallback? onSubmit;
  const _LightInput({required this.controller, required this.focusNode,
    required this.hint, this.prefixIcon, this.maxLines = 1,
    this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1)),
      child: TextField(
        controller: controller, focusNode: focusNode, maxLines: maxLines,
        onEditingComplete: onSubmit,
        textInputAction: maxLines > 1
            ? TextInputAction.newline : TextInputAction.next,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
            color: _kTextDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Inter',
              fontSize: 14, color: _kTextLight),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: _kPrimary, size: 18) : null,
          border: InputBorder.none, enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true, fillColor: Colors.transparent,
          contentPadding: EdgeInsets.fromLTRB(
              prefixIcon != null ? 4 : 14, 12, 14, 12),
          isDense: maxLines == 1,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DROPDOWN
// ══════════════════════════════════════════════════════════════
class _DropdownInput extends StatelessWidget {
  final String value; final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownInput({required this.value, required this.items,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Padding(padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _kTextMuted, size: 20)),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
              color: _kTextDark, fontWeight: FontWeight.w500),
          items: items.map((c) => DropdownMenuItem(value: c,
              child: Padding(padding: const EdgeInsets.only(left: 10),
                  child: Text(c, style: const TextStyle(fontFamily: 'Inter',
                      fontSize: 14, color: _kTextDark))))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONTINUE BAR
// ══════════════════════════════════════════════════════════════
class _ContinueBar extends StatelessWidget {
  final bool allFilled, saving; final VoidCallback? onSave;
  final double bottomPad;
  const _ContinueBar({required this.allFilled, required this.saving,
    required this.onSave, required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad > 0 ? bottomPad + 6 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter,
            end: Alignment.bottomCenter, colors: [
              _kBg.withOpacity(0.0), _kBg.withOpacity(0.95), _kBg,
            ]),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: onSave,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: allFilled
                  ? [const Color(0xFF8B5CF6), _kPrimary]
                  : [_kPrimary.withOpacity(0.60), _kPrimary.withOpacity(0.50)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: allFilled ? [BoxShadow(
                  color: _kPrimary.withOpacity(0.35),
                  blurRadius: 16, offset: const Offset(0, 5))] : [],
            ),
            child: saving
                ? const Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(key: ValueKey(allFilled),
                    allFilled ? 'Complete Setup ✓' : 'Complete Profile',
                    style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              if (!saving) ...[
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 17),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 6),
        Text('By continuing, you agree to HayaBook Provider Terms.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                fontStyle: FontStyle.italic, color: _kTextLight)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final double topPad; final VoidCallback onBack;
  const _Header({required this.topPad, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(14, topPad + 10, 14, 11),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.70),
              border: Border(bottom: BorderSide(
                  color: Colors.black.withOpacity(0.06), width: 0.5))),
          child: Row(children: [
            GestureDetector(onTap: onBack,
                child: Container(width: 36, height: 36,
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        size: 16, color: _kPrimary))),
            const Expanded(child: Text('Complete Profile',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 16,
                    fontWeight: FontWeight.w700, color: _kTextDark,
                    letterSpacing: -0.2))),
            const SizedBox(width: 36),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MESH BACKGROUND
// ══════════════════════════════════════════════════════════════
class _MeshBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MeshPainter(),
        child: const SizedBox.expand());
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void radial(Alignment a, Color c, double r) {
      final cx = (a.x + 1) / 2 * size.width;
      final cy = (a.y + 1) / 2 * size.height;
      canvas.drawCircle(Offset(cx, cy), r,
          Paint()..shader = RadialGradient(colors: [c, c.withOpacity(0)])
              .createShader(Rect.fromCircle(
              center: Offset(cx, cy), radius: r)));
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = _kBg);
    radial(Alignment.topLeft,     const Color(0xFFE9D5FF).withOpacity(0.60), size.width * 0.8);
    radial(Alignment.topRight,    const Color(0xFFDDD6FE).withOpacity(0.40), size.width * 0.7);
    radial(Alignment.bottomRight, const Color(0xFFF3F4F6).withOpacity(0.50), size.width * 0.6);
    radial(Alignment.bottomLeft,  const Color(0xFFE0E7FF).withOpacity(0.50), size.width * 0.7);
  }
  @override
  bool shouldRepaint(_) => false;
}