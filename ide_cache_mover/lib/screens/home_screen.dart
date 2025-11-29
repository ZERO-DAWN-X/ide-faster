import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ide_model.dart';
import '../services/ide_service.dart';
import '../services/window_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<IdeModel> _availableIdes = [];
  bool _isLoading = true;
  bool _isMoving = false;
  String _statusMessage = '';
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableIdes();
  }

  Future<void> _loadAvailableIdes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking available IDEs...';
    });

    try {
      final ides = await IdeService.checkAvailableIdes();
      setState(() {
        _availableIdes = ides;
        _isLoading = false;
        final availableCount = ides.where((ide) => ide.status == IdeStatus.available).length;
        _statusMessage = availableCount > 0
            ? 'Select IDEs to move to D: drive'
            : 'All IDEs are already moved or not installed';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFDC143C) : const Color(0xFFDC143C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
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
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.6),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: (_showSuccess
                                    ? const Color(0xFFFFE4E1)
                                    : _isMoving
                                        ? const Color(0xFFFFF0F5)
                                        : Colors.white).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
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
                                                        color: (ide.isSelected
                                                                ? const Color(0xFFFFE4E1)
                                                                : Colors.white).withOpacity(0.85),
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(width: 6),
                                                        // Selected indicator
                                                        if (ide.isSelected)
                                                          Container(
                                                            width: 3,
                                                            height: 3,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFDC143C),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          )
                                                        else
                                                          const SizedBox(width: 3),
                                                        const SizedBox(width: 6),
                                                        // Icon
                                                        Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: ide.isSelected
                                                                ? const Color(0xFFFF69B4).withOpacity(0.15)
                                                                : Colors.grey.shade50.withOpacity(0.5),
                                                            borderRadius: BorderRadius.circular(3),
                                                          ),
                                                          child: Icon(
                                                            _getIdeIcon(ide.id),
                                                            color: ide.isSelected
                                                                ? const Color(0xFFDC143C)
                                                                : Colors.black87,
                                                            size: 14,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        // Name
                                                        Expanded(
                                                          child: Text(
                                                            ide.name,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                              color: ide.isSelected
                                                                  ? const Color(0xFFDC143C)
                                                                  : Colors.black87,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        // Status indicator
                                                        if (isAlreadyMoved)
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 6),
                                                            child: Icon(
                                                              Icons.check_circle,
                                                              size: 12,
                                                              color: Colors.grey.shade400,
                                                            ),
                                                          )
                                                        else if (isNotInstalled)
                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 6),
                                                            child: Icon(
                                                              Icons.remove_circle_outline,
                                                              size: 12,
                                                              color: Colors.grey.shade400,
                                                            ),
                                                          )
                                                        else
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
          // Custom Window Control - Close Button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
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
          ),
        ],
      ),
    );
  }

  IconData _getIdeIcon(String ideId) {
    switch (ideId) {
      case 'cursor':
        return Icons.code;
      case 'vscode':
      case 'vscode_insiders':
        return Icons.integration_instructions;
      case 'claude':
        return Icons.psychology;
      case 'windsurf':
        return Icons.surfing;
      default:
        return Icons.folder;
    }
  }
}

