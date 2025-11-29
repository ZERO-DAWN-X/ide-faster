import 'dart:io';
import 'package:flutter/services.dart';
import '../models/ide_model.dart';

class FileOperationService {
  static const MethodChannel _channel = MethodChannel('ide_cache_mover/file_ops');

  /// Check if a folder exists at the given path
  static Future<bool> folderExists(String path) async {
    try {
      final directory = Directory(path);
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }

  /// Check if a folder is already a junction link
  static Future<bool> isJunction(String path) async {
    try {
      final result = await _channel.invokeMethod<bool>('isJunction', {'path': path});
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Move IDE folder using robocopy and create junction
  static Future<Map<String, dynamic>> moveIdeFolder(IdeModel ide, String appDataPath, String destinationPath) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'moveIdeFolder',
        {
          'sourcePath': '$appDataPath\\${ide.appDataFolderName}',
          'destinationPath': '$destinationPath\\${ide.destinationFolderName}',
          'junctionPath': '$appDataPath\\${ide.appDataFolderName}',
        },
      );

      if (result != null) {
        return {
          'success': result['success'] as bool? ?? false,
          'message': result['message'] as String? ?? 'Unknown error',
        };
      }

      return {'success': false, 'message': 'No result from native code'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get AppData Roaming path
  static String getAppDataPath() {
    final envVars = Platform.environment;
    return envVars['APPDATA'] ?? '';
  }
}

