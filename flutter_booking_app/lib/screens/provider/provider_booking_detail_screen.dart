// lib/screens/provider/provider_booking_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary     = Color(0xFF7C3AED);
const _kPrimaryDeep = Color(0xFF6D28D9);
const _kDeepViolet  = Color(0xFF2D0A5A);
const _kTextMuted   = Color(0xFF64748B);
const _kTextLight   = Color(0xFF94A3B8);

class ProviderBookingDetailScreen extends StatefulWidget {
  final ProviderBooking booking;
  const ProviderBookingDetailScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  State<ProviderBookingDetailScreen> createState() =>
      _ProviderBookingDetailScreenState();
}

class _ProviderBookingDetailScreenState
    extends State<ProviderBookingDetailScreen> {
  bool _completing = false;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    await Provider.of<ProviderStateProvider>(context, listen: false)
        .completeBooking(widget.booking.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _CancelDialog(
        clientName:  widget.booking.clientName,
        serviceName: widget.booking.serviceName,
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    await Provider.of<ProviderStateProvider>(context, listen: false)
        .cancelBooking(widget.booking.id);
    if (mounted) Navigator.pop(context);
  }

  String _statusLabel() {
    switch (widget.booking.status) {
      case ProviderBookingStatus.upcoming:  return 'Confirmed';
      case ProviderBookingStatus.completed: return 'Completed';
      case ProviderBookingStatus.cancelled: return 'Cancelled';
    }
  }

  Color _statusColor() {
    switch (widget.booking.status) {
      case ProviderBookingStatus.upcoming:  return const Color(0xFF16A34A);
      case ProviderBookingStatus.completed: return _kTextMuted;
      case ProviderBookingStatus.cancelled: return const Color(0xFFDC2626);
    }
  }

  Color _statusBg() {
    switch (widget.booking.status) {
      case ProviderBookingStatus.upcoming:  return const Color(0xFFDCFCE7);
      case ProviderBookingStatus.completed: return const Color(0xFFF1F5F9);
      case ProviderBookingStatus.cancelled: return const Color(0xFFFEE2E2);
    }
  }

  String _dateLabel(DateTime d) {
    const days   = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday - 1]}, ${months[d.month]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final b          = widget.booking;
    final pad        = MediaQuery.of(context).padding;
    final isUpcoming = b.status == ProviderBookingStatus.upcoming;
    final isBusy     = _completing || _cancelling;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(topPad: pad.top)),
              SliverToBoxAdapter(
                child: Padding(
                  // Extra bottom padding so content clears the taller action bar
                  padding: EdgeInsets.fromLTRB(
                      20, 20, 20, pad.bottom + 160),
                  child: Column(children: [
                    FadeSlide(
                      delay: const Duration(milliseconds: 0),
                      child: _ClientSection(
                        booking:     b,
                        statusLabel: _statusLabel(),
                        statusColor: _statusColor(),
                        statusBg:    _statusBg(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlide(
                      delay: const Duration(milliseconds: 80),
                      child: _DetailsCard(
                          booking: b, dateLabel: _dateLabel(b.bookingDate)),
                    ),
                    const SizedBox(height: 18),
                    if (b.notes != null) ...[
                      FadeSlide(
                        delay: const Duration(milliseconds: 120),
                        child: _SectionLabel(left: 'CONSULTATION NOTES'),
                      ),
                      const SizedBox(height: 8),
                      FadeSlide(
                        delay: const Duration(milliseconds: 140),
                        child: _NotesCard(notes: b.notes!),
                      ),
                      const SizedBox(height: 18),
                    ],
                    FadeSlide(
                      delay: const Duration(milliseconds: 160),
                      child: _SectionLabel(
                          left: 'LOCATION', right: 'Algiers, DZ'),
                    ),
                    const SizedBox(height: 8),
                    FadeSlide(
                      delay: const Duration(milliseconds: 180),
                      child: _MapPlaceholder(),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── Bottom action bar ─────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomBar(
              completing: _completing,
              cancelling: _cancelling,
              isBusy:     isBusy,
              isUpcoming: isUpcoming,
              onMessage:  () => Navigator.pushNamed(context, '/messages'),
              onComplete: (isUpcoming && !isBusy) ? _complete : null,
              onCancel:   (isUpcoming && !isBusy) ? _cancel   : null,
              bottomPad:  pad.bottom,
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CANCEL CONFIRMATION DIALOG
// ══════════════════════════════════════════════════════════════
class _CancelDialog extends StatelessWidget {
  final String clientName;
  final String serviceName;
  const _CancelDialog(
      {required this.clientName, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Warning icon
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded,
                color: Color(0xFFDC2626), size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Cancel Appointment',
              style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    18,
                fontWeight:  FontWeight.w800,
                color:       _kDeepViolet,
              )),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to cancel $clientName\'s '
                '$serviceName appointment? '
                'They will be notified immediately.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize:   13,
              height:     1.55,
              color:      _kTextMuted,
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            // Keep it
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color:        const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Center(child: Text('Keep It',
                    style: TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    14,
                      fontWeight:  FontWeight.w700,
                      color:       _kDeepViolet,
                    ))),
              ),
            )),
            const SizedBox(width: 10),
            // Yes, cancel
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color:        const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [BoxShadow(
                      color:      const Color(0xFFDC2626).withOpacity(0.30),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Text('Yes, Cancel',
                    style: TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    14,
                      fontWeight:  FontWeight.w700,
                      color:       Colors.white,
                    ))),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final double topPad;
  const _Header({required this.topPad});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            border: Border(bottom: BorderSide(
                color: Colors.white.withOpacity(0.40), width: 1)),
          ),
          child: Row(children: [
            _HeaderBtn(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _kPrimary, size: 16),
            ),
            const Expanded(child: Text('Appointment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 16,
                  fontWeight: FontWeight.w700, color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ))),
            _HeaderBtn(
              onTap: () {},
              child: const Icon(Icons.more_horiz_rounded,
                  color: _kPrimary, size: 20),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget       child;
  const _HeaderBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.70),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CLIENT SECTION
// ══════════════════════════════════════════════════════════════
class _ClientSection extends StatelessWidget {
  final ProviderBooking booking;
  final String          statusLabel;
  final Color           statusColor;
  final Color           statusBg;
  const _ClientSection({
    required this.booking,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 108, height: 108,
          decoration: BoxDecoration(
            color:  const Color(0xFFEDE9FE),
            shape:  BoxShape.circle,
            border: Border.all(
                color: Colors.white.withOpacity(0.85), width: 5),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.person_rounded,
              color: _kPrimary, size: 50),
        ),
        if (booking.clientOnline)
          Positioned(bottom: 4, right: 5,
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.40),
                    blurRadius: 6)],
              ),
            ),
          ),
      ]),
      const SizedBox(height: 12),
      Text(booking.clientName, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 20,
        fontWeight: FontWeight.w800, color: _kDeepViolet,
        letterSpacing: -0.3,
      )),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.verified_rounded, color: _kPrimary, size: 13),
        const SizedBox(width: 4),
        Text('Premium Client • ${booking.serviceName}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12,
              fontWeight: FontWeight.w600, color: _kPrimary,
            )),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(statusLabel, style: TextStyle(
          fontFamily: 'Inter', fontSize: 12,
          fontWeight: FontWeight.w700, color: statusColor,
        )),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// DETAILS CARD
