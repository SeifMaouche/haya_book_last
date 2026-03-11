import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/provider_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_kit.dart';

// ─────────────────────────────────────────────────────────────
// SERVICE DATA per category
// ─────────────────────────────────────────────────────────────
List<Map<String, dynamic>> _servicesFor(String cat) {
  if (cat == 'Clinic') {
    return [
      {'name': 'General Consultation', 'icon': Icons.medical_services,       'price': 3000.0, 'duration': 30},
      {'name': 'Follow-up Visit',       'icon': Icons.history,                'price': 2000.0, 'duration': 20},
      {'name': 'Blood Test Panel',      'icon': Icons.biotech_outlined,       'price': 2500.0, 'duration': 15},
    ];
  } else if (cat == 'Salon') {
    return [
      {'name': 'Hair Cut & Style', 'icon': Icons.content_cut,         'price': 1500.0, 'duration': 45},
      {'name': 'Hair Coloring',    'icon': Icons.palette_outlined,    'price': 4000.0, 'duration': 90},
      {'name': 'Facial Treatment', 'icon': Icons.spa_outlined,        'price': 2500.0, 'duration': 60},
    ];
  } else {
    return [
      {'name': 'Math Tutoring',    'icon': Icons.calculate_outlined,  'price': 2000.0, 'duration': 60},
      {'name': 'Physics Tutoring', 'icon': Icons.science_outlined,    'price': 2000.0, 'duration': 60},
      {'name': 'Test Preparation', 'icon': Icons.task_alt_outlined,   'price': 3000.0, 'duration': 90},
    ];
  }
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
  Map<String, dynamic>? _selectedService;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedSlot;
  bool _isConfirming = false;

  // Time slots — 11:30 AM is fully booked
  static const List<Map<String, dynamic>> _allSlots = [
    {'time': '09:00 AM', 'available': true},
    {'time': '09:30 AM', 'available': true},
    {'time': '10:00 AM', 'available': true},
    {'time': '10:30 AM', 'available': true},
    {'time': '11:00 AM', 'available': true},
    {'time': '11:30 AM', 'available': false},
    {'time': '12:30 PM', 'available': true},
    {'time': '01:00 PM', 'available': true},
    {'time': '01:30 PM', 'available': true},
    {'time': '02:00 PM', 'available': true},
    {'time': '02:30 PM', 'available': true},
    {'time': '03:00 PM', 'available': true},
  ];

  int get _availableCount => _allSlots.where((s) => s['available'] == true).length;

  bool _isPast(DateTime d) => d.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  void _prevMonth() => setState(() =>
  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));
  void _nextMonth() => setState(() =>
  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  bool get _canConfirm =>
      _selectedService != null && _selectedDay != null && _selectedSlot != null && !_isConfirming;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    setState(() => _isConfirming = true);

    final bp = Provider.of<BookingProvider>(context, listen: false);
    bp.selectService(Service(
      id: (_selectedService!['name'] as String).toLowerCase().replaceAll(' ', '_'),
      name: _selectedService!['name'] as String,
      description: 'Duration: ${_selectedService!['duration']} mins',
      price: _selectedService!['price'] as double,
      durationMinutes: _selectedService!['duration'] as int,
    ));
    bp.selectDate(_selectedDay!);
    bp.selectTimeSlot(_selectedSlot!);

    final ok = await bp.createBooking('');
    if (!mounted) return;
    setState(() => _isConfirming = false);

    if (ok) {
      Navigator.of(context).pushReplacementNamed('/payment');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(bp.error ?? 'Booking failed. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context);
    final provider = bp.selectedProvider;
    final services = provider != null ? _servicesFor(provider.category) : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Glass header ─────────────────────────────────────
          _buildHeader(provider),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 1: Choose Service ──────────────
                  _buildSectionHeader('1. Choose Service',
                      trailing: _requiredBadge()),
                  const SizedBox(height: 14),
                  ...services.map((s) => _buildServiceCard(s)),

                  const SizedBox(height: 28),

                  // ── Section 2: Select Date ─────────────────
                  _buildSectionHeader('2. Select Date',
                      trailing: _monthLabel()),
                  const SizedBox(height: 14),
                  _buildCalendar(),

                  const SizedBox(height: 28),

                  // ── Section 3: Select Time ─────────────────
                  _buildSectionHeader('3. Select Time',
                      trailing: Text(
                        '$_availableCount slots available',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  const SizedBox(height: 14),
                  _buildTimeGrid(),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky bottom CTA ────────────────────────────────────
      bottomSheet: _buildBottomCTA(),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(ServiceProvider? provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        border: const Border(
            bottom: BorderSide(color: Color(0xFFE9ECEF))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              // Back button
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
              // Title
              Expanded(
                child: Column(
                  children: [
                    Text(
                      provider?.name ?? 'Book an Appointment',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Book an Appointment',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // More button
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
            ],
          ),
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
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3)),
          trailing,
        ],
      ),
    );
  }

  Widget _requiredBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text('REQUIRED',
        style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.primary)),
  );

  Widget _monthLabel() => GestureDetector(
    onTap: () {},
    child: Row(
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_focusedMonth),
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.calendar_month_outlined,
            size: 18, color: AppColors.textMuted),
      ],
    ),
  );

  // ── SERVICE CARD ──────────────────────────────────────────────
  Widget _buildServiceCard(Map<String, dynamic> s) {
    final selected = _selectedService?['name'] == s['name'];
    return GestureDetector(
      onTap: () => setState(() => _selectedService = s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          // Glass card effect
          color: Colors.white.withOpacity(selected ? 0.85 : 0.60),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.4)
                : Colors.white.withOpacity(0.4),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon square
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: selected ? Colors.white : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] as String,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.textDark
                                  : AppColors.textMuted)),
                      const SizedBox(height: 3),
                      Text(
                        'DZD ${(s['price'] as double).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Check icon top-right when selected
            if (selected)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 22),
              ),
          ],
        ),
      ),
    );
  }

  // ── CALENDAR ──────────────────────────────────────────────────
  Widget _buildCalendar() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // Mon-based offset (Mon=0)
    final startOffset = (first.weekday - 1) % 7;
    final daysInMonth = DateTimeRange(
      start: first,
      end: DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1),
    ).duration.inDays;

    return Container(
      decoration: _glassDecor(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          // Day-of-week headers (Mon first, matching screenshot)
          Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((d) => Expanded(
              child: Center(
                child: Text(d,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 0.3,
                    )),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Date grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, day);
              final disabled = _isPast(date);
              final selected = _selectedDay != null &&
                  _selectedDay!.year == date.year &&
                  _selectedDay!.month == date.month &&
                  _selectedDay!.day == date.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return GestureDetector(
                onTap: disabled
                    ? null
                    : () => setState(() {
                  _selectedDay = date;
                  _selectedSlot = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Text('$day',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : disabled
                              ? const Color(0xFFCDD5E0)
                              : isToday
                              ? AppColors.primary
                              : AppColors.textDark,
                        )),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── TIME GRID ─────────────────────────────────────────────────
  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _allSlots.length,
      itemBuilder: (_, i) {
        final slot = _allSlots[i];
        final t = slot['time'] as String;
        final avail = slot['available'] as bool;
        final sel = _selectedSlot == t;

        return GestureDetector(
          onTap: avail && _selectedDay != null
              ? () => setState(() => _selectedSlot = t)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: sel
                  ? Colors.white.withOpacity(0.85)
                  : avail
                  ? Colors.white.withOpacity(0.60)
                  : Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel
                    ? AppColors.primary.withOpacity(0.5)
                    : avail
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFFE2E8F0),
                width: sel ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(t,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: sel
                        ? AppColors.primary
                        : avail
                        ? AppColors.textDark
                        : const Color(0xFFCDD5E0),
                  )),
            ),
          ),
        );
      },
    );
  }

  // ── BOTTOM CTA ────────────────────────────────────────────────
  Widget _buildBottomCTA() {
    final price = _selectedService != null
        ? (_selectedService!['price'] as double)
        : 0.0;
    final priceStr =
        'DZD ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

    String dateStr = '—';
    if (_selectedDay != null && _selectedSlot != null) {
      dateStr =
      '${DateFormat('MMM d').format(_selectedDay!)}, $_selectedSlot';
    } else if (_selectedDay != null) {
      dateStr = DateFormat('MMM d').format(_selectedDay!);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price + date summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL PRICE',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(priceStr,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('SELECTED DATE',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(dateStr,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _canConfirm ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canConfirm
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.45),
                elevation: _canConfirm ? 4 : 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: _isConfirming
                  ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Confirm Booking',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
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
    color: Colors.white.withOpacity(0.60),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withOpacity(0.35)),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );
}