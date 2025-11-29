import 'package:shared_preferences/shared_preferences.dart';

class PathService {
  static const String _destinationPathKey = 'destination_path';
  static const String _defaultDestinationPath = r'D:\AppData\Roaming';

  /// Get the saved destination path or return default
  static Future<String> getDestinationPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_destinationPathKey) ?? _defaultDestinationPath;
    } catch (e) {
      return _defaultDestinationPath;
    }
  }

  /// Save the destination path
  static Future<bool> setDestinationPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_destinationPathKey, path);
    } catch (e) {
      return false;
    }
  }

  /// Get default destination path
  static String getDefaultDestinationPath() {
    return _defaultDestinationPath;
  }
}

