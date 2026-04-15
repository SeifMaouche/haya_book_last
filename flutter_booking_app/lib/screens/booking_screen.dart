import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/provider_model.dart';
import '../models/provider_models.dart';   // ← TimeBlock / DaySchedule
import '../models/booking_model.dart';     // ← TimeSlot
import '../providers/booking_provider.dart';

// ─────────────────────────────────────────────────────────────
// SERVICE DATA per category
// ─────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
// SERVICE ICON HELPER
// ─────────────────────────────────────────────────────────────
IconData _iconForService(String name, String category) {
  final n = name.toLowerCase();
  final c = category.toLowerCase();
  
  if (n.contains('hair') || n.contains('cut') || c.contains('salon')) return Icons.content_cut;
  if (n.contains('color') || n.contains('paint')) return Icons.palette_outlined;
  if (n.contains('facial') || n.contains('spa') || n.contains('skin')) return Icons.spa_outlined;
  if (n.contains('consult') || n.contains('medical') || c.contains('clinic')) return Icons.medical_services;
  if (n.contains('blood') || n.contains('test')) return Icons.biotech_outlined;
  if (n.contains('math')) return Icons.calculate_outlined;
  if (n.contains('physic') || n.contains('science')) return Icons.science_outlined;
  if (n.contains('tutor') || n.contains('class') || n.contains('teach')) return Icons.school_outlined;
  if (n.contains('law') || n.contains('legal')) return Icons.gavel;
  if (n.contains('fit') || n.contains('gym') || n.contains('coach')) return Icons.fitness_center;
  
  return Icons.miscellaneous_services; // Default
}

