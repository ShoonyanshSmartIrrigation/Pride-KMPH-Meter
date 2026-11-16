import 'package:flutter/material.dart';
import 'brand_speed_title_widget.dart';
import 'splash_speedometer_icon.dart';

/// Fancy high-end top header for Auth screens (Login & Register), featuring
/// a luminous central speedometer gauge, rich sapphire wave gradient, and glowing crest.
class AuthHeaderWidget extends StatelessWidget {
  final bool singleLineTitle;
  final double? height;
  final double? iconSize;

  const AuthHeaderWidget({
    super.key,
    this.singleLineTitle = false,
    this.height,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final effectiveHeight = height ?? (singleLineTitle ? 148.0 : 198.0);
    final effectiveIconSize = iconSize ?? (singleLineTitle ? 52.0 : 68.0);
    final totalHeight = topPadding + effectiveHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // 1. Secondary Glowing Cyan Accent Wave
          ClipPath(
            clipper: _AuthHeaderAccentClipper(),
            child: Container(
              height: totalHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0052D4),
                    Color(0xFF0072FF),
                    Color(0xFF00C6FF),
                    Color(0xFF60EFFF),
                  ],
                  stops: [0.0, 0.45, 0.80, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 2. Primary Deep Sapphire/Royal Wave Header
          ClipPath(
            clipper: _AuthHeaderMainClipper(),
            child: Container(
              height: totalHeight - 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF021025),
                    Color(0xFF05214D),
                    Color(0xFF0A3C7E),
                    Color(0xFF005AC8),
                  ],
                  stops: [0.0, 0.35, 0.72, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Soft ambient glow halo inside header
                  Positioned(
                    top: topPadding - 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00C6FF).withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header Content (Speedometer Dial & Brand Title)
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: topPadding + (singleLineTitle ? 2 : 4),
                        left: 16,
                        right: 16,
                        bottom: singleLineTitle ? 12 : 18,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Speedometer Dial Gauge
                          SplashSpeedometerIcon(size: effectiveIconSize),
                          SizedBox(height: singleLineTitle ? 2 : 3),

                          // Brand Title & Subtitle with Speed Wings
                          BrandSpeedTitleWidget(
                            isDarkBackground: true,
                            singleLine: singleLineTitle,
                            prideSize: singleLineTitle ? 19.5 : 26,
                            kmphSize: singleLineTitle ? 16 : 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeaderMainClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    // Flowing organic wave contour across header base
    path.cubicTo(
      size.width * 0.26,
      size.height + 4,
      size.width * 0.65,
      size.height - 30,
      size.width,
      size.height - 10,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _AuthHeaderAccentClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 12);

    path.cubicTo(
      size.width * 0.28,
      size.height + 10,
      size.width * 0.68,
      size.height - 20,
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

