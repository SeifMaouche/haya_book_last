// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/notification_model.dart';
import '../services/api_client.dart';
import 'support_history_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final resp = await apiClient.dio.get('/notifications');
      final List raw = resp.data as List;
      setState(() {
        _notifications = raw.map((j) => NotificationModel.fromJson(j as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load notifications'; _isLoading = false; });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await apiClient.dio.patch('/notifications/read-all');
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    } catch (_) {}
  }

  Future<void> _markOneRead(NotificationModel n) async {
    if (n.isRead) return;
    try {
      await apiClient.dio.patch('/notifications/${n.id}/read');
      final idx = _notifications.indexWhere((x) => x.id == n.id);
      if (idx != -1) {
        setState(() {
          _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        });
      }
    } catch (_) {}
  }

  // ── Map notification type to icon + color ──────────────────────
  _NotifMeta _metaFor(String type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
        return _NotifMeta(Icons.calendar_today_outlined, const Color(0xFFDDF3F0), AppColors.primary);
      case 'BOOKING_CANCELLED':
      case 'CANCELLED_BY_CLIENT':
      case 'CANCELLED_BY_PROVIDER':
        return _NotifMeta(Icons.cancel_outlined, const Color(0xFFFFE4E4), const Color(0xFFEF4444));
      case 'BOOKING_COMPLETED':
        return _NotifMeta(Icons.check_circle_outline, const Color(0xFFDDF3F0), AppColors.primary);
      case 'NEW_MESSAGE':
        return _NotifMeta(Icons.chat_bubble_rounded, const Color(0xFFFFF0E6), AppColors.secondary);
      case 'SUPPORT_REPLY':
        return _NotifMeta(Icons.help_outline_rounded, const Color(0xFFF3E8FF), const Color(0xFF7C3AED));
      default:
        return _NotifMeta(Icons.notifications_active_outlined, const Color(0xFFF0F2F5), const Color(0xFF6B7280));
    }
  }

  // ── Group notifications by date section ─────────────────────────
  Map<String, List<NotificationModel>> _grouped() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest  = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationModel>> groups = {};
    for (final n in _notifications) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      String label;
      if (d == today) {
        label = 'TODAY';
      } else if (d == yest) {
        label = 'YESTERDAY';
      } else {
        label = '${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}';
      }
      groups.putIfAbsent(label, () => []).add(n);
    }
    return groups;
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
            style: TextStyle(fontFamily: 'Inter', fontSize: 20,
                fontWeight: FontWeight.w800, color: AppColors.textDark)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Clear all',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(fontFamily: 'Inter', color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadNotifications, child: const Text('Retry')),
        ]),
      );
    }
    if (_notifications.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFDDF3F0), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('No Notifications Yet',
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text("You're all caught up!", textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textMuted)),
        ]),
      );
    }

    final groups = _grouped();
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primary,
      child: ListView(
        children: [
          for (final entry in groups.entries) ...[
            _sectionHeader(entry.key),
            ...entry.value.map((n) => _tile(n)),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0FAF9),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(label,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
              fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.8)),
    );
  }

  Widget _tile(NotificationModel n) {
    final meta = _metaFor(n.type);
    return InkWell(
      onTap: () {
        _markOneRead(n);
        if (n.type == 'SUPPORT_REPLY') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupportHistoryScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : const Color(0xFFF8FFFE),
          border: const Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: meta.bg, shape: BoxShape.circle),
            child: Icon(meta.icon, color: meta.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(n.title,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                        fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                        color: AppColors.textDark))),
                const SizedBox(width: 8),
                Text(_timeLabel(n.createdAt),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textLight)),
              ]),
              const SizedBox(height: 5),
              Text(n.body,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                      color: AppColors.textMuted, height: 1.45)),
            ]),
          ),
          if (!n.isRead)
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 4),
              child: Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
            ),
        ]),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _NotifMeta {
  final IconData icon;
  final Color    bg;
  final Color    color;
  const _NotifMeta(this.icon, this.bg, this.color);
}