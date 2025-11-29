import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/ide_model.dart';
import '../services/ide_service.dart';
import '../services/file_operation_service.dart';
import 'home_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<IdeModel> _detectedIdes = [];
  bool _isScanning = true;
  String _scanStatus = 'Scanning for installed IDEs...';
  int _scannedCount = 0;
  int _totalToScan = 0;

  @override
  void initState() {
    super.initState();
    _scanForIdes();
  }

  Future<void> _scanForIdes() async {
    setState(() {
      _isScanning = true;
      _scanStatus = 'Scanning %AppData%\\Roaming...';
    });

    try {
      final appDataPath = await _getAppDataPath();
      
      if (appDataPath.isEmpty) {
        setState(() {
          _isScanning = false;
          _scanStatus = 'Error: Could not access AppData folder';
        });
        return;
      }

      // Get all possible IDE folder names
      final allPossibleIdes = IdeService.getAvailableIdes();
      setState(() {
        _totalToScan = allPossibleIdes.length;
        _scannedCount = 0;
      });

      final detectedIdes = <IdeModel>[];

      // Scan for each IDE
      for (final ide in allPossibleIdes) {
        setState(() {
          _scannedCount++;
          _scanStatus = 'Checking: ${ide.name}...';
        });

        final folderPath = '$appDataPath\\${ide.appDataFolderName}';
        final exists = await Directory(folderPath).exists();

        if (exists) {
          // Check if it's a junction or regular folder
          final isJunction = await FileOperationService.isJunction(folderPath);
          final detectedIde = IdeModel(
            id: ide.id,
            name: ide.name,
            appDataFolderName: ide.appDataFolderName,
            destinationFolderName: ide.destinationFolderName,
            status: isJunction ? IdeStatus.alreadyMoved : IdeStatus.available,
          );
          detectedIdes.add(detectedIde);
        }

        // Small delay for smooth UI update
        await Future.delayed(const Duration(milliseconds: 50));
      }

      setState(() {
        _detectedIdes = detectedIdes;
        _isScanning = false;
        _scanStatus = detectedIdes.isEmpty
            ? 'No IDEs detected in AppData\\Roaming'
            : 'Found ${detectedIdes.length} IDE${detectedIdes.length > 1 ? 's' : ''}';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanStatus = 'Error scanning: $e';
      });
    }
  }

  Future<String> _getAppDataPath() async {
    return FileOperationService.getAppDataPath();
  }

  Widget _getIdeIcon(String ideId, {Color? color}) {
    final iconColor = color ?? Colors.black87;
    const iconSize = 20.0;
    
    switch (ideId) {
      case 'cursor':
        return FaIcon(FontAwesomeIcons.arrowPointer, size: iconSize, color: iconColor);
      case 'vscode':
      case 'vscode_insiders':
        return FaIcon(FontAwesomeIcons.code, size: iconSize, color: iconColor);
      case 'claude':
        return Icon(Icons.psychology, size: iconSize, color: iconColor);
      case 'windsurf':
        return FaIcon(FontAwesomeIcons.wind, size: iconSize, color: iconColor);
      case 'zed':
        return FaIcon(FontAwesomeIcons.bolt, size: iconSize, color: iconColor);
      case 'trae':
        return FaIcon(FontAwesomeIcons.star, size: iconSize, color: iconColor);
      case 'wrap':
        return FaIcon(FontAwesomeIcons.bars, size: iconSize, color: iconColor);
      case 'qader':
        return FaIcon(FontAwesomeIcons.rocket, size: iconSize, color: iconColor);
      case 'replit':
        return FaIcon(FontAwesomeIcons.cloud, size: iconSize, color: iconColor);
      case 'project_idx':
        return FaIcon(FontAwesomeIcons.google, size: iconSize, color: iconColor);
      case 'github_copilot':
        return FaIcon(FontAwesomeIcons.github, size: iconSize, color: iconColor);
      case 'tabnine':
        return FaIcon(FontAwesomeIcons.wandMagicSparkles, size: iconSize, color: iconColor);
      case 'codeium':
      case 'codeium_chat':
        return FaIcon(FontAwesomeIcons.comments, size: iconSize, color: iconColor);
      case 'intellij':
        return FaIcon(FontAwesomeIcons.java, size: iconSize, color: iconColor);
      case 'pycharm':
        return FaIcon(FontAwesomeIcons.python, size: iconSize, color: iconColor);
      case 'webstorm':
        return FaIcon(FontAwesomeIcons.js, size: iconSize, color: iconColor);
      case 'eclipse_theia':
        return Icon(Icons.brightness_1, size: iconSize, color: iconColor);
      case 'continue':
        return FaIcon(FontAwesomeIcons.play, size: iconSize, color: iconColor);
      case 'aider':
        return FaIcon(FontAwesomeIcons.robot, size: iconSize, color: iconColor);
      default:
        return Icon(Icons.folder, size: iconSize, color: iconColor);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(detectedIdes: _detectedIdes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFE4E1),
              const Color(0xFFFFF0F5),
              Colors.white,
            ],
          ),
        ),
        child: Row(
          children: [
            // Left Side - Image
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/images/3.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFFE4E1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Right Side - Scan Results
            Expanded(
              flex: 3,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top spacing
                        const SizedBox(height: 80),

                        // Title
                        const Text(
                          'IDE Detection',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scanStatus,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Progress indicator
                        if (_isScanning)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFDC143C),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_totalToScan > 0)
                                  Text(
                                    'Scanning ${_scannedCount} of ${_totalToScan}...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Detected IDEs Grid
                        if (!_isScanning)
                          Expanded(
                            child: _detectedIdes.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFE4E1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.search_off,
                                            size: 48,
                                            color: Color(0xFFDC143C),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No IDEs Detected',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'No IDE folders found in AppData\\Roaming',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2.5,
                                    ),
                                    itemCount: _detectedIdes.length,
                                    itemBuilder: (context, index) {
                                      final ide = _detectedIdes[index];
                                      final isMoved = ide.status == IdeStatus.alreadyMoved;
                                      
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isMoved
                                              ? const Color(0xFFF1F8F4)
                                              : Colors.white,
                                          border: Border.all(
                                            color: isMoved
                                                ? const Color(0xFF4CAF50).withOpacity(0.3)
                                                : const Color(0xFFDC143C).withOpacity(0.2),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: isMoved
                                                    ? const Color(0xFF4CAF50).withOpacity(0.15)
                                                    : const Color(0xFFDC143C).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: _getIdeIcon(
                                                ide.id,
                                                color: isMoved
                                                    ? const Color(0xFF4CAF50)
                                                    : const Color(0xFFDC143C),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    ide.name,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: isMoved
                                                          ? const Color(0xFF2E7D32)
                                                          : Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: isMoved
                                                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                                                          : const Color(0xFFDC143C).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (isMoved)
                                                          Icon(
                                                            Icons.check_circle,
                                                            size: 8,
                                                            color: const Color(0xFF4CAF50),
                                                          )
                                                        else
                                                          Container(
                                                            width: 4,
                                                            height: 4,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFDC143C),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        const SizedBox(width: 2),
                                                        Flexible(
                                                          child: Text(
                                                            isMoved ? 'Optimized' : 'Ready',
                                                            style: TextStyle(
                                                              fontSize: 8,
                                                              color: isMoved
                                                                  ? const Color(0xFF2E7D32)
                                                                  : const Color(0xFFDC143C),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),

                        // Continue Button
                        if (!_isScanning)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _detectedIdes.isEmpty ? null : _navigateToHome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC143C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: Text(
                                  _detectedIdes.isEmpty
                                      ? 'No IDEs to Optimize'
                                      : 'Continue with ${_detectedIdes.length} IDE${_detectedIdes.length > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

