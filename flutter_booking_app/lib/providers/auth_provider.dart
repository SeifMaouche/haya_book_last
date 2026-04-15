// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import 'favorites_provider.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _userName;
  String? _phone;
  String? _bio;
  String? _userType;
  String? _photoPath;
  bool    _isLoading = false;
  String? _error;
  String? _token;
  bool    _isProfileComplete = false;

  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Optional reference to FavoritesProvider — set after MultiProvider initialises
  FavoritesProvider? _favoritesProvider;
  void attachFavoritesProvider(FavoritesProvider fp) {
    _favoritesProvider = fp;
  }

  bool    get isAuthenticated => _token != null && _userId != null;
  String? get userId    => _userId;
  String? get email     => _email;
  String? get userName  => _userName;
  String? get phone     => _phone;
  String? get bio       => _bio;
  String? get userType  => _userType;
  String? get photoPath => _photoPath;
  String? get token     => _token;
  bool    get isLoading => _isLoading;
  String? get error     => _error;

  bool    get profileComplete => _isProfileComplete;

  AuthProvider() {
    loadAuthState();
  }

  /// ── Session Persistence Helper ────────────────────────────────
  Future<void> _persistAuth(String token, Map<String, dynamic> user) async {
    _token    = token;
    _userId   = user['id'];
    _email    = user['email'];
    _userName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    _phone    = user['phone'] ?? '';
    _bio      = user['bio'] ?? '';
    // Normalize role to lowercase for consistent UI checks
    _userType = (user['role'] ?? 'client').toString().toLowerCase();
    
    // Use the backend's precise role-aware flag if available; otherwise fallback safely
    if (user.containsKey('isProfileComplete')) {
      _isProfileComplete = user['isProfileComplete'] == true;
    } else {
      _isProfileComplete = _userName != null && _userName!.isNotEmpty;
    }

    // Write to Secure Storage
    await _secureStorage.write(key: 'jwt_token', value: _token!);
    await _secureStorage.write(key: 'userId',    value: _userId!);
    await _secureStorage.write(key: 'isProfileComplete', value: _isProfileComplete.toString());
    if (_email != null) await _secureStorage.write(key: 'email', value: _email!);
    await _secureStorage.write(key: 'userName',  value: _userName!);
    await _secureStorage.write(key: 'phone',     value: _phone!);
    await _secureStorage.write(key: 'userType',  value: _userType!);
    if (_bio != null)   await _secureStorage.write(key: 'bio',   value: _bio!);

    // Sync profile image if present
    if (user['profileImage'] != null) {
      _photoPath = user['profileImage'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photoPath', _photoPath!);
    }
  }

  Future<void> loadAuthState() async {
    try {
      _token     = await _secureStorage.read(key: 'jwt_token');
      _userId    = await _secureStorage.read(key: 'userId');
      _email     = await _secureStorage.read(key: 'email');
      _userName  = await _secureStorage.read(key: 'userName');
      _phone     = await _secureStorage.read(key: 'phone');
      _userType  = await _secureStorage.read(key: 'userType');
      _bio       = await _secureStorage.read(key: 'bio');
      final isComp = await _secureStorage.read(key: 'isProfileComplete');
      
      // Fallback for older sessions: if missing, calculate it based on name
      if (isComp != null) {
        _isProfileComplete = isComp == 'true';
      } else {
        _isProfileComplete = _userName != null && _userName!.isNotEmpty;
      }

      final prefs = await SharedPreferences.getInstance();
      _photoPath = prefs.getString('photoPath');

      if (_token != null) {
        // Silent refresh of profile data to ensure token still valid and data fresh
        loadUserProfile(); 
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Auth state load error: $e');
      await logout();
    }
  }

  Future<void> loadUserProfile() async {
    if (_token == null) return;
    try {
      final user = await _authService.getProfile();
      await _persistAuth(_token!, user);
      notifyListeners();
    } catch (e) {
      debugPrint('Silent profile sync failed: $e');
      // If 401, ApiClient will trigger logout via global navigator
    }
  }

  Future<void> updatePhoto(String path) async {
    _photoPath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoPath', path);
    notifyListeners();
  }

  Future<void> updateToken(String newToken) async {
    _token = newToken;
    await _secureStorage.write(key: 'jwt_token', value: newToken);
    await loadUserProfile(); // This will fetch current DB role and call _persistAuth
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      await _persistAuth(response['token'], response['user']);
      _isLoading = false;
      notifyListeners();
      // Seed favorites from backend immediately after login
      _favoritesProvider?.loadFavorites();
      return true;
    } on DioException catch (de) {
      if (de.response?.statusCode == 404) {
        _error = 'Account not found. Please create an account first.';
      } else if (de.response?.statusCode == 401) {
        _error = 'Invalid email or password.';
      } else {
        _error = de.response?.data?['message'] ?? 'Login failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error     = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithPhone(String phone) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      await _authService.sendOtp(phone);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (de) {
      if (de.response?.statusCode == 404) {
        _error = 'Account not found. Please register first.';
      } else {
        _error = de.response?.data?['message'] ?? 'Phone verification failed.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error     = 'Phone login failed.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPhoneOtp(String phone, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.verifyOtp(phone, code);
      await _persistAuth(response['token'], response['user']);
      _isLoading = false;
      notifyListeners();
      // Seed favorites from backend immediately after OTP login
      _favoritesProvider?.loadFavorites();
      return true;
    } catch (e) {
      _error = 'OTP verification failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String identifier) async {
    _error = null;
    notifyListeners();
    try {
      final success = await _authService.resendOtp(identifier);
      return success;
    } catch (e) {
      _error = 'Resend failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phone,
  }) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();
    try {
      final names = name.split(' ');
      final first = names[0];
      final last  = names.length > 1 ? names.sublist(1).join(' ') : '';
      
      await _authService.register(
        email: email.isNotEmpty ? email : null,
        phone: phone?.isNotEmpty == true ? phone : null,
        password: password,
        firstName: first,
        lastName: last,
        role: userType.toUpperCase(),
      );

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

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? password,
    String? bio,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final names = name.split(' ');
      final first = names[0];
      final last  = names.length > 1 ? names.sublist(1).join(' ') : '';

      final user = await _authService.updateProfile(
        firstName: first,
        lastName:  last,
        email:     email,
        phone:     phone,
        bio:       bio,
        password:  password,
        photoPath: photoPath,
        removePhoto: removePhoto,
      );

      // Re-persist using current token
      if (_token != null) {
        await _persistAuth(_token!, user);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (de) {
      final msg = de.response?.data?['message'] ?? de.message;
      _error     = 'Update failed: $msg';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error     = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _token     = null;
      _userId    = null;
      _email     = null;
      _userName  = null;
      _phone     = null;
      _bio       = null;
      _userType  = null;
      _photoPath = null;
      _error     = null;
      // Clear cached favorites on logout
      _favoritesProvider?.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
      notifyListeners();
    }
  }
}