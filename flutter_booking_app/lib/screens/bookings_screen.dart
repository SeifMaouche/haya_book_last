import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../widgets/glass_kit.dart';
import '../widgets/haya_avatar.dart';

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
    
    // Fetch user bookings on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchUserBookings();
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      '09:00', '09:30', '10:30', '11:00',
      '11:30', '12:00', '13:00', '13:30',
      '14:00', '15:00', '15:30', '16:00',
      '16:30', '17:00',
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
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      builder: (_, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setModal(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark),
                        ),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                        ),
                        child: Text(slot,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textDark)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      final bp = Provider.of<BookingProvider>(ctx, listen: false);
                      final ok = await bp.rescheduleBooking(booking.id, selectedDate, selectedSlot);
                      if (ok && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Rescheduled to ${DateFormat('MMM d').format(selectedDate)} at $selectedSlot'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
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
      body: Column(
        children: [
          GlassHeader(
            title: 'My Bookings',
            subtitle: 'Manage your appointments',
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
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
          ),
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

  const _UpcomingTab({required this.onCancel, required this.onReschedule});

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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          itemCount: bookings.length,
          itemBuilder: (_, i) => FadeSlide(
            delay: Duration(milliseconds: 50 * i),
            child: _BookingCard(
              booking: bookings[i],
              type: _CardType.upcoming,
              onCancel: () => onCancel(bookings[i]),
              onReschedule: () => onReschedule(bookings[i]),
            ),
          ),
        );
      },
    );
  }
}

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

  String get _statusLabel {
    if (booking.status.toUpperCase() == 'IN_PROGRESS') return 'In Session';
    switch (type) {
      case _CardType.upcoming: return 'Confirmed';
      case _CardType.past: return 'Completed';
      case _CardType.cancelled: return 'Cancelled';
    }
  }

  Color get _statusColor {
    if (booking.status.toUpperCase() == 'IN_PROGRESS') return Colors.orangeAccent;
    switch (type) {
      case _CardType.upcoming: return AppColors.success;
      case _CardType.past: return AppColors.textMuted;
      case _CardType.cancelled: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24), // Balanced separation
      child: GlassBox(
        radius: 18, // Crisper iOS 26 style
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Tighter vertical
        tintOpacity: 0.85, // Thick glass look for better contrast
        borderOpacity: 0.8, // Sharp "crystalline" edge
        blur: 30, // Deep frosted effect
        child: Column(
          children: [
            Row(
              children: [
                // Instant & Robust Global Avatar System
                HayaAvatar(
                  avatarUrl: booking.providerAvatar,
                  size: 44,
                  isProvider: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14, // Compact font
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 1), // Minimal vertical gap
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 4, color: AppColors.primary), // Decorative bullet
                          const SizedBox(width: 6),
                          Text(
                            booking.providerName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11, // Tiny but readable
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: _statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    _statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8, // Very compact status
                      fontWeight: FontWeight.w900,
                      color: _statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Tightened spacing
            Row(
              children: [
                _modernInfoChip(Icons.calendar_today_rounded, DateFormat('EEE, MMM d').format(booking.bookingDate)),
                const SizedBox(width: 6),
                _modernInfoChip(Icons.access_time_filled_rounded, booking.timeSlot),
                const Spacer(),
                Text(
                  'DZD ${booking.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15, // Compact price
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            if (type == _CardType.upcoming) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ScaleTap(
                      onTap: onReschedule ?? () {},
                      child: Container(
                        height: 36, // Ultra-compact buttons
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.5)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 14),
                            SizedBox(width: 4),
                            Text('Reschedule',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ScaleTap(
                      onTap: onCancel ?? () {},
                      child: Container(
                        height: 36, // Ultra-compact buttons
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withOpacity(0.15)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded, color: AppColors.error, size: 14),
                            SizedBox(width: 4),
                            Text('Cancel',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (type == _CardType.cancelled && booking.cancelledAt != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text('Cancelled ${DateFormat('MMM d').format(booking.cancelledAt!)}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modernInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}



class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({required this.icon, required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      dy: 10,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassBox(radius: 32, tintOpacity: 0.1, padding: const EdgeInsets.all(24), child: Icon(icon, size: 48, color: AppColors.primary.withOpacity(0.5))),
              const SizedBox(height: 28),
              Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
              const SizedBox(height: 10),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMuted.withOpacity(0.7), height: 1.5)),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 32),
                ScaleTap(
                  onTap: onAction!,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), // Slightly tighter
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), AppColors.primary]),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Text(actionLabel!, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}