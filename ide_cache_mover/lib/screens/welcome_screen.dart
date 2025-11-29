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
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                                  const SizedBox(height: 12),
                                  // Fixed 3-column Grid
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 3.2,
                                    children: [
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
                                  const SizedBox(height: 24),
                                  // Introduction Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: Colors.grey.shade300.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF4CAF50),
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'What You\'ll Get',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildBenefitItem('Eliminate SSD lag and PC freezing'),
                                        const SizedBox(height: 8),
                                        _buildBenefitItem('Prevent SSD crashes and drive failures'),
                                        const SizedBox(height: 8),
                                        _buildBenefitItem('Improve system performance significantly'),
                                        const SizedBox(height: 8),
                                        _buildBenefitItem('Extend your SSD lifespan'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E1).withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: const Color(0xFFDC143C).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFDC143C),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC143C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade700,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

