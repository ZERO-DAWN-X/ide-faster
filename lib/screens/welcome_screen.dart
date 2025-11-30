import 'dart:ui';
import 'package:flutter/material.dart';
import 'scan_screen.dart';
import '../services/window_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _closeAndContinue(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ScanScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Two-column layout
          Row(
            children: [
              // Left Side - Image
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFDC143C).withOpacity(0.05),
                        const Color(0xFFDC143C).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/1.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFAFAFA),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Right Side - Content
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'NXIVE OPTIMIZER',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFDC143C),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'NXIVE Optimizer - SSD Protected',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(0.08),
                              2: FlexColumnWidth(1),
                            },
                            children: [
                              // Header row
                              TableRow(
                                children: [
                                  _buildTableHeader('Critical Issues', true),
                                  const SizedBox(width: 16),
                                  _buildTableHeader('Solutions', false),
                                ],
                              ),
                              // Spacer row
                              const TableRow(
                                children: [
                                  SizedBox(height: 20),
                                  SizedBox(),
                                  SizedBox(height: 20),
                                ],
                              ),
                              // Content rows
                              TableRow(
                                children: [
                                  _buildProblemItem(
                                    'IDE Lag Until Open New Chat',
                                    'Slow response when starting new conversations',
                                  ),
                                  const SizedBox(),
                                  _buildBenefitItem(
                                    'Eliminate SSD lag and PC freezing',
                                    'No more system slowdowns or freezing',
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _buildProblemItem(
                                    'SSD Lag & PC Lag',
                                    'Constant cache writes cause system slowdowns',
                                  ),
                                  const SizedBox(),
                                  _buildBenefitItem(
                                    'Prevent SSD crashes and drive failures',
                                    'Protect your SSD from excessive writes',
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _buildProblemItem(
                                    'Performance Reduction',
                                    'Disk bottlenecks when using multiple IDEs',
                                  ),
                                  const SizedBox(),
                                  _buildBenefitItem(
                                    'Improve system performance significantly',
                                    'Eliminate disk bottlenecks completely',
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _buildProblemItem(
                                    'SSD Crashes After Few Days',
                                    'Excessive writes damage SSD controller',
                                  ),
                                  const SizedBox(),
                                  _buildBenefitItem(
                                    'Extend your SSD lifespan',
                                    'Reduce wear and extend drive longevity',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Footer with Continue button
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _closeAndContinue(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC143C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue to Scan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Draggable title bar area (excludes close button on the right)
          Positioned(
            top: 0,
            left: 0,
            right: 70, // Exclude right 70px for close button
            height: 100,
            child: GestureDetector(
              onPanStart: (_) => WindowService.startDrag(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Close Button (overlaid at top-right)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: WindowService.close,
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
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

  Widget _buildTableHeader(String title, bool isProblem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isProblem ? const Color(0xFFDC143C) : const Color(0xFF2E7D32),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProblemItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC143C),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              height: 1.5,
              letterSpacing: 0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              height: 1.5,
              letterSpacing: 0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
