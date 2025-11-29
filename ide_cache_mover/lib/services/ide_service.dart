import 'dart:io';
import '../models/ide_model.dart';
import 'file_operation_service.dart';

class IdeService {
  static const String destinationBasePath = r'D:\AppData\Roaming';

  static List<IdeModel> getAvailableIdes() {
    return [
      IdeModel(
        id: 'cursor',
        name: 'Cursor',
        appDataFolderName: 'Cursor',
        destinationFolderName: 'Cursor',
      ),
      IdeModel(
        id: 'vscode',
        name: 'VS Code',
        appDataFolderName: 'Code',
        destinationFolderName: 'Code',
      ),
      IdeModel(
        id: 'vscode_insiders',
        name: 'VS Code Insiders',
        appDataFolderName: 'Code - Insiders',
        destinationFolderName: 'Code-Insiders',
      ),
      IdeModel(
        id: 'claude',
        name: 'Claude',
        appDataFolderName: 'Claude',
        destinationFolderName: 'Claude',
      ),
      IdeModel(
        id: 'windsurf',
        name: 'Windsurf',
        appDataFolderName: 'Windsurf',
        destinationFolderName: 'Windsurf',
      ),
      IdeModel(
        id: 'discord',
        name: 'Discord',
        appDataFolderName: 'discord',
        destinationFolderName: 'discord',
      ),
      IdeModel(
        id: 'github',
        name: 'GitHub Desktop',
        appDataFolderName: 'GitHub Desktop',
        destinationFolderName: 'GitHub-Desktop',
      ),
      IdeModel(
        id: 'figma',
        name: 'Figma',
        appDataFolderName: 'Figma',
        destinationFolderName: 'Figma',
      ),
      IdeModel(
        id: 'obs',
        name: 'OBS Studio',
        appDataFolderName: 'obs-studio',
        destinationFolderName: 'obs-studio',
      ),
    ];
  }

  /// Check all IDEs and their status (returns all 9 IDEs from batch file)
  static Future<List<IdeModel>> checkAvailableIdes() async {
    final ides = getAvailableIdes();
    final appDataPath = FileOperationService.getAppDataPath();

    if (appDataPath.isEmpty) {
      // Return all IDEs with notInstalled status if we can't get AppData path
      return ides;
    }

    // Check status for each IDE
    for (final ide in ides) {
      final folderPath = '$appDataPath\\${ide.appDataFolderName}';
      final exists = await FileOperationService.folderExists(folderPath);

      if (exists) {
        final isJunction = await FileOperationService.isJunction(folderPath);
        ide.status = isJunction ? IdeStatus.alreadyMoved : IdeStatus.available;
      } else {
        ide.status = IdeStatus.notInstalled;
      }
    }

    return ides; // Return all IDEs, not just available ones
  }

  /// Move selected IDEs
  static Future<Map<String, dynamic>> moveSelectedIdes(List<IdeModel> selectedIdes) async {
    final appDataPath = FileOperationService.getAppDataPath();
    final results = <String, Map<String, dynamic>>{};

    // Create destination directory if it doesn't exist
    final destDir = Directory(destinationBasePath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    for (final ide in selectedIdes) {
      final result = await FileOperationService.moveIdeFolder(
        ide,
        appDataPath,
        destinationBasePath,
      );
      results[ide.id] = result;
    }

    return {
      'success': results.values.every((r) => r['success'] == true),
      'results': results,
    };
  }
}

