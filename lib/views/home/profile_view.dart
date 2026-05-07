import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/welcome_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Pengguna';
    final email = user?.email ?? '-';
    final photoUrl = user?.photoURL;

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

          SafeArea(
            child: Column(
              children: [
                // ── AppBar row ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
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
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ── Avatar card ─────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF163520),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF4ADE80).withOpacity(0.15),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF4ADE80).withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar circle
                              Stack(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF22C55E),
                                          Color(0xFF4ADE80),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4ADE80)
                                              .withOpacity(0.35),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: photoUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      _buildInitialAvatar(
                                                          displayName),
                                            ),
                                          )
                                        : _buildInitialAvatar(displayName),
                                  ),
                                  // online indicator
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4ADE80),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF163520),
                                            width: 2.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.55),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4ADE80).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        const Color(0xFF4ADE80).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified,
                                        color: Color(0xFF4ADE80), size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Pengguna Aktif',
                                      style: TextStyle(
                                        color: Color(0xFF4ADE80),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Info detail card ────────────────────────────
                        _InfoCard(
                          items: [
                            _InfoItem(
                              icon: Icons.person_outline,
                              label: 'Nama Lengkap',
                              value: displayName,
                            ),
                            _InfoItem(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: email,
                            ),
                            _InfoItem(
                              icon: Icons.login_outlined,
                              label: 'Login dengan',
                              value: _getProviderName(user),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Menu card ───────────────────────────────────
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.lock_outline,
                              label: 'Ubah Password',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur segera hadir'),
                                    backgroundColor: Color(0xFF163520),
                                  ),
                                );
                              },
                            ),
                            _MenuItem(
                              icon: Icons.help_outline,
                              label: 'Bantuan',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur segera hadir'),
                                    backgroundColor: Color(0xFF163520),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Logout button ───────────────────────────────
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF163520),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: const Color(0xFF4ADE80)
                                        .withOpacity(0.2),
                                  ),
                                ),
                                title: const Text('Keluar',
                                    style:
                                        TextStyle(color: Colors.white)),
                                content: const Text(
                                  'Apakah kamu yakin ingin keluar dari akun?',
                                  style: TextStyle(
                                      color: Color(0xB3FFFFFF)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal',
                                        style: TextStyle(
                                            color: Color(0xFF4ADE80))),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Keluar',
                                        style: TextStyle(
                                            color: Colors.redAccent)),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout,
                                    color: Colors.redAccent, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Keluar dari Akun',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

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

  Widget _buildInitialAvatar(String name) {
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF0D2818),
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

// ── Info Card ──────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF163520),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF4ADE80).withOpacity(0.12), width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon,
                          color: const Color(0xFF4ADE80), size: 18),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: const Color(0xFF4ADE80).withOpacity(0.08),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(
      {required this.icon, required this.label, required this.value});
}

// ── Menu Card ──────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF163520),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF4ADE80).withOpacity(0.12), width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            color: const Color(0xFF4ADE80), size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.3), size: 14),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: const Color(0xFF4ADE80).withOpacity(0.08),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}