// ─────────────────────────────────────────────────────────────
// BOOKING SCREEN
// ─────────────────────────────────────────────────────────────
class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Service? _selectedService;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  String?   _selectedSlot;
  bool      _isConfirming = false;


  // ── Convert 'HH:mm' → minutes since midnight ─────────────────

  // ── Build available slots respecting provider schedule — CLIENT VERSION ───────
  List<TimeSlot> _getAvailableSlots() {
    return Provider.of<BookingProvider>(context).availableSlots;
  }


  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _availableCount => _getAvailableSlots().length;

  bool _isPast(DateTime d) => d.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  /// Returns true if this calendar date is within the provider's
  /// open schedule (used to dim closed days).
  bool _isDayOpen(DateTime d) {
    final bp = Provider.of<BookingProvider>(context, listen: false);
    final provider = bp.selectedProvider;
    if (provider == null) return false;
    
    final dayName = DateFormat('EEEE').format(d);
    final schedule = provider.workingHours.firstWhere(
      (h) => h.day.toLowerCase() == dayName.toLowerCase(),
      orElse: () => DaySchedule(day: dayName, letter: dayName[0], isOpen: false, blocks: []),
    );
    return schedule.isOpen;
  }

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    _resetIfOutOfMonth();
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    _resetIfOutOfMonth();
  });

  void _resetIfOutOfMonth() {
    if (_selectedDay != null &&
        (_selectedDay!.year != _focusedMonth.year ||
            _selectedDay!.month != _focusedMonth.month)) {
      _selectedDay = null;
      _selectedSlot = null;
    }
  }

  bool get _canConfirm =>
      _selectedService != null &&
          _selectedDay != null &&
          _selectedSlot != null &&
          !_isConfirming;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    setState(() => _isConfirming = true);

    final bp = Provider.of<BookingProvider>(context, listen: false);
    bp.selectService(_selectedService!);
    bp.selectDate(_selectedDay!);
    bp.selectTimeSlot(_selectedSlot!);

    final ok = await bp.createBooking('');
    if (!mounted) return;
    setState(() => _isConfirming = false);

    if (ok) {
      Navigator.of(context).pushReplacementNamed('/confirmation');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(bp.error ?? 'Booking failed. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bp       = Provider.of<BookingProvider>(context);
    final provider = bp.selectedProvider;
    final services = provider?.services ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(provider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1 — Choose Service
                  _buildSectionHeader('1. Choose Service',
                      trailing: _requiredBadge()),
                  const SizedBox(height: 14),
                  ...services.map((s) => _buildServiceCard(s, provider?.category ?? 'General')),

                  const SizedBox(height: 28),

                  // Section 2 — Select Date
                  _buildSectionHeader('2. Select Date',
                      trailing: _monthNavigator()),
                  const SizedBox(height: 14),
                  _buildCalendar(),

                  const SizedBox(height: 28),

                  // Section 3 — Select Time
                  _buildSectionHeader('3. Select Time',
                      trailing: Text(
                        '$_availableCount slots available',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          color:      AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  const SizedBox(height: 14),
                  _buildTimeSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomCTA(),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(ServiceProvider? provider) {
    return Container(
      decoration: BoxDecoration(
        color:  Colors.white.withOpacity(0.6),
        border: const Border(bottom: BorderSide(color: Color(0xFFE9ECEF))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back,
                      color: AppColors.textDark, size: 22),
                ),
              ),
            ),
            Expanded(
              child: Column(children: [
                Text(
                  provider?.name ?? 'Book an Appointment',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 16,
                    fontWeight: FontWeight.w800, color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text('Book an Appointment',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12,
                      fontWeight: FontWeight.w600, color: AppColors.primary,
                    )),
              ]),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.more_horiz,
                      color: AppColors.textDark, size: 22),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 20,
                fontWeight: FontWeight.w800, color: AppColors.textDark,
                letterSpacing: -0.3,
              )),
          trailing,
        ],
      ),
    );
  }

  Widget _requiredBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color:        AppColors.primaryLight,
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text('REQUIRED',
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 0.8,
          color: AppColors.primary,
        )),
  );

  Widget _monthNavigator() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color:        AppColors.primaryLight,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _prevMonth,
          child: const Icon(Icons.chevron_left,
              size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMMM yyyy').format(_focusedMonth),
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            fontWeight: FontWeight.w700, color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _nextMonth,
          child: const Icon(Icons.chevron_right,
              size: 18, color: AppColors.primary),
        ),
      ],
    ),
  );

  // ── SERVICE CARD ──────────────────────────────────────────────
  Widget _buildServiceCard(Service s, String category) {
    final selected = _selectedService?.id == s.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = s;
          _selectedSlot    = null; // Reset slot if service changes
        });
        final bp = Provider.of<BookingProvider>(context, listen: false);
        bp.selectService(s);
        // If date was already picked, this will refresh slots for the new service duration
        if (_selectedDay != null) {
          bp.selectDate(_selectedDay!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(selected ? 0.85 : 0.60),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.4)
                : Colors.white.withOpacity(0.4),
            width: selected ? 2 : 1,
          ),
          boxShadow: [BoxShadow(
            color:      selected
                ? AppColors.primary.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          )],
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : const Color(0xFFE9ECEF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_iconForService(s.name, category),
                    color: selected ? Colors.white : AppColors.textMuted,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.textDark : AppColors.textMuted,
                        )),
                    const SizedBox(height: 3),
                    Text(
                      'DZD ${s.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]},")}',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          if (selected)
            const Positioned(
              top: 10, right: 10,
              child: Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
            ),
        ]),
      ),
    );
  }

  // ── CALENDAR ──────────────────────────────────────────────────
  Widget _buildCalendar() {
    final first       = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startOffset = (first.weekday - 1) % 7;
    final daysInMonth = DateTimeRange(
      start: first,
      end:   DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1),
    ).duration.inDays;

    return Container(
      decoration: _glassDecor(),
      padding:    const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(children: [
        // Day-of-week headers
        Row(
          children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
              .map((d) => Expanded(
            child: Center(child: Text(d,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w700, color: AppColors.textLight,
                  letterSpacing: 0.3,
                ))),
          ))
              .toList(),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics:   const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, childAspectRatio: 1.0,
            mainAxisSpacing: 4, crossAxisSpacing: 4,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (_, i) {
            if (i < startOffset) return const SizedBox();
            final day     = i - startOffset + 1;
            final date    = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final isPast  = _isPast(date);
            // Days the provider has marked as closed are also un-tappable
            final isClosed = !_isDayOpen(date);
            final disabled = isPast || isClosed;

            final selected = _selectedDay != null && _isSameDay(_selectedDay!, date);
            final isToday  = _isSameDay(date, DateTime.now());

            return GestureDetector(
              onTap: disabled ? null : () => setState(() {
                _selectedDay  = date;
                _selectedSlot = null;
                // Wake up the provider to fetch real slots
                Provider.of<BookingProvider>(context, listen: false).selectDate(date);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected ? [BoxShadow(
                    color:      AppColors.primary.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 3),
                  )] : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('$day', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : disabled
                          ? const Color(0xFFCDD5E0)
                          : isToday
                          ? AppColors.primary
                          : AppColors.textDark,
                    )),
                    // Small dot under closed (but not past) days
                    if (isClosed && !isPast)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: 4, height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCDD5E0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Legend
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _dot(AppColors.primary),
          const SizedBox(width: 4),
          const Text('Today',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: AppColors.textMuted)),
          const SizedBox(width: 12),
          _dot(const Color(0xFFCDD5E0)),
          const SizedBox(width: 4),
          const Text('Provider closed',
              style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: AppColors.textMuted)),
        ]),
      ]),
    );
  }

  Widget _dot(Color c) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  // ── TIME SECTION (block-aware) ────────────────────────────────
  Widget _buildTimeSection() {
    if (_selectedDay == null) {
      return _emptySlotState(
        icon: Icons.calendar_today_outlined,
        message: 'Please select a date first',
        sub: null,
      );
    }

    final isDayOpen = _isDayOpen(_selectedDay!);
    if (!isDayOpen) {
      return _emptySlotState(
        icon: Icons.event_busy_outlined,
        message: 'Provider is closed on this day',
        sub: 'Please pick an open date',
      );
    }

    final slots = _getAvailableSlots();

    if (slots.isEmpty) {
      return _emptySlotState(
        icon: Icons.event_busy_outlined,
        message: 'No available slots for this date',
        sub: 'Please choose another date',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:  3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemCount:   slots.length,
          itemBuilder: (_, i) {
            final slot = slots[i];
            final t    = slot.time;
            final sel  = _selectedSlot == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white.withOpacity(0.85)
                      : Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                    width: sel ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(
                    color: sel
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )],
                ),
                child: Center(
                  child: Text(t, style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: sel ? AppColors.primary : AppColors.textDark,
                  )),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _emptySlotState({
    required IconData icon,
    required String   message,
    required String?  sub,
  }) {
    return Container(
      padding:    const EdgeInsets.all(32),
      decoration: _glassDecor(),
      child: Center(
        child: Column(children: [
          Icon(icon, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w600, color: AppColors.textMuted,
              )),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(sub,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  color: AppColors.textLight,
                )),
          ],
        ]),
      ),
    );
  }

  // ── BOTTOM CTA ────────────────────────────────────────────────
  Widget _buildBottomCTA() {
    final price    = _selectedService?.price ?? 0.0;
    final priceStr =
        'DZD ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

    String dateStr = '—';
    if (_selectedDay != null && _selectedSlot != null) {
      dateStr = '${DateFormat('MMM d').format(_selectedDay!)}, $_selectedSlot';
    } else if (_selectedDay != null) {
      dateStr = DateFormat('MMM d').format(_selectedDay!);
    }

    return Container(
      margin:  const EdgeInsets.fromLTRB(12, 0, 12, 0),
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28), topRight: Radius.circular(28),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [BoxShadow(
          color:      AppColors.primary.withOpacity(0.06),
          blurRadius: 24,
          offset:     const Offset(0, -4),
        )],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('TOTAL PRICE',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w600, letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      )),
                  const SizedBox(height: 2),
                  Text(priceStr,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 20,
                        fontWeight: FontWeight.w800, color: AppColors.textDark,
                      )),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('SELECTED DATE',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w600, letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      )),
                  const SizedBox(height: 2),
                  Text(dateStr,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w700, color: AppColors.primary,
                      )),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity, height: 58,
            child: ElevatedButton(
              onPressed: _canConfirm ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canConfirm
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.45),
                elevation:   _canConfirm ? 4 : 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: _isConfirming
                  ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confirm Booking',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _glassDecor() => BoxDecoration(
    color:        Colors.white.withOpacity(0.60),
    borderRadius: BorderRadius.circular(28),
    border:       Border.all(color: Colors.white.withOpacity(0.35)),
    boxShadow: [BoxShadow(
      color:      AppColors.primary.withOpacity(0.05),
      blurRadius: 20,
      offset:     const Offset(0, 6),
    )],
  );
}