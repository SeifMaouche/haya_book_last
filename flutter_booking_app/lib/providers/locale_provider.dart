import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  String get languageName {
    switch (_locale.languageCode) {
      case 'fr': return 'Français';
      case 'ar': return 'العربية';
      default:   return 'English';
    }
  }

  LocaleProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    notifyListeners();
  }

  /// Map from display name to language code
  static const Map<String, String> supportedLanguages = {
    'English':  'en',
    'Français': 'fr',
    'العربية':  'ar',
  };
}