// lib/screens/provider/provider_availability_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary   = Color(0xFF6D28D9);
const _kTextDark  = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kTextLight = Color(0xFF94A3B8);

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends State<ProviderAvailabilityScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Provider.of<ProviderStateProvider>(context, listen: false)
        .saveSchedule();
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Availability saved!',
            style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: _kPrimary,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [Color(0xFFEDE9FE), Color(0xFFF8F7FF)],
          ),
        ),
        child: Stack(children: [
          Column(children: [
            _StickyHeader(topPad: pad.top),
            Expanded(
              child: Consumer<ProviderStateProvider>(
                builder: (_, ps, __) => ListView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, pad.bottom + 130),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Hero title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 18, 4, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HayaBook',
                              style: TextStyle(
                                fontFamily:    'Inter',
                                fontSize:      28,
                                fontWeight:    FontWeight.w900,
                                color:         _kTextDark,
                                letterSpacing: -0.5,
                              )),
                          const SizedBox(height: 3),
                          Text(
                            'Configure your working hours — add breaks whenever you need',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Day cards
                    ...List.generate(ps.schedule.length, (i) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FadeSlide(
                            delay: Duration(milliseconds: i * 40),
                            child: _DayCard(
                              dayIndex: i,
                              day:      ps.schedule[i],
                              onUpdate: (updated) =>
                                  ps.updateDaySchedule(i, updated),
                              onAddBlock:    () => ps.addBlockToDay(i),
                              onRemoveBlock: (bi) =>
                                  ps.removeBlockFromDay(i, bi),
                              onUpdateBlock: (bi, tb) =>
                                  ps.updateBlock(i, bi, tb),
                            ),
                          ),
                        ),
                    ),

                    // Footer note
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Tip: Add multiple blocks to schedule a lunch break or split shift',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: _kTextLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),

          // Save button
          Positioned(
            bottom: pad.bottom > 0 ? pad.bottom + 80 : 80,
            left: 16, right: 16,
            child: _SaveButton(
                saving: _saving,
                onTap:  _saving ? null : _save),
          ),
        ]),
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 1),
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
          padding: EdgeInsets.fromLTRB(14, topPad + 11, 14, 13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            border: Border(bottom: BorderSide(
                color: Colors.white.withOpacity(0.40), width: 1)),
          ),
          child: Row(children: [
            ScaleTap(
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 36, height: 36,
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: _kTextDark),
              ),
            ),
            const Expanded(
              child: Text('Weekly Schedule',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 16,
                    fontWeight: FontWeight.w700, color: _kTextDark,
                    letterSpacing: -0.2,
                  )),
            ),
            ScaleTap(
              onTap: () {
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 80, 20, 0),
                  items: [
                    const PopupMenuItem(
                      value: 'reset',
                      child: Row(children: [
                        Icon(Icons.refresh_rounded, size: 18, color: _kTextDark),
                        SizedBox(width: 10),
                        Text('Reset to Defaults', style: TextStyle(fontSize: 14)),
                      ]),
                    ),
                  ],
                ).then((value) {
                  if (value == 'reset') {
                     // We could call a method to reset here.
                  }
                });
              },
              child: const SizedBox(
                width: 36, height: 36,
                child: Icon(Icons.more_horiz_rounded,
                    size: 20, color: _kTextDark),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DAY CARD  —  supports multiple TimeBlocks
// ══════════════════════════════════════════════════════════════
class _DayCard extends StatelessWidget {
  final int                           dayIndex;
  final DaySchedule                   day;
  final ValueChanged<DaySchedule>     onUpdate;
  final VoidCallback                  onAddBlock;
  final ValueChanged<int>             onRemoveBlock;
  final void Function(int, TimeBlock) onUpdateBlock;

  const _DayCard({
    required this.dayIndex,
    required this.day,
    required this.onUpdate,
    required this.onAddBlock,
    required this.onRemoveBlock,
    required this.onUpdateBlock,
  });

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts  = current.trim().split(' ');
    final hm     = parts[0].split(':');
    int hour     = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPm   = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    if (isPm  && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour  = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: _kPrimary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );

    if (picked == null) return null;
    final h   = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final m   = picked.minute.toString().padLeft(2, '0');
    final per = picked.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $per';
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = day.isOpen;

    return AnimatedOpacity(
      opacity:  isOpen ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        isOpen ? Colors.white : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isOpen
              ? [BoxShadow(
              color:      _kPrimary.withOpacity(0.08),
              blurRadius: 16,
              offset:     const Offset(0, 4))]
              : [BoxShadow(
              color:      Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset:     const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: letter + name + toggle ───────
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isOpen
                      ? _kPrimary.withOpacity(0.10)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(day.letter,
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isOpen ? _kPrimary : Colors.grey,
                    ))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(day.day, style: TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isOpen ? _kTextDark : Colors.grey,
              ))),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value:              isOpen,
                  onChanged:          (v) => onUpdate(day.copyWith(isOpen: v)),
                  activeColor:        Colors.white,
                  activeTrackColor:   _kPrimary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.withOpacity(0.30),
                ),
              ),
            ]),

            // ── Unavailable label ─────────────────────────
            if (!isOpen)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(child: Text('UNAVAILABLE',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.8,
                    ))),
              ),

            // ── Time blocks ───────────────────────────────
            if (isOpen) ...[
              const SizedBox(height: 12),
              ...List.generate(day.blocks.length, (bi) => Column(
                children: [
                  _BlockRow(
                    blockIndex: bi,
                    block:      day.blocks[bi],
                    canRemove:  day.blocks.length > 1,
                    onPickStart: () async {
                      final t = await _pickTime(
                          context, day.blocks[bi].startTime);
                      if (t != null) {
                        onUpdateBlock(bi,
                            day.blocks[bi].copyWith(startTime: t));
                      }
                    },
                    onPickEnd: () async {
                      final t = await _pickTime(
                          context, day.blocks[bi].endTime);
                      if (t != null) {
                        onUpdateBlock(bi,
                            day.blocks[bi].copyWith(endTime: t));
                      }
                    },
                    onRemove: () => onRemoveBlock(bi),
                  ),

                  // Break pill between consecutive blocks
                  if (bi < day.blocks.length - 1)
                    _BreakPill(
                      before: day.blocks[bi].endTime,
                      after:  day.blocks[bi + 1].startTime,
                    ),
                ],
              )),

              const SizedBox(height: 10),

              // ── Add Block button ──────────────────────────
              GestureDetector(
                onTap: onAddBlock,
                child: Container(
                  width:   double.infinity,
                  height:  40,
                  decoration: BoxDecoration(
                    color:        _kPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _kPrimary.withOpacity(0.20), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          color: _kPrimary, size: 18),
                      SizedBox(width: 6),
                      Text('Add Time Block',
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kPrimary,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BLOCK ROW  —  one start/end pair with an optional remove button
// ══════════════════════════════════════════════════════════════
class _BlockRow extends StatelessWidget {
  final int          blockIndex;
  final TimeBlock    block;
  final bool         canRemove;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onRemove;

  const _BlockRow({
    required this.blockIndex,
    required this.block,
    required this.canRemove,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // Block number pill
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color:        _kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text('${blockIndex + 1}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ))),
          ),
          const SizedBox(width: 8),

          // Start time box
          Expanded(
            child: _TimeBox(
              label:  'START',
              time:   block.startTime,
              onTap:  onPickStart,
            ),
          ),
          const SizedBox(width: 8),

          // Arrow
          const Icon(Icons.arrow_forward_rounded,
              color: _kTextLight, size: 14),
          const SizedBox(width: 8),

          // End time box
          Expanded(
            child: _TimeBox(
              label: 'END',
              time:  block.endTime,
              onTap: onPickEnd,
            ),
          ),

          // Remove button
          if (canRemove) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color:        Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove_rounded,
                    color: Colors.red, size: 16),
              ),
            ),
          ] else
          // Keep alignment consistent when no remove button
            const SizedBox(width: 38),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BREAK PILL  —  shown between two consecutive blocks
// ══════════════════════════════════════════════════════════════
class _BreakPill extends StatelessWidget {
  final String before; // endTime of previous block
  final String after;  // startTime of next block

  const _BreakPill({required this.before, required this.after});

  int _toMinutes(String t) {
    final parts  = t.trim().split(' ');
    final hm     = parts[0].split(':');
    int hour     = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPm   = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    if (isPm  && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour  = 0;
    return hour * 60 + minute;
  }

  @override
  Widget build(BuildContext context) {
    final breakMins = _toMinutes(after) - _toMinutes(before);
    final label = breakMins > 0
        ? '☕  ${breakMins ~/ 60 > 0 ? '${breakMins ~/ 60}h ' : ''}'
        '${breakMins % 60 > 0 ? '${breakMins % 60}m ' : ''}break'
        : '⚠️  Overlap — check times';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Container(height: 1,
              color: const Color(0xFFE2E8F0))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        breakMins > 0
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: breakMins > 0
                    ? const Color(0xFFBBF7D0)
                    : const Color(0xFFFED7AA),
              ),
            ),
            child: Text(label,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: breakMins > 0
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFEA580C),
                )),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1,
              color: const Color(0xFFE2E8F0))),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TIME BOX  —  tappable time chip
// ══════════════════════════════════════════════════════════════
class _TimeBox extends StatelessWidget {
  final String       label;
  final String       time;
  final VoidCallback onTap;
  const _TimeBox({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _kTextLight, letterSpacing: 1.0,
        )),
        const SizedBox(height: 4),
        ScaleTap(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(
                  color:      _kPrimary.withOpacity(0.06),
                  blurRadius: 6,
                  offset:     const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: _kTextDark,
                )),
                const Icon(Icons.schedule_rounded,
                    color: _kPrimary, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SAVE BUTTON
// ══════════════════════════════════════════════════════════════
class _SaveButton extends StatelessWidget {
  final bool          saving;
  final VoidCallback? onTap;
  const _SaveButton({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap ?? () {},
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), _kPrimary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color:        _kPrimary.withOpacity(0.35),
              blurRadius:   20,
              offset:       const Offset(0, 8),
              spreadRadius: -2)],
        ),
        child: saving
            ? const Center(child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5)))
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, color: Colors.white, size: 19),
            SizedBox(width: 8),
            Text('Save Availability', style: TextStyle(
              fontFamily: 'Inter', fontSize: 15,
              fontWeight: FontWeight.w800, color: Colors.white,
            )),
          ],
        ),
      ),
    );
  }
}