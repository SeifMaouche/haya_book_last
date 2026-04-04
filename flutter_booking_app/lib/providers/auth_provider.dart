// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _userName;
  String? _phone;
  String? _bio;
  String? _userType;
  String? _photoPath; // ← local file path of picked profile photo
  bool    _isLoading = false;
  String? _error;

  bool    get isAuthenticated => _userId != null;
  String? get userId    => _userId;
  String? get email     => _email;
  String? get userName  => _userName;
  String? get phone     => _phone;
  String? get bio       => _bio;
  String? get userType  => _userType;
  String? get photoPath => _photoPath; // ← used by profile_screen
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId    = prefs.getString('userId');
      _email     = prefs.getString('email');
      _userName  = prefs.getString('userName');
      _phone     = prefs.getString('phone');
      _bio       = prefs.getString('bio');
      _userType  = prefs.getString('userType');
      _photoPath = prefs.getString('photoPath'); // ← load saved photo
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load auth state: $e';
      notifyListeners();
    }
  }

  // ── Update photo path only ────────────────────────────────────
  Future<void> updatePhoto(String path) async {
    _photoPath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoPath', path);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _userId   = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _email    = email;
      _userName = email.split('@')[0];
      _phone    = '';
      _userType = 'client';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId',   _userId!);
      await prefs.setString('email',    _email!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('phone',    '');
      await prefs.setString('userType', _userType!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    return signup(
        email: email, password: password, name: name, userType: 'client');
  }

  Future<bool> loginWithPhone(String phone) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _userId   = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _email    = '$phone@phone.local';
      _userName = 'User';
      _phone    = phone;
      _userType = 'client';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId',   _userId!);
      await prefs.setString('email',    _email!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('phone',    _phone!);
      await prefs.setString('userType', _userType!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = 'Phone login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _userId   = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _email    = email;
      _userName = name;
      _phone    = '';
      _userType = userType;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId',   _userId!);
      await prefs.setString('email',    _email!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('phone',    '');
      await prefs.setString('userType', _userType!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = 'Signup failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── UPDATE PROFILE — name + email + phone + bio + optional photo ──
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? bio,
    String? photoPath, // ← optional new photo path
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _userName = name.trim();
      _email    = email.trim();
      _phone    = phone.trim();
      if (bio != null)       _bio       = bio.trim();
      if (photoPath != null) _photoPath = photoPath;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userName!);
      await prefs.setString('email',    _email!);
      await prefs.setString('phone',    _phone!);
      if (_bio != null)       await prefs.setString('bio',       _bio!);
      if (_photoPath != null) await prefs.setString('photoPath', _photoPath!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _userId    = null;
      _email     = null;
      _userName  = null;
      _phone     = null;
      _bio       = null;
      _userType  = null;
      _photoPath = null;
      _error     = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
      notifyListeners();
    }
  }
}