// ══════════════════════════════════════════════════════════════
class _DetailsCard extends StatelessWidget {
  final ProviderBooking booking;
  final String          dateLabel;
  const _DetailsCard({required this.booking, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      radius: 20,
      tint: _kPrimary,
      tintOpacity: 0.08,
      blur: 20,
      borderOpacity: 0.15,
      padding: const EdgeInsets.all(18),
      shadows: [BoxShadow(
          color: _kPrimary.withOpacity(0.06),
          blurRadius: 20, offset: const Offset(0, 6))],
      child: Column(children: [
        _DetailRow(
          icon:  Icons.calendar_today_rounded,
          label: 'DATE & TIME',
          value: dateLabel,
          sub:   booking.timeSlot,
        ),
        _GradientDivider(),
        _DetailRow(
          icon:  Icons.work_rounded,
          label: 'SERVICE TYPE',
          value: booking.serviceName,
          sub:   'Beauty Service',
        ),
        _GradientDivider(),
        _DetailRow(
          icon:      Icons.payments_rounded,
          label:     'FINANCIALS',
          value:     'DZD ${booking.price.toStringAsFixed(0)}',
          subWidget: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF16A34A), size: 13),
            const SizedBox(width: 4),
            const Text('Payment Secured via HayaBook',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Color(0xFF16A34A),
                )),
          ]),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final String?  sub;
  final Widget?  subWidget;
  const _DetailRow({required this.icon, required this.label,
    required this.value, this.sub, this.subWidget});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: _kPrimary, size: 19),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 9,
            fontWeight: FontWeight.w800, color: _kTextLight,
            letterSpacing: 1.5,
          )),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14,
            fontWeight: FontWeight.w700, color: _kDeepViolet,
          )),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, color: _kTextMuted,
            )),
          ],
          if (subWidget != null) ...[
            const SizedBox(height: 3),
            subWidget!,
          ],
        ],
      )),
    ]);
  }
}

