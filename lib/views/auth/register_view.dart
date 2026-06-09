import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../shared/colors.dart';
import 'login_view.dart';
import 'email_verification_view.dart';
import '../home/main_navigation.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  late AnimationController _animController;
  late AnimationController _sparkleCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fullNameController.addListener(() {
      if (_usernameError != null) setState(() => _usernameError = null);
    });
    _emailController.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _passwordController.addListener(() {
      if (_passwordError != null) setState(() => _passwordError = null);
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    _sparkleCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // Logo (tanpa background putih)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Main card (glassmorphism)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Center(
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Create your account',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: Color(0xFF6DFC9A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Usrname
                            _buildLabel('Username'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _fullNameController,
                              hint: 'Enter Username',
                              keyboardType: TextInputType.name,
                              errorText: _usernameError,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'example@gmail.com',
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildPasswordField(errorText: _passwordError),
                            const SizedBox(height: 14),

                            // Checkbox terms
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _agreeToTerms = !_agreeToTerms),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.white
                                              .withValues(alpha: 0.4),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(4),
                                      color: _agreeToTerms
                                          ? AppColors.accentYellow
                                          : Colors.transparent,
                                    ),
                                    child: _agreeToTerms
                                        ? const Icon(Icons.check,
                                            size: 13, color: Color(0xFF1a0a00))
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                RichText(
                                  text: TextSpan(
                                    text: 'I agree to the processing of ',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: AppColors.white
                                          .withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Personal data',
                                        style: TextStyle(
                                          color: AppColors.accentYellow,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Sign Up button
                            Consumer<AuthViewModel>(
                              builder: (context, vm, _) => GestureDetector(
                                onTap: vm.isLoading
                                    ? null
                                    : () async {
                                        // Field validation
                                        bool hasError = false;
                                        setState(() {
                                          _usernameError = null;
                                          _emailError = null;
                                          _passwordError = null;
                                          if (_fullNameController.text
                                              .trim()
                                              .isEmpty) {
                                            _usernameError =
                                                'Username tidak boleh kosong';
                                            hasError = true;
                                          }
                                          if (_emailController.text
                                              .trim()
                                              .isEmpty) {
                                            _emailError =
                                                'Email tidak boleh kosong';
                                            hasError = true;
                                          } else if (!RegExp(
                                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                              .hasMatch(
                                                  _emailController.text
                                                      .trim())) {
                                            _emailError =
                                                'Format email tidak valid';
                                            hasError = true;
                                          }
                                          if (_passwordController
                                              .text.isEmpty) {
                                            _passwordError =
                                                'Password tidak boleh kosong';
                                            hasError = true;
                                          } else if (_passwordController
                                                  .text.length <
                                              6) {
                                            _passwordError =
                                                'Password minimal 6 karakter';
                                            hasError = true;
                                          }
                                        });
                                        if (hasError) return;

                                        if (!_agreeToTerms) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Harap setujui syarat dan ketentuan.')));
                                          return;
                                        }
                                        final success =
                                            await vm.registerWithEmail(
                                          fullName:
                                              _fullNameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );
                                        if (!mounted) return;
                                        if (success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Registrasi berhasil! \u{1f389}')));
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const EmailVerificationView(),
                                            ),
                                            (route) => false,
                                          );
                                        } else if (vm.errorMessage != null) {
                                          final errMsg = vm.errorMessage!;
                                          if (vm.isEmailAlreadyInUse) {
                                            setState(() => _emailError = errMsg);
                                            // Tampilkan snackbar dengan aksi langsung ke login
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Email sudah terdaftar. Silakan login dengan email tersebut.'),
                                                action: SnackBarAction(
                                                  label: 'Login',
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) => const LoginView()),
                                                    );
                                                  },
                                                ),
                                                duration: const Duration(seconds: 5),
                                              ),
                                            );
                                          } else {
                                            setState(() => _passwordError = errMsg);
                                          }
                                        }
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentYellow,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentYellow
                                            .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: vm.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                color: AppColors.textDark,
                                                strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontFamily: 'Lexend',
                                              color: AppColors.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'or sign up with',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: AppColors.white
                                          .withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Social buttons
                            Consumer<AuthViewModel>(
                              builder: (context, vm, _) => GestureDetector(
                                onTap: () async {
                                  final success = await vm.loginWithGoogle();
                                  if (!mounted) return;
                                  if (success) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MainNavigation(),
                                      ),
                                      (route) => false,
                                    );
                                  } else if (vm.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(vm.errorMessage!)));
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const GoogleLogo(size: 22),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontFamily: 'Lexend',
                                          color: Color(0xFF3C4043),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Already have account
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginView()),
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Color(0xFF6DFC9A),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign in',
                                        style: TextStyle(
                                          color: AppColors.accentYellow,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Back button
          SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary, size: 18),
                        SizedBox(width: 6),
                        Text('Back',
                            style: TextStyle(
                                fontFamily: 'Lexend',
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Lexend',
        color: Color(0xFF6DFC9A),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: hasError
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4D4D).withValues(alpha: 0.28),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Lexend',
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: hasError
                  ? const Color(0xFFFF4D4D).withValues(alpha: 0.08)
                  : AppColors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFFF4D4D)
                      : AppColors.white.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFFF4D4D)
                      : AppColors.white.withValues(alpha: 0.15),
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFFF4D4D)
                      : AppColors.accentYellow,
                  width: 1.5,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (hasError) _buildErrorMessage(errorText),
      ],
    );
  }

  Widget _buildPasswordField({String? errorText}) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: hasError
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4D4D).withValues(alpha: 0.28),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              fontFamily: 'Lexend',
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: '••••••',
              hintStyle: TextStyle(
                color: AppColors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: hasError
                  ? const Color(0xFFFF4D4D).withValues(alpha: 0.08)
                  : AppColors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFFF4D4D)
                      : AppColors.white.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFFF4D4D)
                      : AppColors.white.withValues(alpha: 0.15),
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFFF4D4D)
                      : AppColors.accentYellow,
                  width: 1.5,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.white.withValues(alpha: 0.4),
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        if (hasError) _buildErrorMessage(errorText),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF6B6B),
            size: 14,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Lexend',
                color: Color(0xFFFF6B6B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    Color? iconColor,
    String? label,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: iconColor, size: 20)
              : Text(
                  label!,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }

  static const Color _bg1 = Color(0xFF061D12);
  static const Color _bg2 = Color(0xFF0D2E1E);
  static const Color _bg3 = Color(0xFF08351F);
  static const Color _green = Color(0xFF6DFC9A);

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bg1, _bg2, _bg3],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Radial glow bottom left
          Positioned(
            bottom: -100,
            left: -100,
            child: _glowOrb(300, const Color(0xFF0E3D22), 0.6),
          ),
          // Radial glow top right
          Positioned(
            top: -100,
            right: -100,
            child: _glowOrb(300, const Color(0xFF0E3D22), 0.4),
          ),
          
          // Top left rings
          Positioned(
            top: -80,
            left: -80,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _ThinRingPainter(color: _green),
            ),
          ),
          Positioned(
            top: -20,
            left: -100,
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _ThinRingPainter(color: _green),
            ),
          ),

          // Bottom right rings
          Positioned(
            bottom: -50,
            right: -80,
            child: CustomPaint(
              size: const Size(300, 300),
              painter: _ThinRingPainter(color: _green),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -20,
            child: CustomPaint(
              size: const Size(250, 250),
              painter: _ThinRingPainter(color: _green),
            ),
          ),

          // Left star
          _animatedSparkle(
            top: 250,
            left: 30,
            size: 14,
            delay: 0.5,
          ),

          // Bottom right star
          _animatedSparkle(
            bottom: 200,
            right: 40,
            size: 32,
            delay: 1.0,
          ),

          // Top right cluster
          _animatedSparkle(
            top: 100,
            right: 100,
            size: 55,
            delay: 0.0,
          ),
          _animatedSparkle(
            top: 130,
            right: 40,
            size: 30,
            delay: 0.3,
          ),
        ],
      ),
    );
  }

  Widget _glowOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.06),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.04,
          ),
        ],
      ),
    );
  }

  Widget _animatedSparkle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, child) {
        final floatOffset = sin((_floatCtrl.value * 2 * pi) + delay * 2 * pi) * 10;
        
        return Positioned(
          top: top != null ? top + floatOffset : null,
          bottom: bottom != null ? bottom - floatOffset : null,
          left: left,
          right: right,
          child: AnimatedBuilder(
            animation: _sparkleCtrl,
            builder: (context, child) {
              final scale = 0.8 + 0.2 * sin((_sparkleCtrl.value * 2 * pi) + delay * pi);
              final opacity = 0.5 + 0.5 * sin((_sparkleCtrl.value * 2 * pi) + delay * pi);
              
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: _Sparkle(size: size, color: _green),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  Thin Ring Painter
// ═══════════════════════════════════════════════
class _ThinRingPainter extends CustomPainter {
  final Color color;
  _ThinRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_ThinRingPainter o) => o.color != color;
}

// ═══════════════════════════════════════════════
//  4-point sparkle
// ═══════════════════════════════════════════════
class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final inner = r * 0.22;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 2;
      final rad = (i % 2 == 0) ? r : inner;
      final x = cx + rad * cos(angle);
      final y = cy + rad * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter o) => o.color != color;
}

// ═══════════════════════════════════════════════
//  Google Logo Native CustomPainter (No CORS issues)
// ═══════════════════════════════════════════════
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.22;
    final radius = size.width / 2 - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Blue arc (bottom right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 0.0, 0.8, false, paint);

    // Green arc (bottom to bottom left)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.8, 1.6, false, paint);

    // Yellow arc (left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.4, 1.5, false, paint);

    // Red arc (top left to top right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.4, 1.8, false, paint);

    // Blue horizontal bar
    paint.color = const Color(0xFF4285F4);
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx - strokeWidth * 0.05, 
        center.dy - strokeWidth / 2, 
        size.width, 
        center.dy + strokeWidth / 2
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

