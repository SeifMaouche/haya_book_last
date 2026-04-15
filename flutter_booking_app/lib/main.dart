// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/provider_profile_provider.dart';
import 'providers/notification_provider.dart';
import 'services/api_client.dart';       // ✅ FIX F2 — navigatorKey
import 'services/socket_service.dart';   // ✅ FIX F3 — notification_received

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/provider_state.dart';
import 'providers/chat_provider.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const HayaBookApp());
}

class HayaBookApp extends StatelessWidget {
  const HayaBookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ProviderStateProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ProviderProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Builder(builder: (ctx) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final auth = ctx.read<AuthProvider>();
          final favs = ctx.read<FavoritesProvider>();
          auth.attachFavoritesProvider(favs);
          if (auth.isAuthenticated) {
            favs.loadFavorites();
            ctx.read<NotificationProvider>().fetchNotifications();
            ctx.read<ChatProvider>().initSocket();
            ctx.read<BookingProvider>().initSocket();
            ctx.read<ProviderStateProvider>().initSocket();
            // ✅ FIX F3: Wire notification_received → show in-app SnackBar
            _attachNotificationListener(ctx);
          }
        });
        return MaterialApp(
          title:                     'HayaBook',
          debugShowCheckedModeBanner: false,
          theme:                     AppTheme.lightTheme,
          onGenerateRoute:           AppRouter.generateRoute,
          initialRoute:              '/splash',
          // ✅ FIX F2: Wire navigatorKey so 401 interceptor redirects to /login
          navigatorKey:              ApiClient.navigatorKey,
        );
      }),
    );
  }

  void _attachNotificationListener(BuildContext ctx) {
    final socket = socketService.socket;
    if (socket == null) return;
    socket.off('notification_received');
    socket.on('notification_received', (data) {
      // Refresh the unread count badge
      ctx.read<NotificationProvider>().fetchNotifications();

      // Show an in-app SnackBar
      final title     = data?['title'] as String?;
      final body      = data?['body']  as String?;
      if (title == null) return;
      final navContext = ApiClient.navigatorKey.currentContext;
      if (navContext == null) return;
      ScaffoldMessenger.of(navContext).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              if (body != null)
                Text(body,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
            ],
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}