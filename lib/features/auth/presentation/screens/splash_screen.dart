import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      duration: const Duration(milliseconds: 2200),
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

    // If authenticated and Remember Me is enabled, go to Dashboard; else Login
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
      backgroundColor: AppColors.modernBg,
      body: Stack(
        children: [
          // 1. Top Decorative Wave
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopSplashWaveWidget(height: 160),
          ),

          // 2. Center Branding & Sleek Progress Bar
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Visual Speedometer Dial Gauge
                const SplashSpeedometerIcon(size: 110),
                const SizedBox(height: 14),

                // "Pride" in stylized italic bold blue
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF0052D4), Color(0xFF0066FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'Pride',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // "KMPH Meter" in deep navy
                const Text(
                  'KMPH Meter',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepNavy,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Precision Speed Monitoring',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7B8F),
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 42),

                // Animated Sleek Progress Bar
                Container(
                  width: 210,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEBFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0052D4),
                                  Color(0xFF0066FF),
                                  Color(0xFF00C6FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0066FF)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 6,
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

                // Loading Text
                const Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7B8F),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Decorative Wave
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomWaveWidget(height: 100),
          ),
        ],
      ),
    );
  }
}
