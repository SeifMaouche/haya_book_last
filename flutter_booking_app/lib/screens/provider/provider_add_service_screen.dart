// lib/screens/provider/provider_add_service_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary    = Color(0xFF6D28D9);
const _kTextDark   = Color(0xFF1E1B4B);
const _kTextMuted  = Color(0xFF94A3B8);
const _kLabelGray  = Color(0xFF8B8FA8);

class ProviderAddServiceScreen extends StatefulWidget {
  final ProviderService? service;
  const ProviderAddServiceScreen({Key? key, this.service}) : super(key: key);

  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _ProviderAddServiceScreenState
    extends State<ProviderAddServiceScreen> {
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  int?  _selectedDuration;
  bool  _isVisible = true;
  bool  _saving    = false;

  static const _durations = [30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    final s = widget.service;
    if (s != null) {
      _nameCtrl.text    = s.name;
      _descCtrl.text    = s.description;
      _priceCtrl.text   = s.price.toStringAsFixed(0);
      _selectedDuration = s.durationMinutes;
      _isVisible        = s.isVisible;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final ps = Provider.of<ProviderStateProvider>(context, listen: false);
    final service = ProviderService(
      id:              widget.service?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name:            _nameCtrl.text.trim(),
      description:     _descCtrl.text.trim(),
      price:           double.tryParse(_priceCtrl.text) ?? 0,
      durationMinutes: _selectedDuration ?? 60,
      isVisible:       _isVisible,
    );
    if (widget.service == null) ps.addService(service);
    else ps.updateService(service);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        // Consistent bg across all screens
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [Color(0xFFEDE9FE), Color(0xFFF8F7FF)],
          ),
        ),
        child: Stack(children: [

          // ── Content ──────────────────────────────────
          Column(children: [
            SizedBox(height: pad.top),
            // Header
            _Header(),
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    18, 20, 18, pad.bottom + 130),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Icon preview ──────────────────
                    Center(child: FadeSlide(
                      delay: const Duration(milliseconds: 0),
                      child: GlassButton(
                        size:         88,
                        radius:       24,
                        tint:         Colors.white,
                        tintOpacity:  0.65,
                        child: const Icon(Icons.category_rounded,
                            color: _kPrimary, size: 40),
                      ),
                    )),
                    const SizedBox(height: 24),

                    // ── SERVICE NAME ──────────────────
                    FadeSlide(delay: const Duration(milliseconds: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('SERVICE NAME'),
                          const SizedBox(height: 7),
                          _Input(
                            controller: _nameCtrl,
                            hint:       'e.g. Deep Tissue Massage',
                            suffix:     Icon(Icons.edit_outlined,
                                color: _kPrimary.withOpacity(0.40), size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── DESCRIPTION ───────────────────
                    FadeSlide(delay: const Duration(milliseconds: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('DESCRIPTION'),
                          const SizedBox(height: 7),
                          _Input(
                            controller: _descCtrl,
                            hint:       'Describe what is included...',
                            maxLines:   5,
                            minHeight:  110,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── PRICE + DURATION ──────────────
                    FadeSlide(delay: const Duration(milliseconds: 100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('PRICE (DZD)'),
                              const SizedBox(height: 7),
                              _Input(
                                controller:  _priceCtrl,
                                hint:        '0.00',
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .allow(RegExp(r'[0-9.]')),
                                ],
                                suffix: Icon(Icons.payment_rounded,
                                    color: _kPrimary.withOpacity(0.40),
                                    size: 18),
                              ),
                            ],
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('DURATION'),
                              const SizedBox(height: 7),
                              _DurationPicker(
                                value:     _selectedDuration,
                                durations: _durations,
                                onChanged: (v) =>
                                    setState(() => _selectedDuration = v),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── VISIBILITY TOGGLE ─────────────
                    FadeSlide(delay: const Duration(milliseconds: 120),
                      child: _VisibilityToggle(
                        value:     _isVisible,
                        onChanged: (v) => setState(() => _isVisible = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),

          // ── Save button bar ───────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _SaveBar(
              saving:    _saving,
              onSave:    _saving ? null : _save,
              bottomPad: pad.bottom,
            ),
          ),
        ]),
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 2),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        // Glass circle back
        ScaleTap(
          onTap: () => Navigator.pop(context),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.60),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.70), width: 1),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: _kPrimary, size: 15),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Text('Add/Edit Service',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                fontWeight: FontWeight.w700, color: _kTextDark,
                letterSpacing: -0.2,
              )),
        ),
        const SizedBox(width: 38), // balance
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FIELD LABEL
// ══════════════════════════════════════════════════════════════
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 11,
      fontWeight: FontWeight.w600, color: _kLabelGray,
      letterSpacing: 0.8,
    ));
  }
}

// ══════════════════════════════════════════════════════════════
// INPUT FIELD  —  solid white for max readability
// ══════════════════════════════════════════════════════════════
class _Input extends StatelessWidget {
  final TextEditingController     controller;
  final String                    hint;
  final Widget?                   suffix;
  final int                       maxLines;
  final double                    minHeight;
  final TextInputType?            keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Input({
    required this.controller,
    required this.hint,
    this.suffix,
    this.maxLines   = 1,
    this.minHeight  = 50,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        // Solid white — always readable against any background
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFF6D28D9).withOpacity(0.07),
            blurRadius: 12,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller:       controller,
              maxLines:         maxLines,
              keyboardType:     keyboardType,
              inputFormatters:  inputFormatters,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14, color: _kTextDark,
              ),
              decoration: InputDecoration(
                hintText:  hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14, color: _kTextMuted,
                ),
                border:         InputBorder.none,
                enabledBorder:  InputBorder.none,
                focusedBorder:  InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(
                    16, maxLines > 1 ? 14 : 0,
                    10, maxLines > 1 ? 14 : 0),
                isDense: maxLines == 1,
              ),
            ),
          ),
          if (suffix != null)
            Padding(
              padding: EdgeInsets.only(
                  right: 14, top: maxLines > 1 ? 14 : 0),
              child: suffix!,
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DURATION PICKER  —  solid white dropdown
// ══════════════════════════════════════════════════════════════
class _DurationPicker extends StatelessWidget {
  final int?               value;
  final List<int>          durations;
  final ValueChanged<int?> onChanged;

  const _DurationPicker({
    required this.value,
    required this.durations,
    required this.onChanged,
  });

  String _label(int d) {
    if (d < 60) return '$d min';
    final h = d ~/ 60;
    final m = d % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color:      const Color(0xFF6D28D9).withOpacity(0.07),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value:        value,
          isExpanded:   true,
          borderRadius: BorderRadius.circular(14),
          hint: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('Select', style: TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: _kTextMuted,
            )),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: _kPrimary.withOpacity(0.60), size: 20),
          ),
          items: durations.map((d) => DropdownMenuItem<int>(
            value: d,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(_label(d), style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w500, color: _kTextDark,
              )),
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// VISIBILITY TOGGLE  —  solid white card
// ══════════════════════════════════════════════════════════════
class _VisibilityToggle extends StatelessWidget {
  final bool               value;
  final ValueChanged<bool> onChanged;
  const _VisibilityToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color:      const Color(0xFF6D28D9).withOpacity(0.07),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        // Eye icon square
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color:        _kPrimary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.visibility_outlined,
              color: _kPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visible to public', style: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              fontWeight: FontWeight.w700, color: _kTextDark,
            )),
            SizedBox(height: 1),
            Text('Allow customers to book this', style: TextStyle(
              fontFamily: 'Inter', fontSize: 11, color: _kLabelGray,
            )),
          ],
        )),
        // iOS toggle
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value:              value,
            onChanged:          onChanged,
            activeColor:        Colors.white,
            activeTrackColor:   _kPrimary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withOpacity(0.30),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SAVE BAR
// ══════════════════════════════════════════════════════════════
class _SaveBar extends StatelessWidget {
  final bool          saving;
  final VoidCallback? onSave;
  final double        bottomPad;
  const _SaveBar({required this.saving, required this.onSave,
    required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    // Sits above the bottom nav bar (~72px)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8F7FF).withOpacity(0.0),
            const Color(0xFFEDE9FE).withOpacity(0.95),
            const Color(0xFFEDE9FE),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, 12, 18, bottomPad + 82),
      child: ScaleTap(
        onTap: onSave ?? () {},
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withOpacity(0.20), width: 1),
            boxShadow: [BoxShadow(
                color:      _kPrimary.withOpacity(0.40),
                blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: saving
              ? const Center(child: SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5)))
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: 19),
              SizedBox(width: 8),
              Text('Save Service', style: TextStyle(
                fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w700, color: Colors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }
}