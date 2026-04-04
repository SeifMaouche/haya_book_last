// lib/screens/provider/provider_edit_profile_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_profile_provider.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary     = Color(0xFF6D28D9);
const _kPrimaryDeep = Color(0xFF4C1D95);
const _kTextDark    = Color(0xFF111827);
const _kTextMuted   = Color(0xFF6B7280);
const _kTextLight   = Color(0xFF9CA3AF);

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProviderEditProfileScreen> createState() =>
      _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState
    extends State<ProviderEditProfileScreen> {

  // ── Controllers ───────────────────────────────────────────
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _locCtrl;

  // ── Focus nodes ───────────────────────────────────────────
  final _nameFocus = FocusNode();
  final _bioFocus  = FocusNode();
  final _locFocus  = FocusNode();

  // ── Section keys for auto-scroll ─────────────────────────
  final _infoKey    = GlobalKey();
  final _bioKey     = GlobalKey();
  final _galleryKey = GlobalKey();
  final _locKey     = GlobalKey();

  final _scroll = ScrollController();

  // ── State ─────────────────────────────────────────────────
  late String   _category;
  bool          _saving  = false;
  File?         _logoFile;
  late List<File> _gallery;
  late LatLng   _location;

  static const _categories = [
    'Health & Wellness', 'Beauty & Grooming', 'Beauty & Salon',
    'Fitness', 'Tutoring', 'Medical / Clinic', 'Spa & Relaxation',
  ];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ── Pre-fill from ProviderProfileProvider ───────────────
    final profile = Provider.of<ProviderProfileProvider>(
        context, listen: false);
    _nameCtrl = TextEditingController(text: profile.businessName);
    _bioCtrl  = TextEditingController(text: profile.bio);
    _locCtrl  = TextEditingController(text: profile.locationText);
    _category = profile.category;
    _logoFile = profile.logoFile;
    _gallery  = List<File>.from(profile.portfolioPhotos);
    _location = profile.location;

    _nameFocus.addListener(() { if (_nameFocus.hasFocus) _scrollTo(_infoKey); });
    _bioFocus.addListener(()  { if (_bioFocus.hasFocus)  _scrollTo(_bioKey);  });
    _locFocus.addListener(()  { if (_locFocus.hasFocus)  _scrollTo(_locKey);  });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _bioCtrl.dispose(); _locCtrl.dispose();
    _nameFocus.dispose(); _bioFocus.dispose(); _locFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Auto-scroll ───────────────────────────────────────────
  void _scrollTo(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          curve:    Curves.easeOutCubic,
          alignment: 0.15);
    });
  }

  // ── Pick logo ─────────────────────────────────────────────
  Future<void> _pickLogo() async {
    final source = await _sourceSheet();
    if (source == null) return;
    try {
      final img = await _picker.pickImage(
          source: source, maxWidth: 512, imageQuality: 85);
      if (img != null && mounted) setState(() => _logoFile = File(img.path));
    } catch (_) {
      _toast('Could not pick image. Check permissions.');
    }
  }

  // ── Pick gallery photo ────────────────────────────────────
  Future<void> _pickGalleryPhoto() async {
    final source = await _sourceSheet();
    if (source == null) return;
    try {
      final img = await _picker.pickImage(
          source: source, maxWidth: 800, imageQuality: 80);
      if (img != null && mounted) {
        setState(() => _gallery.add(File(img.path)));
      }
    } catch (_) {
      _toast('Could not pick image. Check permissions.');
    }
  }

  void _removeGallery(int i) => setState(() => _gallery.removeAt(i));

  // ── Image source sheet ────────────────────────────────────
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
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 14),
            const Text('Add Photo', style: TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                fontWeight: FontWeight.w700, color: _kTextDark)),
            const SizedBox(height: 14),
            _SourceTile(icon: Icons.camera_alt_rounded, label: 'Take Photo',
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

  // ── Open map picker ───────────────────────────────────────
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
    }
  }

  // ── Save → ProviderProfileProvider ───────────────────────
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Persist everything to the shared provider
    Provider.of<ProviderProfileProvider>(context, listen: false).saveProfile(
      name:    _nameCtrl.text,
      cat:     _category,
      about:   _bioCtrl.text,
      latLng:  _location,
      locText: _locCtrl.text,
      logo:    _logoFile,
      gallery: List<File>.from(_gallery),
    );

    setState(() => _saving = false);

    // Show success snack then pop
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('Profile updated!',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
    Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
      backgroundColor: _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topCenter,
            end:    Alignment.bottomCenter,
            colors: [Color(0xFFEEEBFF), Color(0xFFF8F7FF)],
            stops:  [0.0, 0.45],
          ),
        ),
        child: Column(children: [
          _StickyHeader(topPad: pad.top),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(14, 0, 14, pad.bottom + 90),
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(children: [

                // Cover + profile pic
                _CoverSection(
                    logoFile: _logoFile, onPickLogo: _pickLogo),
                const SizedBox(height: 16),

                // Business Info
                _Section(key: _infoKey, icon: Icons.badge_rounded,
                    title: 'Business Info',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('BUSINESS NAME'),
                        const SizedBox(height: 5),
                        _TextInput(ctrl: _nameCtrl, focus: _nameFocus),
                        const SizedBox(height: 12),
                        _FieldLabel('PROFESSIONAL CATEGORY'),
                        const SizedBox(height: 5),
                        _CategoryPicker(
                            value:     _category,
                            items:     _categories,
                            onChanged: (v) =>
                                setState(() => _category = v!)),
                      ],
                    )),
                const SizedBox(height: 12),

                // Business Bio
                _Section(key: _bioKey, icon: Icons.description_rounded,
                    title: 'Business Bio',
                    child: _TextInput(
                        ctrl: _bioCtrl, focus: _bioFocus, maxLines: 5)),
                const SizedBox(height: 12),

                // Photo Gallery
                _Section(key: _galleryKey,
                    icon: Icons.photo_library_rounded,
                    title: 'Portfolio Photos',
                    trailing: ScaleTap(
                      onTap: _pickGalleryPhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: _kPrimary.withOpacity(0.20), width: 1),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_rounded,
                                  size: 12, color: _kPrimary),
                              SizedBox(width: 3),
                              Text('ADD MORE', style: TextStyle(
                                fontFamily:    'Inter',
                                fontSize:      9,
                                fontWeight:    FontWeight.w800,
                                color:         _kPrimary,
                                letterSpacing: 0.5,
                              )),
                            ]),
                      ),
                    ),
                    child: _GalleryGrid(
                        photos:   _gallery,
                        onRemove: _removeGallery,
                        onAdd:    _pickGalleryPhoto)),
                const SizedBox(height: 12),

                // Business Location
                _Section(key: _locKey, icon: Icons.location_on_rounded,
                    title: 'Business Location',
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: _LocationInput(
                            ctrl: _locCtrl, focus: _locFocus)),
                        const SizedBox(width: 8),
                        ScaleTap(
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
                      const SizedBox(height: 12),
                      GestureDetector(
                          onTap: _openMap,
                          child: _MapPreview(location: _location)),
                    ])),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SaveBar(saving: _saving, onSave: _saving ? null : _save),
          const ProviderBottomNavBar(currentIndex: 3),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STICKY GLASS HEADER
