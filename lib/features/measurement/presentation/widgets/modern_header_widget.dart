import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Modern top curved header matching the reference visual design.
/// Features a deep navy gradient, curved organic bottom wave,
/// brand logo badge, title, subtitle, and settings shortcut.
class ModernHeaderWidget extends StatelessWidget {
  const ModernHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Secondary soft cyan accent wave underneath
        ClipPath(
          clipper: _HeaderAccentWaveClipper(),
          child: Container(
            height: topPadding + 112,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0052D4), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        // Primary deep navy wave header
        ClipPath(
          clipper: _HeaderMainWaveClipper(),
          child: Container(
            height: topPadding + 104,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.modernNavyStart, AppColors.modernNavyEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.only(
              top: topPadding + 2,
              left: 18,
              right: 18,
              bottom: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rounded speedometer logo badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF00C6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C6FF).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pride KMPH Meter',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Precision Speed Monitoring',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFC2D9F2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Main wave clipper for the deep navy header.
class _HeaderMainWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 18);

    // Flowing organic wave contour across the header base
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height,
      size.width * 0.58,
      size.height - 10,
    );
    path.quadraticBezierTo(
      size.width * 0.84,
      size.height - 20,
      size.width,
      size.height - 8,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Accent wave clipper peeking underneath the main navy wave.
class _HeaderAccentWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 12);

    path.quadraticBezierTo(
      size.width * 0.32,
      size.height + 4,
      size.width * 0.62,
      size.height - 6,
    );
    path.quadraticBezierTo(
      size.width * 0.86,
      size.height - 14,
      size.width,
      size.height - 4,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
