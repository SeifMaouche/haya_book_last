// lib/screens/provider/provider_bookings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_state.dart';
import '../../models/provider_models.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';

const _kPrimary     = Color(0xFF7C3AED);
const _kPrimaryDeep = Color(0xFF6D28D9);
const _kLavender    = Color(0xFFA78BFA);
const _kTextDark    = Color(0xFF1E1B4B);
const _kTextMuted   = Color(0xFF64748B);
const _kBorder      = Color(0xFFE2E8F0);
const _kGreen       = Color(0xFF16A34A);
const _kGreenBg     = Color(0xFFDCFCE7);
const _kRed         = Color(0xFFDC2626);
const _kRedBg       = Color(0xFFFEE2E2);

const double _kHourH = 80.0;

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderBookingsScreen> createState() =>
      _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _viewMode    = 0;
  int _selectedDay = DateTime.now().weekday - 1;
  late List<DateTime> _weekDates;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _tabCtrl      = TabController(length: 3, vsync: this);
    _weekDates    = _buildWeek(DateTime.now());
    _currentMonth = DateTime.now();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<DateTime> _buildWeek(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void _prevWeek() => setState(() {
    _weekDates    = _weekDates.map((d) => d.subtract(const Duration(days: 7))).toList();
    _currentMonth = _weekDates[0];
  });

  void _nextWeek() => setState(() {
    _weekDates    = _weekDates.map((d) => d.add(const Duration(days: 7))).toList();
    _currentMonth = _weekDates[0];
  });

  String _monthLabel(DateTime d) {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(children: [
          _StickyHeader(viewMode: _viewMode,
              onToggle: (v) => setState(() => _viewMode = v)),

          if (_viewMode == 1) ...[
            _MonthHeader(
              label:  _monthLabel(_weekDates[_selectedDay]),
              onPrev: _prevWeek,
              onNext: _nextWeek,
            ),
            _WeekRow(
              weekDates:   _weekDates,
              selectedDay: _selectedDay,
              onDayTap:    (i) => setState(() => _selectedDay = i),
            ),
          ],

          if (_viewMode == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _TabBar(controller: _tabCtrl),
            ),

          Expanded(
            child: _viewMode == 0
                ? TabBarView(
              controller: _tabCtrl,
              children: const [
                _UpcomingTab(),
                _CompletedTab(),
                _CancelledTab(),
              ],
            )
                : _ScheduleView(selectedDate: _weekDates[_selectedDay]),
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
  final int viewMode;
  final ValueChanged<int> onToggle;
  const _StickyHeader({required this.viewMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 13),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            border: Border(bottom: BorderSide(
                color: Colors.white.withOpacity(0.40))),
          ),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color:        _kPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  color: _kPrimary, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bookings', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 17,
                  fontWeight: FontWeight.w700, color: _kTextDark,
                  letterSpacing: -0.2,
                )),
                Text('PROVIDER DASHBOARD', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: _kPrimary,
                  letterSpacing: 1.5,
                )),
              ],
            )),
            _ViewToggle(viewMode: viewMode, onToggle: onToggle),
          ]),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final int viewMode;
  final ValueChanged<int> onToggle;
  const _ViewToggle({required this.viewMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kLavender.withOpacity(0.30), width: 1),
        boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        _ToggleBtn(icon: Icons.format_list_bulleted_rounded,
            label: 'List', isActive: viewMode == 0,
            onTap: () => onToggle(0)),
        const SizedBox(width: 3),
        _ToggleBtn(icon: Icons.calendar_today_rounded,
            label: 'Schedule', isActive: viewMode == 1,
            onTap: () => onToggle(1)),
      ]),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isActive;
  final VoidCallback onTap;
  const _ToggleBtn({required this.icon, required this.label,
    required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color:        isActive ? _kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive ? [BoxShadow(
              color: _kPrimary.withOpacity(0.30),
              blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(children: [
          Icon(icon, color: isActive ? Colors.white : _kTextMuted, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : _kTextMuted,
          )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MONTH HEADER + WEEK ROW
// ══════════════════════════════════════════════════════════════
class _MonthHeader extends StatelessWidget {
  final String label; final VoidCallback onPrev, onNext;
  const _MonthHeader({required this.label, required this.onPrev,
    required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(children: [
        Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 20,
          fontWeight: FontWeight.w800, color: _kTextDark,
          letterSpacing: -0.3,
        )),
        const Spacer(),
        _NavCircle(icon: Icons.chevron_left_rounded,  onTap: onPrev),
        const SizedBox(width: 8),
        _NavCircle(icon: Icons.chevron_right_rounded, onTap: onNext),
      ]),
    );
  }
}

class _NavCircle extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _NavCircle({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => ScaleTap(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.08),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, color: _kTextDark, size: 20),
    ),
  );
}

class _WeekRow extends StatelessWidget {
  final List<DateTime> weekDates;
  final int selectedDay;
  final ValueChanged<int> onDayTap;
  const _WeekRow({required this.weekDates, required this.selectedDay,
    required this.onDayTap});

  static const _dayNames = ['MON','TUE','WED','THU','FRI','SAT','SUN'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final isActive = i == selectedDay;
          final isToday  = weekDates[i].day   == DateTime.now().day &&
              weekDates[i].month == DateTime.now().month;
          return GestureDetector(
            onTap: () => onDayTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38, height: 62,
              decoration: BoxDecoration(
                color: isActive ? _kPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isActive ? [BoxShadow(
                    color: _kPrimary.withOpacity(0.35),
                    blurRadius: 12, offset: const Offset(0, 4))] : [],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dayNames[i], style: TextStyle(
                    fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white.withOpacity(0.80) : _kTextMuted,
                    letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 4),
                  Text('${weekDates[i].day}', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : isToday ? _kPrimary : _kTextDark,
                  )),
                  if (isToday && !isActive) ...[
                    const SizedBox(height: 3),
                    Container(width: 5, height: 5,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: _kPrimary)),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TAB BAR — 3 tabs
// ══════════════════════════════════════════════════════════════
class _TabBar extends StatefulWidget {
  final TabController controller;
  const _TabBar({required this.controller});
  @override
  State<_TabBar> createState() => _TabBarState();
}

class _TabBarState extends State<_TabBar> {
  static const _labels = ['Upcoming', 'Completed', 'Cancelled'];

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
        color:        Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.80), width: 1),
        boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: List.generate(3, (i) {
        final active = widget.controller.index == i;
        // Color accent per tab
        final Color activeColor = i == 2 ? _kRed : _kPrimary;
        return Expanded(child: GestureDetector(
          onTap: () => widget.controller.animateTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: active ? [BoxShadow(
                  color: activeColor.withOpacity(0.28),
                  blurRadius: 8, offset: const Offset(0, 3))] : [],
            ),
            child: Center(child: Text(_labels[i], style: TextStyle(
              fontFamily: 'Inter', fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.white : _kTextMuted,
            ))),
          ),
        ));
      })),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LIST TABS
// ══════════════════════════════════════════════════════════════
class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab();
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderStateProvider>(builder: (_, ps, __) {
      final bookings = ps.upcomingBookings;
      if (bookings.isEmpty) return const _EmptyState(
        icon:     Icons.calendar_today_outlined,
        title:    'No Upcoming Bookings',
        subtitle: 'Confirmed appointments will appear here',
      );
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: bookings.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return _SectionHeader(
            left:  'TODAY, ${_dateLabel(DateTime.now()).toUpperCase()}',
            right: '${bookings.length} BOOKINGS',
          );
          return _BookingCard(
            booking:    bookings[i - 1],
            badgeLabel: 'Confirmed',
            badgeColor: _kGreen,
            badgeBg:    _kGreenBg,
          );
        },
      );
    });
  }
}

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderStateProvider>(builder: (_, ps, __) {
      final bookings = ps.completedBookings;
      if (bookings.isEmpty) return const _EmptyState(
        icon:     Icons.check_circle_outline_rounded,
        title:    'No Completed Appointments',
        subtitle: 'Appointments you mark as done will appear here',
      );
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: bookings.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return _SectionHeader(
            left:  'COMPLETED',
            right: '${bookings.length} TOTAL',
          );
          return _BookingCard(
            booking:    bookings[i - 1],
            badgeLabel: 'Completed',
            badgeColor: _kTextMuted,
            badgeBg:    const Color(0xFFF1F5F9),
          );
        },
      );
    });
  }
}

