import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../data/models/saving_model.dart';
import 'dart:math' as math;

// ─── Sparkle Model ────────────────────────────────────────────────────────────
class _Sparkle {
  double x, y, size, opacity, phase, speed;
  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
    required this.speed,
  });
}

class SavingFormPage extends StatefulWidget {
  final String userId;
  final SavingModel? existingSaving;
  const SavingFormPage({super.key, required this.userId, this.existingSaving});

  @override
  State<SavingFormPage> createState() => _SavingFormPageState();
}

class _SavingFormPageState extends State<SavingFormPage> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late List<_Sparkle> _sparkles;
  final math.Random _rng = math.Random();
  final _titleController = TextEditingController();
  final _currentController = TextEditingController();
  final _targetController = TextEditingController();

  String _formatNumber(String s) {
    if (s.isEmpty) return '';
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  }

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sparkles = List.generate(
      15,
      (_) => _Sparkle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 8 + 4,
        opacity: _rng.nextDouble() * 0.4 + 0.1,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 1.5 + 0.5,
      ),
    );

    final vm = context.read<SavingViewModel>();
    if (widget.existingSaving != null) {
      vm.loadForEdit(widget.existingSaving!);
      _titleController.text = widget.existingSaving!.title;
      _currentController.text = _formatNumber(widget.existingSaving!.currentAmount.toStringAsFixed(0));
      _targetController.text = _formatNumber(widget.existingSaving!.targetAmount.toStringAsFixed(0));
    } else {
      vm.resetForm();
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _titleController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TAMBAH/EDIT TABUNGAN',
          style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildGradientBg(),
          _buildSparkleLayer(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Upload gambar placeholder atau pratinjau
            GestureDetector(
              onTap: () => vm.pickImage(),
              child: RepaintBoundary(
                key: ValueKey(vm.imageUrl ?? 'placeholder'),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFF163520),
                    borderRadius: BorderRadius.circular(16),
                    image: vm.imageUrl != null
                        ? DecorationImage(
                            image: (vm.getCachedImage(vm.imageUrl!) as ImageProvider?) ?? const AssetImage('assets/images/logo.png'),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: vm.imageUrl == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.white54, size: 40),
                            SizedBox(height: 8),
                            Text('Unggah gambar', style: TextStyle(color: Colors.white70)),
                            Text('JPG, JPEG, PNG (MAX 5MB)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(Icons.edit, color: Colors.white, size: 30),
                          ),
                        ),
                ),
              ),
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            _buildLabel('Nama Tabungan'),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g., European Summer Tour',
              onChanged: (val) => vm.title = val,
              errorText: vm.errorMessage != null &&
                      vm.errorMessage!.contains('kosong')
                  ? vm.errorMessage
                  : null,
            ),
            const SizedBox(height: 16),
            _buildLabel('Nominal Target'),
            _buildTextField(
              controller: _targetController,
              hint: '5.000.000',
              prefix: 'Rp ',
              isNumber: true,
              onChanged: (val) {
                final cleanVal = val.replaceAll('.', '');
                vm.targetAmount = double.tryParse(cleanVal) ?? 0;
                setState(() {}); // Update to show warning
              },
              errorText: vm.errorMessage != null &&
                      vm.errorMessage!.contains('valid')
                  ? vm.errorMessage
                  : null,
            ),
            if ((double.tryParse(_targetController.text.replaceAll('.', '')) ?? 0) >= 1000000000)
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Batas maksimal input 1 Miliar',
                  style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 16),
            _buildLabel('Nominal Sekarang'),
            _buildTextField(
              controller: _currentController,
              hint: '0',
              prefix: 'Rp ',
              isNumber: true,
              onChanged: (val) {
                final cleanVal = val.replaceAll('.', '');
                vm.currentAmount = double.tryParse(cleanVal) ?? 0;
                setState(() {}); // Update to show warning
              },
            ),
            if ((double.tryParse(_currentController.text.replaceAll('.', '')) ?? 0) >= 1000000000)
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Batas maksimal input 1 Miliar',
                  style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AFF91),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        // VALIDASI MANDATORY FIELDS
                        if (_titleController.text.trim().isEmpty || 
                            _currentController.text.trim().isEmpty || 
                            _targetController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama, Nominal, dan Target harus diisi!'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final success =
                            await vm.saveSaving(widget.userId);
                        
                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF4AFF91)),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Berhasil!',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.existingSaving != null
                                          ? 'Data tabungan diperbarui'
                                          : 'Data tabungan ditambahkan',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF163520),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      vm.errorMessage ??
                                          'Gagal menyimpan data',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF163520),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : Text(
                        widget.existingSaving != null
                            ? 'SIMPAN PERUBAHAN'
                            : 'BUAT TABUNGAN BARU',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
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
    );
  }

  Widget _buildSparkleLayer() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _SparklePainter(
                sparkles: _sparkles,
                time: _sparkleController.value,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    bool isNumber = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandSeparatorFormatter(),
            ]
          : null,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Color(0xFF4AFF91), fontWeight: FontWeight.bold),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4AFF91), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String url) {
    try {
      if (url.startsWith('data:image')) {
        final parts = url.split(',');
        if (parts.length < 2) return const AssetImage('assets/images/logo.png');
        return MemoryImage(base64Decode(parts.last));
      }
      return NetworkImage(url);
    } catch (e) {
      // Jika gagal decode, tampilkan placeholder agar tidak crash
      return const AssetImage('assets/images/logo.png');
    }
  }
}

class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll('.', '');
    
    // Limit 1 Miliar
    final double? val = double.tryParse(cleanText);
    if (val != null && val > 1000000000) {
      return oldValue;
    }

    final String formatted = cleanText.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double time;

  _SparklePainter({required this.sparkles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (var s in sparkles) {
      final t = time;
      final move = math.sin(t * 2 * math.pi * s.speed + s.phase) * 20;
      final opacity = s.opacity * (0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase));
      
      final paint = Paint()
        ..color = const Color(0xFF4AFF91).withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final center = Offset(size.width * s.x, (size.height * s.y + move) % size.height);
      
      final path = Path();
      path.moveTo(center.dx, center.dy - s.size / 2);
      path.lineTo(center.dx + s.size / 4, center.dy);
      path.lineTo(center.dx, center.dy + s.size / 2);
      path.lineTo(center.dx - s.size / 4, center.dy);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => true;
}
