import 'dart:ui';
import 'package:flutter/material.dart';
import 'scan_screen.dart';

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
                    'assets/images/3.png',
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
                      // Header with close button
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 40, 24, 24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC143C).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.rocket_launch_outlined,
                                color: Color(0xFFDC143C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'NXIVE OPTIMIZER',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'IDE FASTER & SSD PROTECTED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black45,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _closeAndContinue(context),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Side-by-side Sections
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Critical Issues
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 3,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDC143C),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Problems',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _buildProblemItem(
                                          'IDE Lag Until Open New Chat',
                                          'Slow response when starting new conversations',
                                        ),
                                        _buildProblemItem(
                                          'SSD Lag & PC Lag',
                                          'Constant cache writes cause system slowdowns',
                                        ),
                                        _buildProblemItem(
                                          'Performance Reduction',
                                          'Disk bottlenecks when using multiple IDEs',
                                        ),
                                        _buildProblemItem(
                                          'SSD Crashes After Few Days',
                                          'Excessive writes damage SSD controller',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  // Right: What You'll Get
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 3,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Solutions',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _buildBenefitItem(
                                          'Eliminate SSD lag and PC freezing',
                                          'No more system slowdowns or freezing',
                                        ),
                                        _buildBenefitItem(
                                          'Prevent SSD crashes and drive failures',
                                          'Protect your SSD from excessive writes',
                                        ),
                                        _buildBenefitItem(
                                          'Improve system performance significantly',
                                          'Eliminate disk bottlenecks completely',
                                        ),
                                        _buildBenefitItem(
                                          'Extend your SSD lifespan',
                                          'Reduce wear and extend drive longevity',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Footer with Continue button
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _closeAndContinue(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC143C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue to Scan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
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
        ],
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
              letterSpacing: 0,
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
