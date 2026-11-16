import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders the signature "Pride ≡ KMPH Meter ≡" brand title with custom speed wings
/// and horizontal precision subtitle lines matching the fancy reference design.
class BrandSpeedTitleWidget extends StatelessWidget {
  final bool isDarkBackground;
  final bool singleLine;
  final double prideSize;
  final double kmphSize;

  const BrandSpeedTitleWidget({
    super.key,
    this.isDarkBackground = false,
    this.singleLine = false,
    this.prideSize = 38,
    this.kmphSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final prideColor = isDarkBackground
        ? Colors.white
        : const Color(0xFF0044B8);

    final kmphColor = isDarkBackground
        ? Colors.white
        : const Color(0xFF061E47);

    final speedWingColor = isDarkBackground
        ? const Color(0xFF00C6FF)
        : const Color(0xFF0066FF);

    final subtitleColor = isDarkBackground
        ? const Color(0xFFC7E2FE)
        : const Color(0xFF6B7B8F);

    if (singleLine) {
      final titleFontSize = prideSize > 0 ? prideSize : 20.0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Pride ',
                  style: GoogleFonts.inter(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                TextSpan(
                  text: 'KMPH Meter',
                  style: GoogleFonts.inter(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          _buildSubtitleWithLines(subtitleColor),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Pride" in stylized bold italic font
        Text(
          'Pride',
          style: GoogleFonts.inter(
            fontSize: prideSize,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: prideColor,
            letterSpacing: -0.6,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),

        // "≡ KMPH Meter ≡" with 3-stripe speed wings
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSpeedWings(speedWingColor, isLeft: true),
            const SizedBox(width: 8),
            Text(
              'KMPH Meter',
              style: GoogleFonts.inter(
                fontSize: kmphSize,
                fontWeight: FontWeight.w800,
                color: kmphColor,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 8),
            _buildSpeedWings(speedWingColor, isLeft: false),
          ],
        ),
        const SizedBox(height: 6),

        // Precision Speed Monitoring with decorative flanking lines
        _buildSubtitleWithLines(subtitleColor),
      ],
    );
  }

  Widget _buildSubtitleWithLines(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 1.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                color.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Precision Speed Monitoring',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          width: 24,
          height: 1.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedWings(Color color, {required bool isLeft}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildWingBar(color, width: 14),
        const SizedBox(height: 2.5),
        _buildWingBar(color, width: 18),
        const SizedBox(height: 2.5),
        _buildWingBar(color, width: 12),
      ],
    );
  }

  Widget _buildWingBar(Color color, {required double width}) {
    return Container(
      width: width,
      height: 2.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

