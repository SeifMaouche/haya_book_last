import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widgets/bottom_nav_bar.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

// alias so app_router.dart can import MyBookingsScreen from here
typedef MyBookingsScreen = BookingsScreen;

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Cancel confirmation dialog ─────────────────────────────────
  Future<void> _confirmCancel(BuildContext ctx, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to cancel your ${booking.serviceName} appointment with ${booking.providerName}?',
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep It',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
              elevation: 0,
            ),
            child: const Text('Cancel Booking',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true && ctx.mounted) {
      final bp = Provider.of<BookingProvider>(ctx, listen: false);
      final ok = await bp.cancelBooking(booking.id);
      if (ok && ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Jump to Cancelled tab
        _tabController.animateTo(2);
      }
    }
  }

  // ── Reschedule bottom sheet ────────────────────────────────────
  Future<void> _openReschedule(BuildContext ctx, Booking booking) async {
    DateTime selectedDate = booking.bookingDate.isAfter(DateTime.now())
        ? booking.bookingDate
        : DateTime.now().add(const Duration(days: 1));
    String selectedSlot = booking.timeSlot;

    final timeSlots = [
      '09:00 AM', '09:30 AM', '10:30 AM', '11:00 AM',
      '11:30 AM', '12:00 PM', '01:00 PM', '01:30 PM',
      '02:00 PM', '03:00 PM', '03:30 PM', '04:00 PM',
      '04:30 PM', '05:00 PM',
    ];

    await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (_, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Reschedule Appointment',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(
                  '${booking.serviceName} · ${booking.providerName}',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Date picker button
                const Text('Select Date',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetCtx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate:
                      DateTime.now().add(const Duration(days: 60)),
                      builder: (_, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setModal(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy')
                              .format(selectedDate),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark),
                        ),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time slot picker
                const Text('Select Time',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeSlots.map((slot) {
                    final isSelected = slot == selectedSlot;
                    return GestureDetector(
                      onTap: () => setModal(() => selectedSlot = slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(slot,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      final bp =
                      Provider.of<BookingProvider>(ctx, listen: false);
                      final ok = await bp.rescheduleBooking(
                          booking.id, selectedDate, selectedSlot);
                      if (ok && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Rescheduled to ${DateFormat('MMM d').format(selectedDate)} at $selectedSlot',
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99)),
                      elevation: 0,
                    ),
                    child: const Text('Confirm Reschedule',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Bookings',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UpcomingTab(
            onCancel: (b) => _confirmCancel(context, b),
            onReschedule: (b) => _openReschedule(context, b),
          ),
          const _PastTab(),
          const _CancelledTab(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (i) => navigateToTab(context, i),
      ),
    );
  }
}

// ── UPCOMING TAB ───────────────────────────────────────────────────
class _UpcomingTab extends StatelessWidget {
  final void Function(Booking) onCancel;
  final void Function(Booking) onReschedule;

  const _UpcomingTab(
      {required this.onCancel, required this.onReschedule});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (_, bp, __) {
        final bookings = bp.getUpcomingBookings();
        if (bookings.isEmpty) {
          return _EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No Upcoming Bookings',
            subtitle: 'Book an appointment and it will appear here',
            actionLabel: 'Browse Providers',
            onAction: () => Navigator.pushNamed(context, '/browse'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: bookings.length,
          itemBuilder: (_, i) => _BookingCard(
            booking: bookings[i],
            type: _CardType.upcoming,
            onCancel: () => onCancel(bookings[i]),
            onReschedule: () => onReschedule(bookings[i]),
          ),
        );
      },
    );
  }
}

// ── PAST TAB ───────────────────────────────────────────────────────
class _PastTab extends StatelessWidget {
  const _PastTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (_, bp, __) {
        final bookings = bp.getPastBookings();
        if (bookings.isEmpty) {
          return const _EmptyState(
            icon: Icons.history,
            title: 'No Past Bookings',
            subtitle: 'Completed appointments will appear here',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: bookings.length,
          itemBuilder: (_, i) => _BookingCard(
            booking: bookings[i],
            type: _CardType.past,
          ),
        );
      },
    );
  }
}

// ── CANCELLED TAB ──────────────────────────────────────────────────
class _CancelledTab extends StatelessWidget {
  const _CancelledTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (_, bp, __) {
        final bookings = bp.getCancelledBookings();
        if (bookings.isEmpty) {
          return const _EmptyState(
            icon: Icons.cancel_outlined,
            title: 'No Cancelled Bookings',
            subtitle: 'Cancelled appointments will appear here',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: bookings.length,
          itemBuilder: (_, i) => _BookingCard(
            booking: bookings[i],
            type: _CardType.cancelled,
          ),
        );
      },
    );
  }
}

// ── BOOKING CARD ───────────────────────────────────────────────────
enum _CardType { upcoming, past, cancelled }

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final _CardType type;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const _BookingCard({
    required this.booking,
    required this.type,
    this.onCancel,
    this.onReschedule,
  });

  Color get _statusColor {
    switch (type) {
      case _CardType.upcoming:
        return AppColors.success;
      case _CardType.past:
        return AppColors.textMuted;
      case _CardType.cancelled:
        return AppColors.error;
    }
  }

  Color get _statusBg {
    switch (type) {
      case _CardType.upcoming:
        return const Color(0xFFDCFCE7);
      case _CardType.past:
        return const Color(0xFFF1F5F9);
      case _CardType.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }

  String get _statusLabel {
    switch (type) {
      case _CardType.upcoming:
        return 'Confirmed';
      case _CardType.past:
        return 'Completed';
      case _CardType.cancelled:
        return 'Cancelled';
    }
  }

  IconData get _categoryIcon {
    if (booking.providerName.toLowerCase().contains('salon')) {
      return Icons.content_cut;
    } else if (booking.providerName.toLowerCase().contains('tutor') ||
        booking.providerName.toLowerCase().contains('prof')) {
      return Icons.school_outlined;
    }
    return Icons.local_hospital_outlined;
  }

  List<Color> get _categoryColors {
    if (booking.providerName.toLowerCase().contains('salon')) {
      return [const Color(0xFFF97316), const Color(0xFFE55D00)];
    } else if (booking.providerName.toLowerCase().contains('tutor') ||
        booking.providerName.toLowerCase().contains('prof')) {
      return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
    }
    return [AppColors.primary, const Color(0xFF0A7A70)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Card header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Provider icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _categoryColors,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_categoryIcon,
                      color: Colors.white.withOpacity(0.85), size: 26),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.serviceName,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(booking.providerName,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textMuted)),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor)),
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────
          const Divider(height: 1, color: AppColors.cardBorder),

          // ── Date / Time / Price row ────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _infoChip(
                  Icons.calendar_today_outlined,
                  DateFormat('MMM d, yyyy').format(booking.bookingDate),
                ),
                const SizedBox(width: 8),
                _infoChip(Icons.access_time_outlined, booking.timeSlot),
                const Spacer(),
                Text(
                  'DZD ${booking.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),

          // ── Action buttons (upcoming only) ─────────────────
          if (type == _CardType.upcoming) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  // Reschedule
                  Expanded(
                    child: GestureDetector(
                      onTap: onReschedule,
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_calendar_outlined,
                                color: AppColors.primary, size: 16),
                            SizedBox(width: 6),
                            Text('Reschedule',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined,
                                color: AppColors.error, size: 16),
                            SizedBox(width: 6),
                            Text('Cancel',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Cancelled date ─────────────────────────────────
          if (type == _CardType.cancelled && booking.cancelledAt != null) ...[
            const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 13, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    'Cancelled on ${DateFormat('MMM d, yyyy').format(booking.cancelledAt!)}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}

// ── EMPTY STATE ────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.5)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  elevation: 0,
                ),
                child: Text(actionLabel!,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}