// ══════════════════════════════════════════════════════════════
class _StickyHeader extends StatelessWidget {
  final double topPad;
  const _StickyHeader({required this.topPad});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.fromLTRB(14, topPad + 11, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border(bottom: BorderSide(
                color: Colors.black.withOpacity(0.06), width: 0.5)),
          ),
          child: Row(children: [
            ScaleTap(
              onTap: () => Navigator.pop(context),
              child: const Padding(padding: EdgeInsets.all(4),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: _kTextDark)),
            ),
            const SizedBox(width: 6),
            const Expanded(child: Text('Edit Business Profile',
                style: TextStyle(fontFamily: 'Inter', fontSize: 16,
                    fontWeight: FontWeight.w700, color: _kTextDark,
                    letterSpacing: -0.2))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.30),
                    blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: const Text('PREMIUM', style: TextStyle(
                fontFamily:    'Inter',
                fontSize:      9,
                fontWeight:    FontWeight.w800,
                color:         Colors.white,
                letterSpacing: 1.0,
              )),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// COVER + LOGO
// ══════════════════════════════════════════════════════════════
class _CoverSection extends StatelessWidget {
  final File?        logoFile;
  final VoidCallback onPickLogo;
  const _CoverSection({required this.logoFile, required this.onPickLogo});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        height: 170, width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), _kPrimaryDeep],
          ),
          borderRadius:
          BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Stack(children: [
          Positioned(top: -30, right: -30,
            child: Container(width: 140, height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.white.withOpacity(0.12), Colors.transparent,
                  ])),
            ),
          ),
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onPickLogo,
                child: Stack(children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape:  BoxShape.circle,
                      color:  Colors.white.withOpacity(0.15),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.80), width: 3),
                      boxShadow: [BoxShadow(
                          color:      Colors.black.withOpacity(0.20),
                          blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: ClipOval(
                      child: logoFile != null
                          ? Image.file(logoFile!,
                          fit: BoxFit.cover, width: 90, height: 90)
                          : Container(
                          color: Colors.white.withOpacity(0.15),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 44)),
                    ),
                  ),
                  Positioned(bottom: 2, right: 2,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color:  _kPrimary,
                        shape:  BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onPickLogo,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35), width: 1),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 12),
                        SizedBox(width: 5),
                        Text('Change Photo', style: TextStyle(
                          fontFamily:    'Inter',
                          fontSize:      11,
                          fontWeight:    FontWeight.w700,
                          color:         Colors.white,
                          letterSpacing: 0.3,
                        )),
                      ]),
                ),
              ),
            ],
          )),
        ]),
      ),
      const SizedBox(height: 175),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION CARD
