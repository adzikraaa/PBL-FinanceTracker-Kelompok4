import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/premium_viewmodel.dart';
import '../auth/welcome_view.dart';
import 'edit_profile_view.dart';
import 'support_view.dart';
import '../../shared/creative_background.dart';
import 'dart:math';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedChild(Widget child, int index) {
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Pengguna';
    final email = user?.email ?? '-';
    final photoUrl = user?.photoURL;
    final isPremium = context.watch<PremiumViewModel>().isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      body: Stack(
        children: [
          // ── Gradient BG ───────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1F12),
                  Color(0xFF0D2818),
                  Color(0xFF0F2E1A),
                ],
              ),
            ),
          ),

          // ── Decorative top arc ────────────────────────────────────────
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.06),
                  width: 1,
                ),
              ),
            ),
          ),

          // ── Sparkles ───────────────────────────────────────────────
          const Positioned.fill(
            child: StarSparkleBackground(),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar row ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF163520),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF4ADE80).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFF4ADE80),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Profil Saya',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileView()));
                          setState(() {});
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3E3C8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8BCA6E).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF0C1B13),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ── Avatar card ─────────────────────────────────
                        _buildAnimatedChild(Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF163520).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF4ADE80).withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.03),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar circle
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final double pulse = _pulseController.value;
                                  final double glowSpread = isPremium ? 2.0 + pulse * 4.0 : 1.0;
                                  final double glowBlur = isPremium ? 15.0 + pulse * 10.0 : 15.0;
                                  final double glowOpacity = isPremium ? 0.3 + pulse * 0.3 : 0.2;

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: isPremium
                                              ? const LinearGradient(
                                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : const LinearGradient(
                                                  colors: [
                                                    Color(0xFF22C55E),
                                                    Color(0xFF4ADE80),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isPremium
                                                  ? const Color(0xFFFFD700).withOpacity(glowOpacity)
                                                  : const Color(0xFF4ADE80).withOpacity(glowOpacity),
                                              blurRadius: glowBlur,
                                              spreadRadius: glowSpread,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: isPremium ? const Color(0xFFFFD700) : const Color(0xFF4ADE80).withOpacity(0.5),
                                            width: 3,
                                          ),
                                        ),
                                        child: photoUrl != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  photoUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _buildInitialAvatar(displayName, isPremium),
                                                ),
                                              )
                                            : _buildInitialAvatar(displayName, isPremium),
                                      ),
                                      // Online indicator dot or golden star
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: isPremium ? const Color(0xFFFFD700) : const Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFF0D2818),
                                                width: 4),
                                          ),
                                          child: isPremium
                                              ? const Center(
                                                  child: Icon(Icons.star, size: 10, color: Colors.black),
                                                )
                                              : null,
                                        ),
                                      ),
                                      // Premium Crown Badge - floating
                                      if (isPremium)
                                        Positioned(
                                          top: -12 + (pulse * -4),
                                          right: -10,
                                          child: Transform.rotate(
                                            angle: 0.3 + (pulse * 0.15),
                                            child: const Text(
                                              '\u{1f451}',
                                              style: TextStyle(fontSize: 32),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isPremium ? const Color(0xFF2D2006) : const Color(0xFF163520),
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: isPremium
                                      ? const LinearGradient(
                                          colors: [Color(0xFF2D2006), Color(0xFF1A1303)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  border: Border.all(
                                    color: isPremium
                                        ? const Color(0xFFFFD700).withOpacity(0.4)
                                        : const Color(0xFF4ADE80).withOpacity(0.2),
                                    width: isPremium ? 1.5 : 1,
                                  ),
                                  boxShadow: isPremium
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withOpacity(0.1),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPremium ? Icons.workspace_premium_rounded : Icons.verified,
                                      color: isPremium ? const Color(0xFFFFD700) : const Color(0xFF4ADE80),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isPremium ? 'Premium Member \u{1f451}' : 'Pengguna Aktif',
                                      style: TextStyle(
                                        color: isPremium ? const Color(0xFFFFD700) : const Color(0xFF4ADE80),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ), 0),

                        const SizedBox(height: 16),

                        const SizedBox(height: 24),

                        // ── Information Card ──────────────────────────────
                        _buildAnimatedChild(Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF163520),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF4ADE80).withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoTile(
                                icon: Icons.person_outline,
                                label: 'Nama Lengkap',
                                value: displayName,
                              ),
                              Divider(
                                color: const Color(0xFF4ADE80).withOpacity(0.1),
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              _buildInfoTile(
                                icon: Icons.mail_outline,
                                label: 'Email',
                                value: email,
                              ),
                              Divider(
                                color: const Color(0xFF4ADE80).withOpacity(0.1),
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                                    _buildInfoTile(
                                icon: Icons.login,
                                label: 'Login dengan',
                                value: _getProviderName(user),
                              ),
                            ],
                          ),
                        ), 1),

                        const SizedBox(height: 16),

                        // ── Support ───────────────────────────────────────
                        _buildAnimatedChild(GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportView()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3E3C8),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFD3E3C8).withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.help_outline, color: Color(0xFF0C1B13), size: 24),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    'Support',
                                    style: TextStyle(
                                      color: Color(0xFF0C1B13),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.black, size: 24),
                              ],
                            ),
                          ),
                        ), 2),

                        const SizedBox(height: 16),

                        // ── Ganti Akun ────────────────────────────────────
                        _buildAnimatedChild(GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFFD2E3C8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: const Color(0xFF8BCA6E).withOpacity(0.3),
                                  ),
                                ),
                                title: const Text('Keluar',
                                    style: TextStyle(
                                        color: Color(0xFF0F2E1A),
                                        fontWeight: FontWeight.bold)),
                                content: const Text(
                                  'Apakah kamu yakin ingin keluar dari akun?',
                                  style: TextStyle(
                                      color: Color(0xFF2E4F39)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal',
                                        style: TextStyle(
                                            color: Color(0xFF4E6E56),
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B3D2A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Keluar',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await context
                                  .read<AuthViewModel>()
                                  .logout();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const WelcomeView()),
                                  (_) => false,
                                );
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B0000),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.white, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Ganti Akun',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), 3),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4ADE80), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String name, [bool isPremium = false]) {
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: isPremium ? Colors.black : const Color(0xFF0D2818),
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getProviderName(User? user) {
    if (user == null) return '-';
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('google.com')) return 'Google';
    if (providers.contains('password')) return 'Email & Password';
    return providers.isNotEmpty ? providers.first : '-';
  }
}


