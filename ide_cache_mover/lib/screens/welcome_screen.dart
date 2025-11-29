import 'dart:ui';
import 'package:flutter/material.dart';
import 'scan_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _closeAndContinue(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Two-column layout
          Row(
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
              // Right Side - Content with Glassmorphism
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
                          // Header with close button
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 56, 16, 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.rocket_launch,
                                  color: Color(0xFFDC143C),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'IDE Faster - Protect Your SSD',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _closeAndContinue(context),
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Responsive grid: 1 column on small, 2 on medium, 3 on large
                                final crossAxisCount = constraints.maxWidth < 400
                                    ? 1
                                    : constraints.maxWidth < 600
                                        ? 2
                                        : 3;
                                final spacing = constraints.maxWidth < 400 ? 8.0 : 10.0;
                                final padding = constraints.maxWidth < 400 ? 16.0 : 24.0;

                                return SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Problem Section Header
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC143C).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Color(0xFFDC143C),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Critical Issues You\'re Facing',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFDC143C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Responsive Grid
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: spacing,
                                        mainAxisSpacing: spacing,
                                        childAspectRatio: 1.3,
                                        children: [
                                          _buildProblemItem(
                                            'SSD Lag & PC Lag',
                                            'Constant cache writes cause system slowdowns and freezing',
                                          ),
                                          _buildProblemItem(
                                            'Performance Reduction',
                                            'Disk bottlenecks when using multiple IDEs - everything becomes slow',
                                          ),
                                          _buildProblemItem(
                                            'SSD Crashes After Few Days',
                                            'Excessive writes damage SSD controller and cause complete drive failures',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Footer with Continue button
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _closeAndContinue(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC143C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Continue to Scan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  Widget _buildProblemItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E1).withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: const Color(0xFFDC143C).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC143C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC143C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

