import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../measurement/presentation/widgets/bottom_wave_widget.dart';
import '../controllers/auth_controller.dart';
import '../widgets/splash_speedometer_icon.dart';
import '../widgets/top_splash_wave_widget.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progressAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _animController.forward().then((_) => _onSplashCompleted());
  }

  void _onSplashCompleted() {
    if (!mounted) return;

    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final rememberMe = authService.rememberMe;

    if (user != null && rememberMe) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          final topWaveHeight = (screenHeight * 0.17).clamp(110.0, 160.0);
          final bottomWaveHeight = (screenHeight * 0.13).clamp(75.0, 115.0);
          final iconSize = (screenHeight * 0.135).clamp(92.0, 120.0);
          final prideFontSize = (screenHeight * 0.052).clamp(34.0, 44.0);
          final kmphFontSize = (screenHeight * 0.033).clamp(22.0, 28.0);
          final progressBarWidth = (screenWidth * 0.54).clamp(180.0, 240.0);

          return Stack(
            children: [
              // 0. Soft Ambient Background Glow Orbs for Luxurious Depth
              Positioned(
                top: screenHeight * 0.28,
                left: screenWidth * 0.12,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00C6FF).withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.42,
                right: screenWidth * 0.10,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0052D4).withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 1. Top Decorative Flowing Multi-Layer Wave
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopSplashWaveWidget(height: topWaveHeight),
              ),

              // 2. Responsive Center Branding & Progress Bar
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gauge Graphic with Outer Luminous Aura
                      SplashSpeedometerIcon(size: iconSize),
                      const SizedBox(height: 10),

                      // "Pride" in bold italic electric gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF0044B8),
                            Color(0xFF0066FF),
                            Color(0xFF00B4D8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Pride',
                          style: GoogleFonts.inter(
                            fontSize: prideFontSize,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            letterSpacing: -0.6,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // "KMPH Meter" in deep sapphire navy
                      Text(
                        'KMPH Meter',
                        style: GoogleFonts.inter(
                          fontSize: kmphFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF061E47),
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // High-Tech Pill Badge: "Precision Speed Monitoring"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4E6FA),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052D4)
                                  .withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'PRECISION SPEED MONITORING',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0052D4),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: (screenHeight * 0.045).clamp(24.0, 42.0),
                      ),

                      // Animated High-Tech Glowing Capsule Progress Bar
                      Container(
                        width: progressBarWidth,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EDF9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, _) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor:
                                    _progressAnimation.value.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0044B8),
                                        Color(0xFF0066FF),
                                        Color(0xFF00C6FF),
                                        Color(0xFF60EFFF),
                                      ],
                                      stops: [0.0, 0.45, 0.85, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0072FF)
                                            .withValues(alpha: 0.45),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Loading caption
                      Text(
                        'Loading...',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7A8C9E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Decorative Flowing Multi-Layer Wave
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomWaveWidget(height: bottomWaveHeight),
              ),
            ],
          );
        },
      ),
    );
  }
}
