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
      backgroundColor: const Color(0xFFF4F8FD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          final topWaveHeight = (screenHeight * 0.18).clamp(130.0, 175.0);
          final bottomWaveHeight = (screenHeight * 0.16).clamp(110.0, 150.0);
          final iconSize = (screenHeight * 0.14).clamp(95.0, 130.0);
          final progressBarWidth = (screenWidth * 0.54).clamp(180.0, 240.0);

          return Stack(
            children: [
              // 1. Perspective Speed Highway in lower-middle background
              Positioned(
                bottom: bottomWaveHeight * 0.50,
                left: 0,
                right: 0,
                child: const SpeedPerspectiveRoadWidget(height: 220),
              ),

              // 2. Top Decorative Flowing Multi-Layer Wave
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopSplashWaveWidget(height: topWaveHeight),
              ),

              // 3. Responsive Center Branding & Animated Progress Bar
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Speedometer Gauge with Neon Glow
                      SplashSpeedometerIcon(size: iconSize),
                      const SizedBox(height: 8),

                      // "Pride ≡ KMPH Meter ≡" with Speed Wings and Subtitle
                      const BrandSpeedTitleWidget(
                        isDarkBackground: false,
                        prideSize: 42,
                        kmphSize: 26,
                      ),

                      SizedBox(
                        height: (screenHeight * 0.10).clamp(40.0, 80.0),
                      ),

                      // Animated Sleek Glowing Progress Bar over highway
                      Container(
                        width: progressBarWidth,
                        height: 7,
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

                      const SizedBox(height: 12),

                      // Loading caption
                      Text(
                        'Loading...',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7B8F),
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // 4. Bottom Flowing Multi-Layer Wave
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