class _CancelledTab extends StatelessWidget {
  const _CancelledTab();
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderStateProvider>(builder: (_, ps, __) {
      final bookings = ps.cancelledBookings;
      if (bookings.isEmpty) return const _EmptyState(
        icon:     Icons.cancel_outlined,
        title:    'No Cancelled Appointments',
        subtitle: 'Cancelled and no-show appointments will appear here',
      );

      // Split into two groups for visual separation
      final noShows   = bookings.where((b) => b.cancelReason == CancelReason.noShow).toList();
      final cancelled = bookings.where((b) => b.cancelReason != CancelReason.noShow).toList();

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          if (noShows.isNotEmpty) ...[
            _SectionHeader(
              left:       'NO-SHOWS',
              right:      '${noShows.length} TOTAL',
              leftColor:  _kRed,
            ),
            ...noShows.map((b) => _BookingCard(
              booking:    b,
              badgeLabel: 'No Show',
              badgeColor: _kRed,
              badgeBg:    _kRedBg,
              isNoShow:   true,
            )),
            if (cancelled.isNotEmpty) const SizedBox(height: 8),
          ],
          if (cancelled.isNotEmpty) ...[
            _SectionHeader(
              left:  'CANCELLED BY YOU',
              right: '${cancelled.length} TOTAL',
            ),
            ...cancelled.map((b) => _BookingCard(
              booking:    b,
              badgeLabel: 'Cancelled',
              badgeColor: _kRed,
              badgeBg:    _kRedBg,
            )),
          ],
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String  left;
  final String  right;
  final Color?  leftColor;
  const _SectionHeader({required this.left, required this.right,
    this.leftColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(
            fontFamily: 'Inter', fontSize: 10,
            fontWeight: FontWeight.w800,
            color: leftColor ?? _kTextMuted,
            letterSpacing: 1.4,
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        _kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _kPrimary.withOpacity(0.20)),
            ),
            child: Text(right, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, color: _kPrimary,
              letterSpacing: 0.8,
            )),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOOKING CARD  — unified card used by all three tabs
// ══════════════════════════════════════════════════════════════
class _BookingCard extends StatelessWidget {
  final ProviderBooking booking;
  final String          badgeLabel;
  final Color           badgeColor;
  final Color           badgeBg;
  final bool            isNoShow;

  const _BookingCard({
    required this.booking,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    this.isNoShow = false,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
            context, '/provider/booking-detail', arguments: b),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // Red left border for no-shows to make them stand out
            border: isNoShow
                ? Border(left: const BorderSide(color: _kRed, width: 4),
                top:    BorderSide(color: _kBorder),
                right:  BorderSide(color: _kBorder),
                bottom: BorderSide(color: _kBorder))
                : null,
            boxShadow: [BoxShadow(
                color: _kPrimary.withOpacity(0.07),
                blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            // ── Top row ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  isNoShow ? 10 : 14, 14, 14, 10),
              child: Row(children: [
                // Avatar
                Stack(children: [
                  ClipOval(child: Container(
                    width: 46, height: 46,
                    color: const Color(0xFFEDE9FE),
                    child: Icon(Icons.person_rounded,
                        color: isNoShow ? _kRed.withOpacity(0.60) : _kPrimary,
                        size: 23),
                  )),
                  if (b.clientOnline &&
                      b.status == ProviderBookingStatus.upcoming)
                    Positioned(bottom: 1, right: 1,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(width: 11),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.clientName, style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w700, color: _kTextDark,
                    )),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.schedule_rounded,
                          size: 11,
                          color: isNoShow ? _kRed : _kPrimary),
                      const SizedBox(width: 3),
                      Text(b.timeSlot, style: TextStyle(
                        fontFamily: 'Inter', fontSize: 11,
                        color: isNoShow ? _kRed.withOpacity(0.70) : _kTextMuted,
                      )),
                    ]),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('DZD ${b.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isNoShow ? _kTextMuted : _kPrimary,
                      )),
                  const SizedBox(height: 4),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (isNoShow) ...[
                        Icon(Icons.person_off_rounded,
                            size: 9, color: badgeColor),
                        const SizedBox(width: 3),
                      ],
                      Text(badgeLabel, style: TextStyle(
                        fontFamily: 'Inter', fontSize: 9,
                        fontWeight: FontWeight.w700, color: badgeColor,
                      )),
                    ]),
                  ),
                ]),
              ]),
            ),

            // ── Divider ───────────────────────────────────────
            Container(height: 1, color: const Color(0xFFF1F5F9)),

            // ── Bottom row ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  isNoShow ? 10 : 14, 9, 14, 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 10,
                          color: isNoShow ? _kRed : _kPrimary),
                      const SizedBox(width: 4),
                      Text(_shortDate(b.bookingDate), style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isNoShow ? _kRed : _kTextDark,
                      )),
                    ]),
                  ),
                  // No-show explanation text OR service name
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: isNoShow
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.info_outline_rounded,
                            size: 11,
                            color: _kRed.withOpacity(0.70)),
                        const SizedBox(width: 4),
                        Flexible(child: Text(
                          'Client did not show up',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 10,
                            color: _kRed.withOpacity(0.80),
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                      ])
                          : Text(b.serviceName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kTextDark,
                          )),
                    ),
                  ),
                  // Details chevron
                  const Row(children: [
                    Text('DETAILS', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11,
                      fontWeight: FontWeight.w800, color: _kPrimary,
                      letterSpacing: 0.5,
                    )),
                    Icon(Icons.chevron_right_rounded,
                        color: _kPrimary, size: 17),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SCHEDULE VIEW
// ══════════════════════════════════════════════════════════════
class _ScheduleView extends StatelessWidget {
  final DateTime selectedDate;
  const _ScheduleView({required this.selectedDate});

  static const _startHour = 8;
  static const _endHour   = 20;
  static const _hours     = _endHour - _startHour;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderStateProvider>(
      builder: (_, ps, __) {
        final dayBookings = ps.upcomingBookings.where((b) =>
        b.bookingDate.day   == selectedDate.day &&
            b.bookingDate.month == selectedDate.month).toList();

        final now      = DateTime.now();
        final isToday  = selectedDate.day   == now.day &&
            selectedDate.month == now.month;
        final double timeOffset = isToday
            ? ((now.hour - _startHour + now.minute / 60.0)
            .clamp(0.0, _hours.toDouble()) * _kHourH)
            : -1;

        return Stack(children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 12, 16, 130),
            physics: const BouncingScrollPhysics(),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 58,
                    child: Column(children: List.generate(_hours, (i) {
                      final h = _startHour + i;
                      return SizedBox(
                        height: _kHourH,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${h.toString().padLeft(2, '0')}:00',
                              style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _kTextMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    })),
                  ),
                  Expanded(child: SizedBox(
                    height: _hours * _kHourH,
                    child: Stack(children: [
                      Column(children: List.generate(_hours, (_) =>
                          Container(height: _kHourH,
                              decoration: BoxDecoration(
                                  border: Border(top: BorderSide(
                                      color: _kBorder.withOpacity(0.50),
                                      width: 1)))))),
                      ...dayBookings.map((b) => _ApptBlock(booking: b)),
                      if (isToday && timeOffset >= 0)
                        Positioned(
                          top: timeOffset, left: 0, right: 0,
                          child: Row(children: [
                            Container(width: 11, height: 11,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red)),
                            Expanded(child: Container(height: 2,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  boxShadow: [BoxShadow(
                                      color: Color(0x66FF0000),
                                      blurRadius: 4)],
                                ))),
                          ]),
                        ),
                    ]),
                  )),
                ]),
          ),
          Positioned(
            bottom: 82, left: 16, right: 16,
            child: Row(children: [
              Expanded(child: ScaleTap(
                onTap: () => Navigator.pushNamed(
                    context, '/provider/availability'),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                        color: _kPrimary.withOpacity(0.08),
                        blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block_rounded, color: _kPrimary, size: 18),
                      SizedBox(width: 8),
                      Text('Block Time', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w700, color: _kPrimary,
                      )),
                    ],
                  ),
                ),
              )),
              const SizedBox(width: 12),
              ScaleTap(
                onTap: () => Navigator.pushNamed(
                    context, '/provider/add-service'),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), _kPrimaryDeep]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                        color: _kPrimary.withOpacity(0.40),
                        blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ]),
          ),
        ]);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// APPOINTMENT BLOCK (schedule view)
