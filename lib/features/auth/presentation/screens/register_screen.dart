import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../measurement/presentation/widgets/bottom_wave_widget.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authController = ref.read(authControllerProvider.notifier);

    final success = await authController.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully! Welcome to Pride KMPH Meter.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF169B75),
        ),
      );
      context.go('/');
    } else {
      final error =
          ref.read(authControllerProvider).errorMessage ??
          'Registration failed. Please try again.';
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.modernBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Fancy Sapphire Header with Speedometer Gauge & Title (Compact for Register)
                    const AuthHeaderWidget(
                      singleLineTitle: true,
                      height: 138,
                      iconSize: 48,
                    ),
                    const SizedBox(height: 10),
                    // 2. Main Register Form Body with Floating Card Elevation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFFE2ECF8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0052D4,
                              ).withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Heading: "Create Account"
                              Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF08224D),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Subtitle
                              Text(
                                'Sign up to get started with Pride KMPH Meter',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7B8F),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Field 1: Full Name (Pill / Stadium Shape)
                              TextFormField(
                                controller: _fullNameController,
                                textCapitalization: TextCapitalization.words,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A2540),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF8F9DAE),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 12,
                                    ),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: Color(0xFF5A6E85),
                                      size: 22,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FBFE),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0066FF),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Field 2: Email Address (Pill / Stadium Shape)
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A2540),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF8F9DAE),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 12,
                                    ),
                                    child: Icon(
                                      Icons.mail_outline_rounded,
                                      color: Color(0xFF5A6E85),
                                      size: 22,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FBFE),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0066FF),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Field 3: Password (Pill / Stadium Shape)
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A2540),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF8F9DAE),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 12,
                                    ),
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF5A6E85),
                                      size: 22,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF7A8C9E),
                                        size: 21,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FBFE),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0066FF),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Field 4: Confirm Password (Pill / Stadium Shape)
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A2540),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF8F9DAE),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 12,
                                    ),
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF5A6E85),
                                      size: 22,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF7A8C9E),
                                        size: 21,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FBFE),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E3F2),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0066FF),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              // Primary Action: Pill-Shaped Glowing Gradient Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0044B8),
                                        Color(0xFF0066FF),
                                        Color(0xFF0088FF),
                                      ],
                                      stops: [0.0, 0.5, 1.0],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0066FF,
                                        ).withValues(alpha: 0.42),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: authState.isLoading
                                          ? null
                                          : _handleRegister,
                                      child: Center(
                                        child: authState.isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.person_add_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Sign Up',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // OR Divider with soft styling
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: Color(0xFFE2ECF8),
                                      thickness: 1.2,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'OR',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8F9DAE),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: Color(0xFFE2ECF8),
                                      thickness: 1.2,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Bottom Navigation: Already have an account? Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF6B7B8F),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      } else {
                                        context.go('/login');
                                      }
                                    },
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0066FF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Spacer to push bottom wave down cleanly
                    const Spacer(),
                    const SizedBox(height: 20),

                    // 4. Flowing Decorative Bottom Wave
                    const BottomWaveWidget(height: 70),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
