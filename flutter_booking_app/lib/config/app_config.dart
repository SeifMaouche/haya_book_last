// lib/config/app_config.dart
//
// Single source of truth for environment-specific configuration.
// Change the baseUrl here to switch between your local dev machine
// and production. Do NOT hard-code IP addresses in other files.

class AppConfig {
  // ── Local development (physical Android device on same Wi-Fi) ──────
  static const String _localIp = '10.109.238.5';

  // Switch between environments by changing this one line:
  static const String baseUrl   = 'http://$_localIp:5000/api';
  static const String socketUrl = 'http://$_localIp:5000';

  // High-quality avatars
  static const String defaultAvatar = 'https://ui-avatars.com/api/?background=8B5CF6&color=fff&name=HB&bold=true&length=1';
  static const String defaultAvatarAsset = 'assets/images/default_avatar.png';

  // For iOS Simulator or web:
  // static const String baseUrl = 'http://localhost:5000/api';

  // For production (replace with your real domain):
  // static const String baseUrl = 'https://api.hayabook.dz/api';

  static String getMediaUrl(String path) {
    if (path.isEmpty) return '';
    
    // Detect and fix legacy absolute URLs containing localhost/127.0.0.1
    String processedPath = path;
    if (processedPath.contains('localhost') || processedPath.contains('127.0.0.1')) {
      processedPath = processedPath.replaceAll('localhost', _localIp).replaceAll('127.0.0.1', _localIp);
      return processedPath; // It's already an absolute URL now (fixed)
    }

    if (processedPath.startsWith('http')) return processedPath;
    if (processedPath.startsWith('/')) {
      return '$socketUrl$processedPath';
    }
    return '$socketUrl/$processedPath';
  }
}
