import 'package:flutter/material.dart';

/// Top dynamic corner-swoop wave for the Splash Screen matching the reference design.
/// Features a bold royal blue corner wave, glowing cyan fluid ribbon, and soft azure accents.
class TopSplashWaveWidget extends StatelessWidget {
  final double height;

  const TopSplashWaveWidget({
    super.key,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _TopSplashWavePainter(),
      ),
    );
  }
}

class _TopSplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Top-Right Soft Ambient Azure Accent (adds dynamic depth in upper right)
    final trPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x3500C6FF),
          Color(0x450072FF),
          Color(0x2060EFFF),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final trPath = Path();
    trPath.moveTo(size.width * 0.35, 0);
    trPath.cubicTo(
      size.width * 0.55,
      size.height * 0.45,
      size.width * 0.78,
      size.height * 0.25,
      size.width,
      size.height * 0.50,
    );
    trPath.lineTo(size.width, 0);
    trPath.close();
    canvas.drawPath(trPath, trPaint);

    // 2. Cyan Luminous Fluid Ribbon (peeking out beneath the deep blue wave)
    final cyanRibbonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x800052D4),
          Color(0xA50072FF),
          Color(0xE000C6FF),
          Color(0xFF60EFFF),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final cyanPath = Path();
    cyanPath.moveTo(0, 0);
    cyanPath.lineTo(0, size.height * 0.78);
    cyanPath.cubicTo(
      size.width * 0.28,
      size.height * 1.05,
      size.width * 0.65,
      size.height * 0.42,
      size.width,
      size.height * 0.22,
    );
    cyanPath.lineTo(size.width, 0);
    cyanPath.close();
    canvas.drawPath(cyanPath, cyanRibbonPaint);

    // 3. Primary Solid Deep Sapphire / Royal Blue Corner Swoop
    final mainWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF021B48),
          Color(0xFF003FAD),
          Color(0xFF005CE6),
          Color(0xFF007BFF),
          Color(0xFF00C6FF),
        ],
        stops: [0.0, 0.25, 0.55, 0.82, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final mainPath = Path();
    mainPath.moveTo(0, 0);
    mainPath.lineTo(0, size.height * 0.65);
    mainPath.cubicTo(
      size.width * 0.25,
      size.height * 0.90,
      size.width * 0.60,
      size.height * 0.32,
      size.width,
      size.height * 0.12,
    );
    mainPath.lineTo(size.width, 0);
    mainPath.close();
    canvas.drawPath(mainPath, mainWavePaint);

    // 4. Specular Glossy Edge Highlight along the main crest
    final crestGlowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xC0FFFFFF),
          Color(0xFF60EFFF),
          Color(0x9000C6FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.25, 0.55, 0.85, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final crestPath = Path();
    crestPath.moveTo(0, size.height * 0.65);
    crestPath.cubicTo(
      size.width * 0.25,
      size.height * 0.90,
      size.width * 0.60,
      size.height * 0.32,
      size.width,
      size.height * 0.12,
    );
    canvas.drawPath(crestPath, crestGlowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
