import 'package:shared_preferences/shared_preferences.dart';

class PathService {
  static const String _destinationPathKey = 'destination_path';
  static const String _defaultDestinationPath = r'D:\AppData\Roaming';
  static const String _appDataRoamingSuffix = r'AppData\Roaming';

  /// Get the saved destination path with AppData\Roaming appended, or return default
  /// This ensures the folder structure matches the original AppData\Roaming structure
  static Future<String> getDestinationPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final basePath = prefs.getString(_destinationPathKey);
      
      if (basePath != null && basePath.isNotEmpty) {
        // Automatically append AppData\Roaming to user-selected folder
        final fullPath = _ensureAppDataRoamingPath(basePath);
        return fullPath;
      }
      
      return _defaultDestinationPath;
    } catch (e) {
      return _defaultDestinationPath;
    }
  }

  /// Get the base destination path (without AppData\Roaming) for display
  static Future<String> getBaseDestinationPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final basePath = prefs.getString(_destinationPathKey);
      
      if (basePath != null && basePath.isNotEmpty) {
        // Remove AppData\Roaming suffix if it exists
        return _removeAppDataRoamingSuffix(basePath);
      }
      
      // Return default without AppData\Roaming for display
      return r'D:\';
    } catch (e) {
      return r'D:\';
    }
  }

  /// Save the base destination path (user-selected folder)
  /// AppData\Roaming will be automatically appended when needed
  static Future<bool> setDestinationPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Remove AppData\Roaming suffix if user selected it, we'll add it automatically
      final basePath = _removeAppDataRoamingSuffix(path);
      return await prefs.setString(_destinationPathKey, basePath);
    } catch (e) {
      return false;
    }
  }

  /// Get default destination path
  static String getDefaultDestinationPath() {
    return _defaultDestinationPath;
  }

  /// Ensure the path ends with AppData\Roaming
  static String _ensureAppDataRoamingPath(String basePath) {
    // Normalize path separators
    String normalizedPath = basePath.replaceAll('/', '\\');
    
    // Remove trailing backslashes
    while (normalizedPath.endsWith('\\')) {
      normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
    }
    
    // Check if it already ends with AppData\Roaming
    if (normalizedPath.toLowerCase().endsWith(_appDataRoamingSuffix.toLowerCase())) {
      return normalizedPath;
    }
    
    // Append AppData\Roaming
    return '$normalizedPath\\$_appDataRoamingSuffix';
  }

  /// Remove AppData\Roaming suffix from path if it exists
  static String _removeAppDataRoamingSuffix(String path) {
    String normalizedPath = path.replaceAll('/', '\\');
    
    // Remove trailing backslashes
    while (normalizedPath.endsWith('\\')) {
      normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
    }
    
    // Check if it ends with AppData\Roaming and remove it
    if (normalizedPath.toLowerCase().endsWith(_appDataRoamingSuffix.toLowerCase())) {
      final index = normalizedPath.toLowerCase().lastIndexOf(_appDataRoamingSuffix.toLowerCase());
      if (index > 0) {
        normalizedPath = normalizedPath.substring(0, index - 1); // -1 to remove the backslash
      }
    }
    
    return normalizedPath;
  }
}

