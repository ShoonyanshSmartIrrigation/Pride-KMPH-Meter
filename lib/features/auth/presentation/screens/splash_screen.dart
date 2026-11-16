import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../measurement/presentation/widgets/bottom_wave_widget.dart';
import '../controllers/auth_controller.dart';
import '../widgets/brand_speed_title_widget.dart';
import '../widgets/speed_perspective_road_widget.dart';
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          final topWaveHeight = (screenHeight * 0.19).clamp(135.0, 175.0);
          final bottomWaveHeight = (screenHeight * 0.16).clamp(105.0, 145.0);
          final iconSize = (screenHeight * 0.14).clamp(95.0, 125.0);
          final progressBarWidth = (screenWidth * 0.54).clamp(180.0, 240.0);

          return Stack(
            children: [
              // 1. Top Decorative Corner-Swoop Multi-Layer Wave
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopSplashWaveWidget(height: topWaveHeight),
              ),

              // 2. Responsive Center Branding, Perspective Highway, & Progress Bar
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: topWaveHeight * 0.40),

                      // Speedometer Gauge with Neon Glow
                      SplashSpeedometerIcon(size: iconSize),
                      const SizedBox(height: 8),

                      // "Pride ≡ KMPH Meter ≡" with Speed Wings and Subtitle
                      const BrandSpeedTitleWidget(
                        isDarkBackground: false,
                        prideSize: 42,
                        kmphSize: 26,
                      ),

                      const SizedBox(height: 12),

                      // Futuristic Perspective Highway with Centered Progress Bar
                      SizedBox(
                        width: screenWidth,
                        height: (screenHeight * 0.28).clamp(200.0, 240.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Receding perspective road surface
                            const Positioned.fill(
                              child: SpeedPerspectiveRoadWidget(height: 220),
                            ),

                            // Capsule progress bar & Loading caption
                            Positioned(
                              bottom: 28,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: progressBarWidth,
                                    height: 7.5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2EDF9),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 3,
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
                                                  stops: [0.0, 0.40, 0.80, 1.0],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF0072FF)
                                                        .withValues(alpha: 0.50),
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
                                  const SizedBox(height: 10),
                                  Text(
                                    'Loading...',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7B8F),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: bottomWaveHeight * 0.30),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Flowing Multi-Layer Wave
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
