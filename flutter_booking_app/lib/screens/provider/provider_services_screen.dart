// lib/screens/provider/provider_services_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary    = Color(0xFF6B46C1);
const _kDeepViolet = Color(0xFF44337A);
const _kTextMuted  = Color(0xFF64748B);

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({Key? key}) : super(key: key);

  @override
  State<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      // Same consistent bg as all other screens
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [Color(0xFFEDE9FE), Color(0xFFF8F7FF)],
          ),
        ),
        child: Column(children: [
          _StickyHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _TabBar(controller: _tabs),
          ),
          Expanded(
            child: Consumer<ProviderStateProvider>(
              builder: (_, ps, __) => TabBarView(
                controller: _tabs,
                children: [
                  _ServiceList(services: ps.services),
                  _ServiceList(services: ps.services
                      .where((s) => s.isVisible && !s.isDraft).toList()),
                  _ServiceList(services: ps.services
                      .where((s) => s.isDraft).toList()),
                ],
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: _AddFab(),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 2),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STICKY GLASS HEADER
// ══════════════════════════════════════════════════════════════
class _StickyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.fromLTRB(14, top + 12, 14, 13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border(bottom: BorderSide(
                color: Colors.black.withOpacity(0.06), width: 0.5)),
          ),
          child: Row(children: [
            ScaleTap(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34, height: 34,
                child: const Icon(Icons.arrow_back_rounded,
                    color: _kPrimary, size: 22),
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(child: Text('My Services',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 17,
                  fontWeight: FontWeight.w700, color: _kDeepViolet,
                  letterSpacing: -0.2,
                ))),
            ScaleTap(
              onTap: () {},
              child: Container(width: 36, height: 36,
                  child: Icon(Icons.search_rounded,
                      color: _kPrimary, size: 21)),
            ),
            ScaleTap(
              onTap: () {},
              child: Container(width: 36, height: 36,
                  child: Icon(Icons.filter_list_rounded,
                      color: _kPrimary, size: 21)),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TAB BAR
// ══════════════════════════════════════════════════════════════
class _TabBar extends StatefulWidget {
  final TabController controller;
  const _TabBar({required this.controller});
  @override
  State<_TabBar> createState() => _TabBarState();
}

class _TabBarState extends State<_TabBar> {
  static const _labels = ['All', 'Active', 'Archived'];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        // White glass tab container — visible against lavender bg
        color:        Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.80), width: 1),
        boxShadow: [BoxShadow(
            color: _kPrimary.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(children: List.generate(3, (i) {
        final active = widget.controller.index == i;
        return Expanded(child: GestureDetector(
          onTap: () => widget.controller.animateTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? _kPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: active ? [BoxShadow(
                  color: _kPrimary.withOpacity(0.30),
                  blurRadius: 8, offset: const Offset(0, 3))] : [],
            ),
            child: Center(child: Text(_labels[i], style: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : _kPrimary.withOpacity(0.60),
            ))),
          ),
        ));
      })),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SERVICE LIST
// ══════════════════════════════════════════════════════════════
class _ServiceList extends StatelessWidget {
  final List<ProviderService> services;
  const _ServiceList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.70),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                  color: _kPrimary.withOpacity(0.10),
                  blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.content_cut_rounded,
                color: _kPrimary, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('No services found', style: TextStyle(
            fontFamily: 'Inter', fontSize: 14,
            fontWeight: FontWeight.w600, color: _kTextMuted,
          )),
        ],
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => FadeSlide(
        delay: Duration(milliseconds: i * 50),
        child: _ServiceCard(service: services[i]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SERVICE CARD  —  solid white bg for max visibility
// ══════════════════════════════════════════════════════════════
class _ServiceCard extends StatelessWidget {
  final ProviderService service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDraft = service.isDraft;

    return Opacity(
      opacity: isDraft ? 0.72 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          // Solid white — always clearly visible against any bg
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              // Stronger shadow so card pops off the lavender bg
              color:      _kPrimary.withOpacity(0.10),
              blurRadius: 18,
              offset:     const Offset(0, 5),
            ),
            const BoxShadow(
              color:      Colors.white,
              blurRadius: 0,
              offset:     Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Service image / placeholder ───────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColorFiltered(
                colorFilter: isDraft
                    ? const ColorFilter.matrix([
                  0.213,0.715,0.072,0,0,
                  0.213,0.715,0.072,0,0,
                  0.213,0.715,0.072,0,0,
                  0,0,0,1,0,
                ])
                    : const ColorFilter.mode(
                    Colors.transparent, BlendMode.multiply),
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: isDraft
                        ? Colors.grey.shade200
                        : const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: service.imageUrl != null &&
                      service.imageUrl!.isNotEmpty
                      ? Image.network(service.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(isDraft))
                      : _placeholder(isDraft),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Info ──────────────────────────────────────
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + DRAFT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text(service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDraft ? _kTextMuted : _kDeepViolet,
                          letterSpacing: -0.1,
                        ))),
                    if (isDraft) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1),
                        ),
                        child: const Text('DRAFT', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B), letterSpacing: 0.5,
                        )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                // Duration
                Row(children: [
                  Icon(Icons.schedule_outlined,
                      size: 11,
                      color: isDraft ? Colors.grey : _kPrimary.withOpacity(0.60)),
                  const SizedBox(width: 3),
                  Text('${service.durationMinutes} MINS',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDraft
                            ? Colors.grey
                            : _kPrimary.withOpacity(0.60),
                        letterSpacing: 0.8,
                      )),
                ]),
                const SizedBox(height: 4),
                // Price
                Text('DZD ${_fmt(service.price)}',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDraft ? _kTextMuted : _kPrimary,
                    )),
              ],
            )),

            // ── Actions ───────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScaleTap(
                  onTap: () => Navigator.pushNamed(
                      context, '/provider/add-service',
                      arguments: service),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.edit_rounded,
                        color: isDraft
                            ? Colors.grey.shade400 : _kPrimary,
                        size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                ScaleTap(
                  onTap: () => _confirmDelete(context),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(Icons.delete_outline_rounded,
                        color: isDraft
                            ? Colors.grey.shade400 : Colors.red,
                        size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isDraft) => Icon(
    Icons.content_cut_rounded,
    color: isDraft ? Colors.grey.shade400 : _kPrimary.withOpacity(0.45),
    size: 28,
  );

  String _fmt(double price) {
    final s = price.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Service', style: TextStyle(
          fontFamily: 'Inter', fontWeight: FontWeight.w800,
          color: _kDeepViolet)),
      content: Text('Remove "${service.name}" from your services?',
          style: const TextStyle(
              fontFamily: 'Inter', color: _kTextMuted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(fontFamily: 'Inter', color: _kTextMuted)),
        ),
        TextButton(
          onPressed: () {
            Provider.of<ProviderStateProvider>(context, listen: false)
                .deleteService(service.id);
            Navigator.pop(context);
          },
          child: const Text('Delete', style: TextStyle(
              fontFamily: 'Inter', color: Colors.red,
              fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }
}

// ══════════════════════════════════════════════════════════════
// FLOATING ADD BUTTON
// ══════════════════════════════════════════════════════════════
class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: () => Navigator.pushNamed(context, '/provider/add-service'),
      child: Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF44337A)],
          ),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withOpacity(0.70), width: 2.5),
          boxShadow: [BoxShadow(
              color: _kPrimary.withOpacity(0.40),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.add_rounded,
            color: Colors.white, size: 28),
      ),
    );
  }
}