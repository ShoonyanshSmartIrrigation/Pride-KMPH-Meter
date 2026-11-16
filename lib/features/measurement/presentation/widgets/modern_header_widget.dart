import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Modern top curved header matching the reference visual design.
/// Features a deep navy gradient, curved organic bottom wave,
/// brand logo badge, title, subtitle, and optional user actions.
class ModernHeaderWidget extends StatelessWidget {
  final Widget? action;
  final bool showLogout;

  const ModernHeaderWidget({super.key, this.action, this.showLogout = false});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.deepNavy,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out from Pride KMPH Meter?',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7B8F)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7B8F)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Secondary soft cyan accent wave underneath
        ClipPath(
          clipper: _HeaderAccentWaveClipper(),
          child: Container(
            height: topPadding + 84,
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
            height: topPadding + 78,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.modernNavyStart, AppColors.modernNavyEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.only(
              top: topPadding + 2,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rounded speedometer logo badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF00C6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C6FF).withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pride KMPH Meter',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Precision Speed Monitoring',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFC2D9F2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action or Logout button
                if (action != null)
                  action!
                else if (showLogout)
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white70,
                      size: 21,
                    ),
                    tooltip: 'Log Out',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmLogout(context),
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
    path.lineTo(0, size.height - 14);

    // Flowing organic wave contour across the header base
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height,
      size.width * 0.58,
      size.height - 7,
    );
    path.quadraticBezierTo(
      size.width * 0.84,
      size.height - 15,
      size.width,
      size.height - 6,
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
    path.lineTo(0, size.height - 9);

    path.quadraticBezierTo(
      size.width * 0.32,
      size.height + 3,
      size.width * 0.62,
      size.height - 5,
    );
    path.quadraticBezierTo(
      size.width * 0.86,
      size.height - 11,
      size.width,
      size.height - 3,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