// ══════════════════════════════════════════════════════════════
class _ApptBlock extends StatelessWidget {
  final ProviderBooking booking;
  const _ApptBlock({required this.booking});

  static int _parseHour(String slot) {
    final raw   = slot.toLowerCase();
    final parts = raw.replaceAll(RegExp(r'[apm ]'), '').split(':');
    int hour    = int.tryParse(parts.isNotEmpty ? parts[0] : '9') ?? 9;
    if (raw.contains('pm') && hour != 12) hour += 12;
    if (raw.contains('am') && hour == 12) hour = 0;
    return hour;
  }

  static double _durationH(ProviderBooking b) {
    try {
      final parts = b.timeSlot.split('-');
      if (parts.length < 2) return 1.0;
      final start = _parseMinutes(parts[0].trim());
      final end   = _parseMinutes(parts[1].trim());
      final diff  = end - start;
      return (diff > 0 ? diff : 60) / 60.0;
    } catch (_) { return 1.0; }
  }

  static int _parseMinutes(String t) {
    final lower = t.toLowerCase();
    final tp    = lower.replaceAll(RegExp(r'[apm ]'), '').split(':');
    int h       = int.tryParse(tp.isNotEmpty ? tp[0] : '9') ?? 9;
    final int m = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
    if (lower.contains('pm') && h != 12) h += 12;
    if (lower.contains('am') && h == 12) h = 0;
    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    final hour   = _parseHour(booking.timeSlot);
    final durH   = _durationH(booking);
    final top    = ((hour - _ScheduleView._startHour)
        .clamp(0, _ScheduleView._hours - 1)
        .toDouble()) * _kHourH;
    final height = (durH.clamp(0.5, 4.0) * _kHourH) - 4;

    return Positioned(
      top: top + 2, left: 4, right: 4,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
            context, '/provider/booking-detail', arguments: booking),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color:        _kPrimary.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left:   const BorderSide(color: _kPrimary, width: 4),
              top:    BorderSide(color: _kPrimary.withOpacity(0.15), width: 1),
              right:  BorderSide(color: _kPrimary.withOpacity(0.15), width: 1),
              bottom: BorderSide(color: _kPrimary.withOpacity(0.15), width: 1),
            ),
            boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.08),
                blurRadius: 8, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.serviceName,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w700, color: _kTextDark)),
                const SizedBox(height: 3),
                Text('${booking.clientName} • ${booking.timeSlot}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                        color: _kTextMuted.withOpacity(0.85))),
                if (height > 80) ...[
                  const SizedBox(height: 4),
                  Text('DZD ${booking.price.toStringAsFixed(0)}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary.withOpacity(0.80))),
                ],
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: _kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.30),
                        blurRadius: 6)]),
                child: const Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 14),
              ),
              if (height > 60) ...[
                const Spacer(),
                Container(width: 9, height: 9,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E))),
              ],
            ]),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title, subtitle;
  const _EmptyState({required this.icon, required this.title,
    required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.10),
                blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: _kPrimary, size: 30),
        ),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w700, color: _kTextDark)),
        const SizedBox(height: 5),
        Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: _kTextMuted)),
      ]),
    ));
  }
}

// ── Helpers ───────────────────────────────────────────────────
String _dateLabel(DateTime d)  => '${_monthName(d.month)} ${d.day}';
String _shortDate(DateTime d)  => '${_monthName(d.month)} ${d.day}, ${d.year}';
String _monthName(int m) => const [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
][m];