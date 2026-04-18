import 'package:flutter/material.dart';
import '../shared/colors.dart';
import 'auth/login_view.dart';
import 'auth/register_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient + Blobs ──────────────────────────────
          _buildBackground(),

          // ── Content ──────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // <-- Diubah jadi center
                children: [
                  const Spacer(flex: 3),

                  // Title
                  const Text(
                    'Welcome to\nBizPrice Tracker',
                    textAlign: TextAlign.center, // <-- Teks rata tengah
                    style: TextStyle(
                      fontFamily: 'Lexend', // <-- Font Lexend
                      color: AppColors.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle (Kalimat Ajakan)
                  const Text(
                    'Take control of your business finances\nand reach your goals effortlessly!',
                    textAlign: TextAlign.center, // <-- Teks rata tengah
                    style: TextStyle(
                      fontFamily: 'Lexend', // <-- Font Lexend
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Buttons Row
                  Row(
                    children: [
                      // Sign In
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginView()),
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.3),
                                  width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  fontFamily: 'Lexend', // <-- Font Lexend
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Sign Up
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterView()),
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentYellow
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontFamily: 'Lexend', // <-- Font Lexend
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
            child: _blob(200, AppColors.primaryLight),
          ),
          Positioned(
            top: 120,
            right: -30,
            child: _blob(140, AppColors.white.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: 220,
            left: 30,
            child: _blob(90, AppColors.primaryDeep.withValues(alpha: 0.6)),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _blob(240, AppColors.gradientBlueEnd),
          ),
          Positioned(
            bottom: 150,
            left: -20,
            child: _blob(100, AppColors.primaryPurple.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}