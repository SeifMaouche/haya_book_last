// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/provider_profile_provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/provider_state.dart';
import 'screens/provider/chat_provider.dart';
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
      ],
      child: MaterialApp(
        title:                     'HayaBook',
        debugShowCheckedModeBanner: false,
        theme:                     AppTheme.lightTheme,
        onGenerateRoute:           AppRouter.generateRoute,
        initialRoute:              '/splash',
      ),
    );
  }
}