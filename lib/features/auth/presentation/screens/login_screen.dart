import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../measurement/presentation/widgets/bottom_wave_widget.dart';
import '../../../measurement/presentation/widgets/modern_header_widget.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedEmail = ref.read(authControllerProvider).savedEmail;
      if (savedEmail.isNotEmpty && _emailController.text.isEmpty) {
        _emailController.text = savedEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authController = ref.read(authControllerProvider.notifier);

    final success = await authController.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/');
    } else {
      final error = ref.read(authControllerProvider).errorMessage ??
          'Sign in failed. Please check credentials.';
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
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

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded,
                color: Color(0xFF0066FF), size: 24),
            const SizedBox(width: 8),
            Text(
              'Reset Password',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered email address to receive password reset instructions.',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7B8F)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: AppColors.deepNavy,
              ),
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF8F9DAE),
                ),
                prefixIcon: const Icon(Icons.mail_outline_rounded,
                    color: Color(0xFF6B7B8F), size: 23),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFF0066FF), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF6B7B8F)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter a valid email address.',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                );
                return;
              }
              Navigator.of(dialogCtx).pop();

              final sent = await ref
                  .read(authControllerProvider.notifier)
                  .sendPasswordReset(email);

              if (mounted) {
                if (sent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset email sent! Please check your inbox.',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: const Color(0xFF169B75),
                    ),
                  );
                } else {
                  final err = ref.read(authControllerProvider).errorMessage ??
                      'Could not send reset email.';
                  _showErrorSnackBar(err);
                }
              }
            },
            child: Text(
              'Send Link',
              style: GoogleFonts.inter(
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
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.modernBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Curved Navy Header
                    const ModernHeaderWidget(),

                    // 2. Main Login Form Body with Polished Card Elevation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2ECF8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052D4)
                                  .withValues(alpha: 0.07),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
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
                              // Heading: "Welcome Back"
                              Text(
                                'Welcome Back',
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
                                'Login to continue to Pride KMPH Meter',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B7B8F),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Input 1: Email / Username
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
                                  hintText: 'Email / Username',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF8F9DAE),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF4FD),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.person_outline_rounded,
                                        color: Color(0xFF0066FF),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFAFCFF),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E4F5),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E4F5),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0066FF),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email or username';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Input 2: Password
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
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF4FD),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF0066FF),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  suffixIcon: IconButton(
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
                                  filled: true,
                                  fillColor: const Color(0xFFFAFCFF),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E4F5),
                                      width: 1.2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD6E4F5),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF0066FF),
                                      width: 1.8,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Options Row: Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Remember Me
                                  InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      authController.toggleRememberMe(
                                          !authState.rememberMe);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: authState.rememberMe,
                                            activeColor: const Color(0xFF0066FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            onChanged: (val) {
                                              if (val != null) {
                                                authController
                                                    .toggleRememberMe(val);
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Remember me',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF08224D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Forgot Password?
                                  GestureDetector(
                                    onTap: _showForgotPasswordDialog,
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0066FF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // Primary Action Button: Modern Glowing Gradient Button
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
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0066FF)
                                            .withValues(alpha: 0.40),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: authState.isLoading
                                          ? null
                                          : _handleLogin,
                                      child: Center(
                                        child: authState.isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.login_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Login',
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
                                        horizontal: 14),
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

                              const SizedBox(height: 18),

                              // Secondary Frosted Action: Create New Account
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF3F7FE),
                                    side: const BorderSide(
                                      color: Color(0xFFB8D6FB),
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.push('/register');
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_add_alt_outlined,
                                        color: Color(0xFF0052D4),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create New Account',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0052D4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Flexible spacer to adapt gracefully on any device height
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
