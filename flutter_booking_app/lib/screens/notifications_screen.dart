import 'package:flutter/material.dart';
import '../config/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_Notif> _today;
  late List<_Notif> _yesterday;

  @override
  void initState() {
    super.initState();
    _today = [
      _Notif(
        icon: Icons.calendar_today_outlined,
        iconBg: const Color(0xFFDDF3F0),
        iconColor: AppColors.primary,
        title: 'Booking Confirmed',
        body: 'Your appointment with Dr. Amine has been confirmed for tomorrow at 10:00...',
        time: '2m ago',
        unread: true,
      ),
      _Notif(
        icon: Icons.chat_bubble_rounded,
        iconBg: const Color(0xFFFFF0E6),
        iconColor: AppColors.secondary,
        title: 'New Message',
        body: '"Please remember to bring your previous medical reports for the session."',
        time: '1h ago',
        unread: true,
        italic: true,
      ),
      _Notif(
        icon: Icons.notifications_active_outlined,
        iconBg: const Color(0xFFF0F2F5),
        iconColor: const Color(0xFF6B7280),
        title: 'Security Alert',
        body: 'Your account was logged in from a new device in San Francisco.',
        time: '4h ago',
        unread: false,
      ),
    ];
    _yesterday = [
      _Notif(
        icon: Icons.check_circle_outline,
        iconBg: const Color(0xFFDDF3F0),
        iconColor: AppColors.primary,
        title: 'Session Completed',
        body: 'How was your session with Yoga Flow Studio? Leave a review to help others.',
        time: 'Yesterday',
        unread: false,
      ),
      _Notif(
        icon: Icons.receipt_long_outlined,
        iconBg: const Color(0xFFFFF0E6),
        iconColor: AppColors.secondary,
        title: 'Payment Receipt',
        body: 'Your payment of \$45.00 for Booking #BK-9021 was successful.',
        time: 'Yesterday',
        unread: false,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      for (final n in [..._today, ..._yesterday]) {
        n.unread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Clear all',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: ListView(
        children: [
          _section('TODAY', _today),
          _section('YESTERDAY', _yesterday),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(String label, List<_Notif> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFFF0FAF9),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.8)),
        ),
        ...items.map((n) => _tile(n)),
      ],
    );
  }

  Widget _tile(_Notif n) {
    return InkWell(
      onTap: () => setState(() => n.unread = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: n.iconBg, shape: BoxShape.circle),
              child: Icon(n.icon, color: n.iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: n.unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.textDark)),
                      ),
                      const SizedBox(width: 8),
                      Text(n.time,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textLight)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(n.body,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.45,
                          fontStyle: n.italic
                              ? FontStyle.italic
                              : FontStyle.normal)),
                ],
              ),
            ),
            // Unread dot
            if (n.unread)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool unread;
  final bool italic;

  _Notif({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
    this.italic = false,
  });
}