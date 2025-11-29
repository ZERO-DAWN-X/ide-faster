import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ide_model.dart';
import '../services/ide_service.dart';
import '../services/window_service.dart';
import '../services/path_service.dart';

class HomeScreen extends StatefulWidget {
  final List<IdeModel> detectedIdes;
  
  const HomeScreen({super.key, required this.detectedIdes});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<IdeModel> _availableIdes = [];
  bool _isLoading = false;
  bool _isMoving = false;
  String _statusMessage = '';
  bool _showSuccess = false;
  String _destinationPath = '';
  String? _toastMessage;
  bool _isToastError = false;

  @override
  void initState() {
    super.initState();
    _loadDestinationPath();
    _loadAvailableIdes();
  }

  Future<void> _loadDestinationPath() async {
    // Load base path for display (without AppData\Roaming)
    final basePath = await PathService.getBaseDestinationPath();
    setState(() {
      _destinationPath = basePath;
    });
  }

  Future<void> _selectDestinationFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        // Save the base path (AppData\Roaming will be auto-appended)
        final success = await PathService.setDestinationPath(selectedDirectory);
        if (success) {
          // Get base path for display
          final basePath = await PathService.getBaseDestinationPath();
          setState(() {
            _destinationPath = basePath;
          });
          _showMessage('Destination folder updated. AppData\\Roaming will be created automatically.', isError: false);
        } else {
          _showMessage('Failed to save destination path', isError: true);
        }
      }
    } catch (e) {
      _showMessage('Error selecting folder: $e', isError: true);
    }
  }

  Future<void> _loadAvailableIdes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading IDEs...';
    });

    try {
      // Use the detected IDEs from scan screen and refresh their status
      final ides = await IdeService.checkAvailableIdes(ides: widget.detectedIdes);
      setState(() {
        _availableIdes = ides;
        _isLoading = false;
        final availableCount = ides.where((ide) => ide.status == IdeStatus.available).length;
        _statusMessage = availableCount > 0
            ? 'Select IDEs to optimize performance'
            : 'All IDEs are already optimized or not installed';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading IDEs: $e';
      });
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      final ide = _availableIdes[index];
      // Allow selection if IDE is available or already moved (for revert)
      if (ide.status == IdeStatus.available || ide.status == IdeStatus.alreadyMoved) {
        ide.isSelected = !ide.isSelected;
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (var ide in _availableIdes) {
        if (ide.status == IdeStatus.available || ide.status == IdeStatus.alreadyMoved) {
          ide.isSelected = true;
        }
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var ide in _availableIdes) {
        ide.isSelected = false;
      }
    });
  }

  int get _selectedCount {
    return _availableIdes.where((ide) => ide.isSelected).length;
  }

  int get _selectedMovedCount {
    return _availableIdes.where((ide) => ide.isSelected && ide.status == IdeStatus.alreadyMoved).length;
  }

  int get _selectedAvailableCount {
    return _availableIdes.where((ide) => ide.isSelected && ide.status == IdeStatus.available).length;
  }

  Future<void> _revertSelectedIdes() async {
    final selectedIdes = _availableIdes.where((ide) => ide.isSelected && ide.status == IdeStatus.alreadyMoved).toList();

    if (selectedIdes.isEmpty) {
      _showMessage('Please select at least one moved IDE to restore', isError: true);
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Restore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are about to restore the following IDEs:',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ...selectedIdes.map((ide) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC143C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ide.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC143C),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WARNING: Please close ALL selected applications first!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC143C),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC143C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isMoving = true;
      _statusMessage = 'Restoring IDEs...';
      _showSuccess = false;
    });

    try {
      final result = await IdeService.revertSelectedIdes(selectedIdes);

      if (result['success'] == true) {
        _showMessage('IDEs restored successfully!', isError: false);
        // Deselect all after successful revert
        _deselectAll();
        // Reload to update status
        await Future.delayed(const Duration(seconds: 1));
        await _loadAvailableIdes();
      } else {
        final results = result['results'] as Map<String, dynamic>;
        final errors = results.entries
            .where((e) => (e.value as Map)['success'] != true)
            .map((e) => '${e.key}: ${(e.value as Map)['message']}')
            .join(', ');
        _showMessage('Some IDEs failed to restore: $errors', isError: true);
      }
    } catch (e) {
      _showMessage('Error restoring IDEs: $e', isError: true);
    } finally {
      setState(() {
        _isMoving = false;
      });
    }
  }

  Future<void> _moveSelectedIdes() async {
    final selectedIdes = _availableIdes.where((ide) => ide.isSelected).toList();

    if (selectedIdes.isEmpty) {
      _showMessage('Please select at least one IDE to move', isError: true);
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Move',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are about to move the following IDEs:',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ...selectedIdes.map((ide) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC143C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ide.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC143C),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WARNING: Please close ALL selected applications first!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC143C),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC143C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isMoving = true;
      _statusMessage = 'Moving selected IDEs...';
      _showSuccess = false;
    });

    try {
      final result = await IdeService.moveSelectedIdes(selectedIdes);

      if (result['success'] == true) {
        setState(() {
          _isMoving = false;
          _statusMessage = 'Successfully moved ${selectedIdes.length} IDE(s)!';
          _showSuccess = true;
        });

        // Deselect all after successful move
        _deselectAll();

        // Reload available IDEs
        await Future.delayed(const Duration(seconds: 1));
        await _loadAvailableIdes();
      } else {
        final results = result['results'] as Map<String, dynamic>;
        final errors = <String>[];
        results.forEach((key, value) {
          if (value['success'] != true) {
            final ide = selectedIdes.firstWhere((i) => i.id == key);
            errors.add('${ide.name}: ${value['message']}');
          }
        });

        setState(() {
          _isMoving = false;
          _statusMessage = errors.isEmpty
              ? 'Some operations failed'
              : errors.join('\n');
          _showSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isMoving = false;
        _statusMessage = 'Error: $e';
        _showSuccess = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() {
      _toastMessage = message;
      _isToastError = isError;
    });

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC143C)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            )
          : Container(
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

                  // Right Side - IDE List and Controls with Glassmorphism
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
                                      // Status Message
                              if (_statusMessage.isNotEmpty)
                                Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 56, 16, 8),
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          child: Row(
                            children: [
                              if (_isMoving)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFDC143C),
                                    ),
                                  ),
                                )
                              else if (_showSuccess)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFDC143C),
                                  size: 18,
                                )
                              else
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFDC143C),
                                  size: 18,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                                ),
                              ),

                              // IDE Grid
                              Expanded(
                                child: _availableIdes.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFE4E1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check_circle_outline,
                                                size: 48,
                                                color: Color(0xFFDC143C),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No IDEs available to move',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'All IDEs have been moved or not installed',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : GridView.builder(
                                            padding: const EdgeInsets.all(8),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 6,
                                              mainAxisSpacing: 6,
                                              childAspectRatio: 4.5,
                                            ),
                                            itemCount: _availableIdes.length,
                                            itemBuilder: (context, index) {
                                              final ide = _availableIdes[index];
                                              final isAvailable = ide.status == IdeStatus.available;
                                              final isAlreadyMoved = ide.status == IdeStatus.alreadyMoved;
                                              final isNotInstalled = ide.status == IdeStatus.notInstalled;
                                              
                                              // Determine background color based on status
                                              Color backgroundColor;
                                              Color borderColor;
                                              Color iconBgColor;
                                              Color textColor;
                                              
                                              if (isAlreadyMoved) {
                                                // Optimized (already moved) - Green tint
                                                backgroundColor = ide.isSelected
                                                    ? const Color(0xFFE8F5E9)
                                                    : const Color(0xFFF1F8F4);
                                                borderColor = const Color(0xFF4CAF50).withOpacity(0.3);
                                                iconBgColor = const Color(0xFF4CAF50).withOpacity(0.15);
                                                textColor = const Color(0xFF2E7D32);
                                              } else if (isAvailable) {
                                                // Unoptimized (available) - Red tint
                                                backgroundColor = ide.isSelected
                                                    ? const Color(0xFFFFE4E1)
                                                    : Colors.white;
                                                borderColor = const Color(0xFFDC143C).withOpacity(0.2);
                                                iconBgColor = const Color(0xFFDC143C).withOpacity(0.1);
                                                textColor = Colors.black87;
                                              } else {
                                                // Not installed - Gray
                                                backgroundColor = Colors.grey.shade100;
                                                borderColor = Colors.grey.shade300;
                                                iconBgColor = Colors.grey.shade200;
                                                textColor = Colors.grey.shade600;
                                              }

                                              return Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: _isMoving || (!isAvailable && !isAlreadyMoved)
                                                      ? null
                                                      : () => _toggleSelection(index),
                                                  borderRadius: BorderRadius.circular(3),
                                                  child: Opacity(
                                                    opacity: (isAvailable || isAlreadyMoved) ? 1.0 : 0.5,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: backgroundColor,
                                                          border: Border.all(
                                                            color: borderColor,
                                                            width: 1,
                                                          ),
                                                          borderRadius: BorderRadius.circular(3),
                                                        ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(width: 6),
                                                        // Selected indicator
                                                        if (ide.isSelected)
                                                          Container(
                                                            width: 4,
                                                            height: 4,
                                                            decoration: BoxDecoration(
                                                              color: isAlreadyMoved
                                                                  ? const Color(0xFF4CAF50)
                                                                  : const Color(0xFFDC143C),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          )
                                                        else
                                                          const SizedBox(width: 4),
                                                        const SizedBox(width: 6),
                                                        // Icon
                                                        Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: iconBgColor,
                                                            borderRadius: BorderRadius.circular(3),
                                                          ),
                                                          child: _getIdeIcon(
                                                            ide.id,
                                                            color: ide.isSelected
                                                                ? (isAlreadyMoved
                                                                    ? const Color(0xFF4CAF50)
                                                                    : const Color(0xFFDC143C))
                                                                : textColor,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        // Name
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  ide.name,
                                                                  style: TextStyle(
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: ide.isSelected
                                                                        ? (isAlreadyMoved
                                                                            ? const Color(0xFF2E7D32)
                                                                            : const Color(0xFFDC143C))
                                                                        : textColor,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              // Status badge
                                                              if (isAlreadyMoved)
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 4),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                                                                    borderRadius: BorderRadius.circular(2),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons.check_circle,
                                                                        size: 8,
                                                                        color: const Color(0xFF4CAF50),
                                                                      ),
                                                                      const SizedBox(width: 2),
                                                                      Text(
                                                                        'Done',
                                                                        style: TextStyle(
                                                                          fontSize: 8,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: const Color(0xFF2E7D32),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              else if (isAvailable)
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 4),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(0xFFDC143C).withOpacity(0.1),
                                                                    borderRadius: BorderRadius.circular(2),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Container(
                                                                        width: 4,
                                                                        height: 4,
                                                                        decoration: const BoxDecoration(
                                                                          color: Color(0xFFDC143C),
                                                                          shape: BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 2),
                                                                      Text(
                                                                        'Ready',
                                                                        style: TextStyle(
                                                                          fontSize: 8,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: const Color(0xFFDC143C),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                      ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                              ),

                              // Destination Path Selector
                              if (_availableIdes.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.folderOpen,
                                        size: 14,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _destinationPath.isEmpty 
                                              ? 'Select destination folder...' 
                                              : 'Destination: $_destinationPath',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _isMoving ? null : _selectDestinationFolder,
                                          borderRadius: BorderRadius.circular(3),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC143C).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: const Text(
                                              'Change',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFDC143C),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Action Buttons
                              if (_availableIdes.isNotEmpty)
                                Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isMoving ? null : _selectAll,
                                      icon: const Icon(Icons.select_all, size: 16),
                                      label: const Text(
                                        'Select All',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        side: BorderSide.none,
                                        backgroundColor: Colors.white.withOpacity(0.7),
                                        minimumSize: const Size(0, 36),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isMoving ? null : _deselectAll,
                                      icon: const Icon(Icons.deselect, size: 16),
                                      label: const Text(
                                        'Deselect All',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        side: BorderSide.none,
                                        backgroundColor: Colors.white.withOpacity(0.7),
                                        minimumSize: const Size(0, 36),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_selectedAvailableCount > 0)
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: _isMoving || _selectedAvailableCount == 0
                                        ? null
                                        : _moveSelectedIdes,
                                    icon: _isMoving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.move_down, size: 18),
                                    label: Text(
                                      _isMoving
                                          ? 'Moving...'
                                          : 'Move Selected ($_selectedAvailableCount)',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedAvailableCount == 0
                                          ? Colors.grey.shade400
                                          : const Color(0xFFDC143C),
                                      foregroundColor: Colors.white,
                                      elevation: _selectedAvailableCount == 0 ? 0 : 2,
                                      shadowColor: const Color(0xFFDC143C).withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_selectedMovedCount > 0) ...[
                                if (_selectedAvailableCount > 0) const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: _isMoving || _selectedMovedCount == 0
                                        ? null
                                        : _revertSelectedIdes,
                                    icon: _isMoving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.undo, size: 18),
                                    label: Text(
                                      _isMoving
                                          ? 'Restoring...'
                                          : 'Restore Selected ($_selectedMovedCount)',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedMovedCount == 0
                                          ? Colors.grey.shade400
                                          : Colors.black,
                                      foregroundColor: Colors.white,
                                      elevation: _selectedMovedCount == 0 ? 0 : 2,
                                      shadowColor: Colors.black.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
          // Toast Message at Bottom
          if (_toastMessage != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _toastMessage != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isToastError ? const Color(0xFFDC143C) : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isToastError ? Icons.error_outline : Icons.check_circle_outline,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _toastMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _toastMessage = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(3),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
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

          // Custom Window Controls - GitHub and Close Buttons
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GitHub Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final url = Uri.parse('https://github.com/ZERO-DAWN-X');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'FOLLOW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const FaIcon(
                            FontAwesomeIcons.github,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Close Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: WindowService.close,
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFDC143C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIdeIcon(String ideId, {Color? color}) {
    final iconColor = color ?? Colors.black87;
    final iconSize = 14.0;
    
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
}