// ══════════════════════════════════════════════════════════════
class _Section extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Widget   child;
  final Widget?  trailing;
  const _Section({super.key, required this.icon, required this.title,
    required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: _kPrimary, size: 17)),
          const SizedBox(width: 9),
          Expanded(child: Text(title, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w700, color: _kTextDark))),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
          fontWeight: FontWeight.w700, color: _kTextLight,
          letterSpacing: 0.8));
}

class _TextInput extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode             focus;
  final int                   maxLines;
  const _TextInput({required this.ctrl, required this.focus,
    this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: TextField(
        controller: ctrl, focusNode: focus, maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
            fontWeight: FontWeight.w500, color: _kTextDark),
        decoration: const InputDecoration(
          border:           InputBorder.none,
          filled:           true,
          fillColor:        Colors.transparent,
          contentPadding:   EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final String value; final List<String> items;
  final ValueChanged<String?> onChanged;
  const _CategoryPicker({required this.value, required this.items,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:        const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: _kTextMuted),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
              fontWeight: FontWeight.w500, color: _kTextDark),
          items: items.map((c) => DropdownMenuItem(value: c,
              child: Text(c, style: const TextStyle(fontFamily: 'Inter',
                  fontSize: 13, color: _kTextDark)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GALLERY GRID
// ══════════════════════════════════════════════════════════════
class _GalleryGrid extends StatelessWidget {
  final List<File>        photos;
  final ValueChanged<int> onRemove;
  final VoidCallback      onAdd;
  const _GalleryGrid({required this.photos, required this.onRemove,
    required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount:   3,
      crossAxisSpacing: 10,
      mainAxisSpacing:  10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(photos.length, (i) => Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: _kPrimary.withOpacity(0.10),
              child: Image.file(photos[i], fit: BoxFit.cover,
                  width: double.infinity, height: double.infinity),
            ),
          ),
          Positioned(top: 4, right: 4,
            child: GestureDetector(
              onTap: () => onRemove(i),
              child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 12),
              ),
            ),
          ),
        ])),
        // Upload slot
        GestureDetector(
          onTap: onAdd,
          child: Container(
            decoration: BoxDecoration(
              color:        _kPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _kPrimary.withOpacity(0.30), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    color: _kPrimary.withOpacity(0.70), size: 22),
                const SizedBox(height: 4),
                Text('UPLOAD', style: TextStyle(fontFamily: 'Inter',
                    fontSize: 8, fontWeight: FontWeight.w800,
                    color: _kPrimary.withOpacity(0.70),
                    letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationInput extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode             focus;
  const _LocationInput({required this.ctrl, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:        const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.location_searching_rounded,
            color: _kTextLight, size: 16),
        const SizedBox(width: 7),
        Expanded(child: TextField(
          controller: ctrl, focusNode: focus,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
              color: _kTextDark),
          decoration: const InputDecoration(
            border:         InputBorder.none,
            filled:         true,
            fillColor:      Colors.transparent,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            hintText:       'Pick from map or type address',
            hintStyle:      TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: _kTextLight),
          ),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MAP PREVIEW
// ══════════════════════════════════════════════════════════════
class _MapPreview extends StatelessWidget {
  final LatLng location;
  const _MapPreview({required this.location});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 140,
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
                  point: location, width: 44, height: 54,
                  child: const _PinMarker(),
                ),
              ]),
            ],
          ),
          Positioned(bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8)],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.touch_app_rounded, size: 12, color: _kPrimary),
                SizedBox(width: 4),
                Text('Tap to change', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 10,
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
  late LatLng          _selected;
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
        setState(() => _locating = false); return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() { _selected = loc; _locating = false; });
      _mapCtrl.move(loc, 15.0);
    } catch (_) { setState(() => _locating = false); }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color:        Colors.white,
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
                Text('Tap on the map to set your location',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: _kTextMuted)),
              ],
            )),
            ScaleTap(
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
            ScaleTap(
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
                  point: _selected, width: 48, height: 58,
                  child: const _PinMarker(size: 48),
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
// SOURCE TILE
// ══════════════════════════════════════════════════════════════
class _SourceTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _SourceTile({required this.icon, required this.label,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        const Color(0xFFF9FAFB),
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
              fontSize: 14, fontWeight: FontWeight.w600, color: _kTextDark)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: _kTextLight, size: 18),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SAVE BAR
// ══════════════════════════════════════════════════════════════
class _SaveBar extends StatelessWidget {
  final bool saving; final VoidCallback? onSave;
  const _SaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: ScaleTap(
        onTap: onSave ?? () {},
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), _kPrimary]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.35),
                blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: saving
              ? const Center(child: SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5)))
              : const Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 7),
                Text('Save Changes', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TEARDROP PIN MARKER
// ══════════════════════════════════════════════════════════════
class _PinMarker extends StatelessWidget {
  final double size;
  const _PinMarker({this.size = 44});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.25),
      painter: _TearDropPainter(),
      child: SizedBox(
        width: size, height: size * 1.25,
        child: Align(
          alignment: const Alignment(0, -0.35),
          child: Container(
            width: size * 0.44, height: size * 0.44,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.storefront_rounded,
                color: _kPrimary, size: size * 0.26),
          ),
        ),
      ),
    );
  }
}

class _TearDropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final shadow = Paint()
      ..color      = _kPrimary.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w / 2, h - 4),
            width: w * 0.55, height: 8),
        shadow);
    final grad = Paint()
      ..shader = const LinearGradient(
        begin:  Alignment.topCenter,
        end:    Alignment.bottomCenter,
        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final path = Path();
    final r = w / 2;
    path.addOval(Rect.fromCircle(center: Offset(w / 2, r), radius: r));
    path.moveTo(w / 2 - r * 0.35, r * 1.55);
    path.quadraticBezierTo(w / 2, h, w / 2 + r * 0.35, r * 1.55);
    path.close();
    canvas.drawPath(path, grad);
    canvas.drawOval(
        Rect.fromCircle(center: Offset(w / 2, r), radius: r - 1.5),
        Paint()
          ..color       = Colors.white
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }
  @override
  bool shouldRepaint(_) => false;
}