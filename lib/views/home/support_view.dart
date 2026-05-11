import 'package:flutter/material.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1F12),
                  Color(0xFF0D2818),
                  Color(0xFF163520),
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.05), width: 1),
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.03), width: 1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      const SizedBox(width: 16),
                      const Text(
                        'Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tentang Kami Card
                        _buildAnimatedChild(_buildTentangKamiCard(), 0),
                        const SizedBox(height: 16),

                        // List Tiles
                        _buildAnimatedChild(const _ExpandableTile(
                          icon: Icons.help_outline,
                          title: 'Visi',
                          content: 'Menjadi platform utama dalam memberikan solusi pengelolaan keuangan yang cerdas, efisien, dan mudah digunakan oleh seluruh lapisan masyarakat demi masa depan yang lebih baik.',
                        ), 1),
                        const SizedBox(height: 12),
                        _buildAnimatedChild(const _ExpandableTile(
                          icon: Icons.money_outlined,
                          title: 'Misi',
                          content: 'Membantu pengguna memantau, merencanakan, dan mengoptimalkan pengeluaran serta pemasukan dengan fitur inovatif dan antarmuka yang sangat ramah.',
                        ), 2),
                        const SizedBox(height: 12),
                        _buildAnimatedChild(const _ExpandableTile(
                          icon: Icons.history,
                          title: 'BizPrice itu apasih?',
                          content: 'BizPrice adalah aplikasi pelacakan keuangan (Finance Tracker) yang dirancang khusus untuk mempermudah Anda mencatat setiap transaksi harian, mengelola anggaran, dan melihat wawasan keuangan.',
                        ), 3),
                        
                        const SizedBox(height: 16),

                        // Keamanan & Privasi
                        _buildAnimatedChild(_buildKeamananCard(), 4),
                        const SizedBox(height: 24),

                        // Hubungi Kami
                        _buildAnimatedChild(_buildHubungiKamiCard(), 5),
                        const SizedBox(height: 40),
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

  Widget _buildTentangKamiCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF163520),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative large icon in background anchored to bottom right
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              Icons.account_balance_wallet,
              size: 160,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tentang Kami',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pelajari lebih lanjut mengenai visi dan misi kami dalam membantu pengelolaan keuangan Anda.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeamananCard() {
    return const _AnimatedKeamananCard();
  }

  Widget _buildHubungiKamiCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF70B843), // Vivid light green matching image
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF70B843).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hubungi Kami',
            style: TextStyle(
              color: Color(0xFF0A1F12),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kami sangat menghargai setiap saran, dukungan, dan kritik. Tim kami siap membantu memberikan solusi terbaik untuk setiap kendala yang Anda alami.',
            style: TextStyle(
              color: Color(0xFF0F2E1A),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _AnimatedMessageButton(),
        ],
      ),
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ExpandableTile({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF163520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded ? const Color(0xFF4ADE80).withOpacity(0.4) : const Color(0xFF4ADE80).withOpacity(0.15), 
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(widget.icon, color: const Color(0xFF4ADE80), size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16, left: 38),
                child: Text(
                  widget.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMessageButton extends StatefulWidget {
  @override
  State<_AnimatedMessageButton> createState() => _AnimatedMessageButtonState();
}

class _AnimatedMessageButtonState extends State<_AnimatedMessageButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showAnimatedDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return const _MessageDialog();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut).value,
          child: Opacity(
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeIn).value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showAnimatedDialog();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : (_isHovered ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4 + (_pulseController.value * 0.4)),
                      blurRadius: 10 + (_pulseController.value * 15),
                      spreadRadius: _pulseController.value * 3,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, color: Color(0xFF0A1F12), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Kirim Pesan',
                      style: TextStyle(
                        color: Color(0xFF0A1F12),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MessageDialog extends StatefulWidget {
  const _MessageDialog();

  @override
  State<_MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<_MessageDialog> {
  bool _isSending = false;
  bool _isSent = false;
  final _controller = TextEditingController();

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isSending = true;
    });
    // Simulasi proses pengiriman pesan
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSending = false;
        _isSent = true;
      });
      // Otomatis menutup dialog setelah pesan sukses terkirim
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF163520), Color(0xFF0A1F12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 5,
              )
            ],
          ),
          child: _isSent
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(Icons.check_circle_outline, color: Color(0xFF4ADE80), size: 80),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pesan Terkirim!',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terima kasih atas masukannya.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mail_outline, color: Color(0xFF4ADE80)),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Hubungi Kami',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tulis saran, kritik, atau pertanyaan Anda di sini...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADE80),
                          foregroundColor: const Color(0xFF0A1F12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSending
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Color(0xFF0A1F12), strokeWidth: 3),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 18),
                                  SizedBox(width: 8),
                                  Text('Kirim Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

class _AnimatedKeamananCard extends StatefulWidget {
  const _AnimatedKeamananCard();

  @override
  State<_AnimatedKeamananCard> createState() => _AnimatedKeamananCardState();
}

class _AnimatedKeamananCardState extends State<_AnimatedKeamananCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF163520),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded ? const Color(0xFF4ADE80).withOpacity(0.4) : const Color(0xFF4ADE80).withOpacity(0.15), 
            width: 1,
          ),
          boxShadow: _isExpanded ? [
            BoxShadow(
              color: const Color(0xFF4ADE80).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ] : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1F12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security, color: Color(0xFF4ADE80), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keamanan & Privasi',
                        style: TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pelajari perlindungan data Anda.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1F12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Seluruh data Anda dienkripsi secara end-to-end. Kami tidak membagikan informasi finansial Anda kepada pihak ketiga manapun. Keamanan akun Anda selalu menjadi prioritas utama BizPrice.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
