// lib/screens/provider/provider_services_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary    = Color(0xFF7C3AED);
const _kDeepViolet = Color(0xFF1E1B4B);
const _kTextMuted  = Color(0xFF64748B);
const _kBorder     = Color(0xFFE2E8F0);

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _TabBar(controller: _tabs),
          ),
          const _GestureHint(),
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
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 3),
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
          padding: EdgeInsets.fromLTRB(24, top + 12, 14, 13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border(bottom: BorderSide(
                color: Colors.black.withOpacity(0.06), width: 0.5)),
          ),
          child: const Row(children: [
            Expanded(child: Text('My Services',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 17,
                  fontWeight: FontWeight.w700, color: _kDeepViolet,
                  letterSpacing: -0.2,
                ))),
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
    return Consumer<ProviderStateProvider>(
      builder: (_, ps, __) {
        final counts = [
          ps.services.length,
          ps.services.where((s) => s.isVisible && !s.isDraft).length,
          ps.services.where((s) => s.isDraft).length,
        ];

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.80), width: 1),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: List.generate(3, (i) {
              final active = widget.controller.index == i;
              final count = counts[i];

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.controller.animateTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? _kPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: _kPrimary.withOpacity(0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? Colors.white : _kPrimary.withOpacity(0.60),
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withOpacity(0.25)
                                  : _kPrimary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: active ? Colors.white : _kPrimary.withOpacity(0.60),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.content_cut_rounded,
                  color: _kPrimary, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('No Services found', style: TextStyle(
              fontFamily: 'Inter', fontSize: 16,
              fontWeight: FontWeight.w700, color: _kDeepViolet,
            )),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'List your professional services here so clients can book them instantly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w500, color: _kTextMuted.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
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

    return Dismissible(
      key: Key('service_${service.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.endToStart) {
          _confirmDelete(context);
        } else {
          Navigator.pushNamed(context, '/provider/add-service', arguments: service);
        }
        return false; // We handle actions via dialogs/navigation
      },
      background: _swipeBg(Icons.edit_rounded, 'EDIT', Alignment.centerLeft, _kPrimary),
      secondaryBackground: _swipeBg(Icons.delete_outline_rounded, 'DELETE', Alignment.centerRight, Colors.red),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image / Placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 72, height: 72,
                  color: _kPrimary.withOpacity(0.05),
                  child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                      ? Image.network(
                          service.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(isDraft),
                        )
                      : _placeholder(isDraft),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kDeepViolet,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isDraft) _draftBadge(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 12, color: _kTextMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${service.durationMinutes} minutes'.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _kTextMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DZD ${_fmt(service.price)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              // Simple edit indicator (like arrow in booking)
              Icon(Icons.chevron_right_rounded, color: _kTextMuted.withOpacity(0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swipeBg(IconData icon, String label, Alignment align, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: align,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontFamily: 'Inter', fontSize: 10,
            fontWeight: FontWeight.w800, color: color,
            letterSpacing: 0.5,
          )),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _kPrimary.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: _kPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _draftBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Original Amber
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFCD34D), width: 0.5),
      ),
      child: const Text('DRAFT', style: TextStyle(
        fontFamily: 'Inter', fontSize: 8,
        fontWeight: FontWeight.w900, color: Color(0xFFB45309),
      )),
    );
  }

  Widget _placeholder(bool isDraft) => Icon(
    Icons.content_cut_rounded,
    color: isDraft ? Colors.grey.shade400 : _kPrimary.withOpacity(0.40),
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
      backgroundColor: Colors.white,
      shadowColor: _kPrimary.withOpacity(0.2),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Delete Service', style: TextStyle(
          fontFamily: 'Inter', fontWeight: FontWeight.w900,
          color: _kDeepViolet, fontSize: 18)),
      content: Text('Remove "${service.name}" from your services?',
          style: const TextStyle(
              fontFamily: 'Inter', color: _kTextMuted, fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(fontFamily: 'Inter', color: _kTextMuted, fontWeight: FontWeight.w600)),
        ),
        ScaleTap(
          onTap: () async {
            await Provider.of<ProviderStateProvider>(context, listen: false)
                .deleteService(service.id);
            if (context.mounted) Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Delete', style: TextStyle(
                fontFamily: 'Inter', color: Colors.red,
                fontWeight: FontWeight.w800)),
          ),
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

// ══════════════════════════════════════════════════════════════
// GESTURE HINT  —  teaches user how to edit/delete
// ══════════════════════════════════════════════════════════════
class _GestureHint extends StatelessWidget {
  const _GestureHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimary.withOpacity(0.12), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swipe_rounded, size: 14, color: _kPrimary.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Swipe Right to Edit • Swipe Left to Delete',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kPrimary.withOpacity(0.8),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}