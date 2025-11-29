import 'dart:io';
import '../models/ide_model.dart';
import 'file_operation_service.dart';
import 'path_service.dart';

class IdeService {

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
        id: 'zed',
        name: 'Zed',
        appDataFolderName: 'Zed',
        destinationFolderName: 'Zed',
      ),
      IdeModel(
        id: 'trae',
        name: 'Trae',
        appDataFolderName: 'Trae',
        destinationFolderName: 'Trae',
      ),
      IdeModel(
        id: 'wrap',
        name: 'Wrap',
        appDataFolderName: 'Wrap',
        destinationFolderName: 'Wrap',
      ),
      IdeModel(
        id: 'qader',
        name: 'Qader',
        appDataFolderName: 'Qader',
        destinationFolderName: 'Qader',
      ),
      IdeModel(
        id: 'replit',
        name: 'Replit',
        appDataFolderName: 'Replit',
        destinationFolderName: 'Replit',
      ),
      IdeModel(
        id: 'project_idx',
        name: 'Project IDX',
        appDataFolderName: 'Project IDX',
        destinationFolderName: 'Project-IDX',
      ),
      IdeModel(
        id: 'github_copilot',
        name: 'GitHub Copilot',
        appDataFolderName: 'GitHub Copilot',
        destinationFolderName: 'GitHub-Copilot',
      ),
      IdeModel(
        id: 'tabnine',
        name: 'Tabnine',
        appDataFolderName: 'Tabnine',
        destinationFolderName: 'Tabnine',
      ),
      IdeModel(
        id: 'codeium',
        name: 'Codeium',
        appDataFolderName: 'Codeium',
        destinationFolderName: 'Codeium',
      ),
      IdeModel(
        id: 'intellij',
        name: 'IntelliJ IDEA',
        appDataFolderName: 'JetBrains',
        destinationFolderName: 'JetBrains',
      ),
      IdeModel(
        id: 'pycharm',
        name: 'PyCharm',
        appDataFolderName: 'JetBrains',
        destinationFolderName: 'JetBrains',
      ),
      IdeModel(
        id: 'webstorm',
        name: 'WebStorm',
        appDataFolderName: 'JetBrains',
        destinationFolderName: 'JetBrains',
      ),
      IdeModel(
        id: 'eclipse_theia',
        name: 'Eclipse Theia',
        appDataFolderName: 'Eclipse Theia',
        destinationFolderName: 'Eclipse-Theia',
      ),
      IdeModel(
        id: 'continue',
        name: 'Continue',
        appDataFolderName: 'Continue',
        destinationFolderName: 'Continue',
      ),
      IdeModel(
        id: 'aider',
        name: 'Aider',
        appDataFolderName: 'Aider',
        destinationFolderName: 'Aider',
      ),
      IdeModel(
        id: 'codeium_chat',
        name: 'Codeium Chat',
        appDataFolderName: 'Codeium Chat',
        destinationFolderName: 'Codeium-Chat',
      ),
    ];
  }

  /// Check all IDEs and their status (returns all AI-powered IDEs)
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
    final destinationBasePath = await PathService.getDestinationPath();
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

  /// Revert selected IDEs (move back to original location)
  static Future<Map<String, dynamic>> revertSelectedIdes(List<IdeModel> selectedIdes) async {
    final appDataPath = FileOperationService.getAppDataPath();
    final destinationBasePath = await PathService.getDestinationPath();
    final results = <String, Map<String, dynamic>>{};

    for (final ide in selectedIdes) {
      final result = await FileOperationService.revertIdeFolder(
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

