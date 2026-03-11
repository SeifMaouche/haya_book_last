import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_card.dart';
import 'booking_details_screen.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: allBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: AppTheme.borderColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book an appointment with a doctor',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.mediumGrayColor,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allBookings.length,
              itemBuilder: (context, index) {
                final booking = allBookings[index];
                return BookingCard(
                  booking: booking,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingDetailsScreen(booking: booking),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