class _GradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          _kPrimary.withOpacity(0.15),
          Colors.transparent,
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String  left;
  final String? right;
  const _SectionLabel({required this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 10,
          fontWeight: FontWeight.w800, color: _kTextLight,
          letterSpacing: 2.0,
        )),
        if (right != null)
          Text(right!, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 10,
            fontWeight: FontWeight.w700, color: _kPrimary,
          )),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      radius: 16,
      tint: Colors.white,
      tintOpacity: 0.65,
      blur: 25,
      borderOpacity: 0.60,
      padding: const EdgeInsets.all(16),
      shadows: [BoxShadow(
          color: _kPrimary.withOpacity(0.05),
          blurRadius: 16, offset: const Offset(0, 4))],
      child: Text(notes, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 13,
        height: 1.60, color: Color(0xFF475569),
      )),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: _kPrimary.withOpacity(0.07),
              blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(painter: _MapGridPainter(),
              child: const SizedBox.expand()),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kPrimary, shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: _kPrimary.withOpacity(0.40),
                  blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: const Icon(Icons.location_on_rounded,
                color: Colors.white, size: 22),
          ),
        ]),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.grey.withOpacity(0.20)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
// BOTTOM BAR
// Upcoming    → [Message]  [Mark Complete]
//               [   Cancel Appointment   ]
// Past/cancelled → [Message Client]
// ══════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final bool          completing;
  final bool          cancelling;
  final bool          isBusy;
  final bool          isUpcoming;
  final VoidCallback  onMessage;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final double        bottomPad;

  const _BottomBar({
    required this.completing,
    required this.cancelling,
    required this.isBusy,
    required this.isUpcoming,
    required this.onMessage,
    required this.onComplete,
    required this.onCancel,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, bottomPad > 0 ? bottomPad + 6 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            border: Border(top: BorderSide(
                color: Colors.white.withOpacity(0.60), width: 1)),
          ),
          child: isUpcoming
              ? Column(mainAxisSize: MainAxisSize.min, children: [
            // ── Row 1: Message + Mark Complete ──────────────
            Row(children: [
              Expanded(child: ScaleTap(
                onTap: isBusy ? () {} : onMessage,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _kPrimary.withOpacity(0.15), width: 1),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_rounded,
                          color: _kPrimary, size: 16),
                      SizedBox(width: 6),
                      Text('Message', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w700, color: _kPrimary,
                      )),
                    ],
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: ScaleTap(
                onTap: onComplete ?? () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isBusy
                          ? [Colors.grey.shade300, Colors.grey.shade400]
                          : const [Color(0xFF8B5CF6), _kPrimaryDeep],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isBusy ? [] : [BoxShadow(
                        color: _kPrimary.withOpacity(0.35),
                        blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: completing
                      ? const Center(child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 7),
                      Text('Mark Complete', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                    ],
                  ),
                ),
              )),
            ]),
            const SizedBox(height: 10),
            // ── Row 2: Cancel Appointment (full width) ───────
            ScaleTap(
              onTap: onCancel ?? () {},
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isBusy
                      ? const Color(0xFFFEE2E2).withOpacity(0.50)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFDC2626).withOpacity(0.25),
                      width: 1),
                ),
                child: cancelling
                    ? const Center(child: SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        color: Color(0xFFDC2626), strokeWidth: 2)))
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined,
                        color: isBusy
                            ? const Color(0xFFDC2626).withOpacity(0.40)
                            : const Color(0xFFDC2626),
                        size: 17),
                    const SizedBox(width: 7),
                    Text('Cancel Appointment', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isBusy
                          ? const Color(0xFFDC2626).withOpacity(0.40)
                          : const Color(0xFFDC2626),
                    )),
                  ],
                ),
              ),
            ),
          ])
          // Past / cancelled — message only
              : ScaleTap(
            onTap: onMessage,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_rounded,
                      color: _kPrimary, size: 16),
                  SizedBox(width: 8),
                  Text('Message Client', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w700, color: _kPrimary,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}