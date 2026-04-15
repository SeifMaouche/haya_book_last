import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_kit.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bp, _) {
        final last = bp.lastBooking;
        final providerName = last?.providerName ??
            bp.selectedProvider?.name ??
            'Provider Name & Medical Center';
        final serviceName =
            last?.serviceName ?? bp.selectedService?.name ?? 'General Consultation';
        final date = last?.bookingDate ?? bp.selectedDate;
        final time = last?.timeSlot ?? bp.selectedTimeSlot ?? '—';
        final price = last?.price ?? bp.selectedService?.price ?? 0.0;
        final bookingRef = last?.id ??
            'BK${DateTime.now().year}${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';
        final dateTimeStr = date != null
            ? '${DateFormat('MMM d').format(date)}, $time'
            : '—';

        // Light teal-grey background matching screenshot
        return Scaffold(
          backgroundColor: const Color(0xFFEEF3F3),
          body: SafeArea(
            child: Column(
              children: [
                // ── Top nav ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      // X button — teal
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/', (_) => false),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close,
                              color: AppColors.primary, size: 22),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Confirmation',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 34),
                    ],
                  ),
                ),

                // ── Glassmorphism card ───────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        // semi-transparent white glass
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.45)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),

                              // ── Animated check circle ────────
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration:
                                const Duration(milliseconds: 700),
                                curve: Curves.elasticOut,
                                builder: (_, v, child) =>
                                    Transform.scale(scale: v, child: child),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Blur glow halo
                                    Container(
                                      width: 116,
                                      height: 116,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.28),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // Teal circle with check
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF18C8B8),
                                            AppColors.primary,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.check,
                                            color: Colors.white, size: 50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Title ────────────────────────
                              const Text(
                                'Booking Confirmed!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                               Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Reference: ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '#$bookingRef',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // ── Booking detail inner card ────
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                    Colors.white.withOpacity(0.30),
                                    borderRadius:
                                    BorderRadius.circular(24),
                                    border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.50)),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        serviceName,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        providerName,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Divider(
                                        height: 1,
                                        color: Colors.black
                                            .withOpacity(0.07),
                                      ),
                                      const SizedBox(height: 16),
                                      // Date & Fee row
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Date & Time
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  color: AppColors.primary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        'DATE & TIME',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w800,
                                                          letterSpacing: 0.5,
                                                          color: AppColors.textMuted,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        dateTimeStr,
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.textDark,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Fee
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.payments,
                                                  color: AppColors.primary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text(
                                                        'FEE',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w800,
                                                          letterSpacing: 0.5,
                                                          color: AppColors.textMuted,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        'DZD ${price.toStringAsFixed(0)}',
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w800,
                                                          color: AppColors.textDark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // ── Actions ──────────────────────
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Column(
                                  children: [
                                    // View My Bookings button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/bookings',
                                                    (_) => false),
                                        icon: const Icon(
                                            Icons.event_note,
                                            color: Colors.white,
                                            size: 20),
                                        label: const Text(
                                          'View My Bookings',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          elevation: 0,
                                          shadowColor: AppColors.primary
                                              .withOpacity(0.3),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(18)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Go to Home text button
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, '/', (_) => false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                          Colors.white.withOpacity(0.1),
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                        child: const Text(
                                          'Go to Home',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}