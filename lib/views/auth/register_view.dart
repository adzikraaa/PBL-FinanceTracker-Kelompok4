import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../shared/colors.dart';

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
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
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
          // ── Background Gradient + Blobs ──────────────────────────────
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
                                  color: Color(0xFFCCBBFF),
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
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Enter Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildPasswordField(),
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
                                                      'Registrasi berhasil! 🎉')));
                                          Navigator.of(context).pop();
                                        } else if (vm.errorMessage != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content:
                                                      Text(vm.errorMessage!)));
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
                              builder: (context, vm, _) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    icon: Icons.facebook,
                                    iconColor: const Color(0xFF4267B2),
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Login Facebook belum tersedia.')));
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildSocialButton(
                                    label: 'X',
                                    labelColor: Colors.white,
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Login X belum tersedia.')));
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildSocialButton(
                                    label: 'G',
                                    labelColor: const Color(0xFFEA4335),
                                    onTap: () async {
                                      final success =
                                          await vm.loginWithGoogle();
                                      if (!mounted) return;
                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Login Google berhasil! 🎉')));
                                        Navigator.of(context).pop();
                                      } else if (vm.errorMessage != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text(vm.errorMessage!)));
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildSocialButton(
                                    icon: Icons.apple,
                                    iconColor: Colors.white,
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Login Apple belum tersedia.')));
                                    },
                                  ),
                                ],
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
                                      color: Color(0xFFCCBBFF),
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
                                fontFamily: 'Lexend', // <-- Pakai Lexend
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

          // ── Content ──────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildGlassCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: _blob(180, AppColors.primaryLight),
          ),
          Positioned(
            top: 80,
            right: 30,
            child: _blob(100, AppColors.white.withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: _blob(220, AppColors.gradientBlueEnd),
          ),
          Positioned(
            bottom: 100,
            left: 10,
            child: _blob(80, AppColors.primaryPurple.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ── Glass Card ─────────────────────────────────────────────────────────────
  Widget _buildGlassCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.white.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Center(
            child: Text(
              'Get Started',
              style: TextStyle(
                fontFamily: 'Lexend', // <-- Pakai Lexend
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Full Name
          _buildLabel('Full Name'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _fullNameController,
            hint: 'Enter Full Name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Email
          _buildLabel('Email'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _emailController,
            hint: 'Enter Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),

          // Password
          _buildLabel('Password'),
          const SizedBox(height: 6),
          _buildPasswordField(),
          const SizedBox(height: 16),

          // Agree to terms
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: _agreeToTerms,
                  activeColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (v) => setState(() => _agreeToTerms = v!),
                ),
              ),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    text: 'I agree to the processing of ',
                    style: TextStyle(
                        fontFamily: 'Lexend', // <-- Pakai Lexend
                        fontSize: 13,
                        color: AppColors.textTertiary),
                    children: [
                      TextSpan(
                        text: 'Personal data',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sign Up button
          Consumer<AuthViewModel>(
            builder: (context, vm, _) => _buildPrimaryButton(
              label: 'Sign up',
              isLoading: vm.isLoading,
              onTap: () async {
                if (!_agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Harap setujui syarat dan ketentuan.')),
                  );
                  return;
                }
                final success = await vm.registerWithEmail(
                  fullName: _fullNameController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                );
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Registrasi berhasil! 🎉')),
                  );
                  Navigator.of(context).pop();
                } else if (vm.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.errorMessage!)),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // Sign up with
          const Center(
            child: Text(
              'Sign up with',
              style: TextStyle(
                  fontFamily: 'Lexend', // <-- Pakai Lexend
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 14),

          // Social buttons
          Consumer<AuthViewModel>(
            builder: (context, vm, _) => _buildSocialRow(vm),
          ),

          const SizedBox(height: 20),

          // Already have account?
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: RichText(
                text: const TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(
                      fontFamily: 'Lexend', // <-- Pakai Lexend
                      color: AppColors.textTertiary,
                      fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Sign in.',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Lexend',
        color: Color(0xFFCCBBFF),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Lexend', color: AppColors.textTertiary, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textTertiary, size: 18)
            : null,
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryPurple, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Enter Password',
        hintStyle: const TextStyle(fontFamily: 'Lexend', color: AppColors.textTertiary, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppColors.textTertiary, size: 18),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textTertiary,
            size: 18,
          ),
        ),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryPurple, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: AppColors.textPrimary, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Lexend', // <-- Pakai Lexend
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
              top: -60, left: -40, child: _blob(200, AppColors.primaryLight)),
          Positioned(
              top: 120,
              right: -30,
              child: _blob(140, AppColors.white.withValues(alpha: 0.15))),
          Positioned(
              top: 220,
              left: 30,
              child: _blob(90, AppColors.primaryDeep.withValues(alpha: 0.6))),
          Positioned(
              bottom: -60,
              right: -60,
              child: _blob(240, AppColors.gradientBlueEnd)),
          Positioned(
              bottom: 150,
              left: -20,
              child:
                  _blob(100, AppColors.primaryPurple.withValues(alpha: 0.5))),
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