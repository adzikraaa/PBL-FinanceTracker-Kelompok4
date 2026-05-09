import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../data/models/saving_model.dart';
import '../../main.dart';

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
      duration: const Duration(seconds: 4),
    )..repeat();

    _sparkles = List.generate(
      15,
      (_) => _Sparkle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 10 + 4,
        opacity: _rng.nextDouble() * 0.4 + 0.1,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 1.0 + 0.5,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SavingViewModel>();
      if (widget.existingSaving != null) {
        vm.loadForEdit(widget.existingSaving!);
        _titleController.text = widget.existingSaving!.title;
        _currentController.text = _formatNumber(widget.existingSaving!.currentAmount.toStringAsFixed(0));
        _targetController.text = _formatNumber(widget.existingSaving!.targetAmount.toStringAsFixed(0));
      } else {
        vm.resetForm();
      }
    });
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
        backgroundColor: const Color(0xFF0D2818),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
        ),
        title: const Text(
          'Kembali',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, _) {
                return Stack(
                  children: _sparkles.map((s) {
                    final t = _sparkleController.value;
                    final move = math.sin(t * 2 * math.pi * s.speed + s.phase) * 20;
                    return Positioned(
                      left: MediaQuery.of(context).size.width * s.x,
                      top: MediaQuery.of(context).size.height * s.y + move,
                      child: Opacity(
                        opacity: s.opacity * (0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase)),
                        child: Icon(
                          Icons.auto_awesome,
                          color: const Color(0xFF4AFF91).withOpacity(0.2),
                          size: s.size,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Upload gambar placeholder atau pratinjau
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTap: () => vm.pickImage(),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: vm.imageUrl != null
                          ? Container(
                              key: ValueKey(vm.imageUrl),
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                image: DecorationImage(
                                  image: _getImageProvider(vm, vm.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Icon(Icons.edit, color: Colors.white, size: 32),
                                ),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: Color(0xFF4AFF91), size: 40),
                                SizedBox(height: 12),
                                Text('Unggah Gambar Tabungan',
                                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('JPG, JPEG, PNG (MAX 5MB)',
                                    style: TextStyle(
                                        color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            _buildLabel('NAMA'),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g., European Summer Tour',
              onChanged: (val) => vm.title = val,
              errorText: vm.errorMessage != null &&
                      (vm.errorMessage!.contains('Nama') || vm.errorMessage!.contains('kosong'))
                  ? vm.errorMessage
                  : null,
            ),
            const SizedBox(height: 20),

            _buildLabel('NOMINAL TABUNGAN'),
            _buildNumberField(
              controller: _currentController,
              onChanged: (val) {
                final cleanVal = val.replaceAll('.', '');
                vm.currentAmount = double.tryParse(cleanVal) ?? 0;
                setState(() {}); // Update to show warning
              },
            ),
            if ((double.tryParse(_currentController.text.replaceAll('.', '')) ?? 0) >= 1000000000)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Batas maksimal 1 Miliar telah tercapai',
                  style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 20),

            _buildLabel('NOMINAL TARGET'),
            _buildNumberField(
              controller: _targetController,
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
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Batas maksimal 1 Miliar telah tercapai',
                  style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AFF91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final success =
                            await vm.saveSaving(widget.userId);
                        
                        if (success) {
                          final messenger = MyApp.scaffoldMessengerKey.currentState;
                          messenger?.hideCurrentSnackBar();
                          messenger?.showSnackBar(
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
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            // Jika mode edit, pop lagi untuk balik ke list
                            if (widget.existingSaving != null) {
                              Navigator.pop(context);
                            }
                          }
                        } else {
                          final messenger = MyApp.scaffoldMessengerKey.currentState;
                          messenger?.hideCurrentSnackBar();
                          messenger?.showSnackBar(
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
                              backgroundColor: Colors.red.shade900,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Batal
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF163520),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
      ],
    ),
  );
}

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4AFF91),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4AFF91)),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText,
                style:
                    const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required Function(String) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('RP  ',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ThousandSeparatorFormatter(),
                ],
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF4AFF91)),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText,
                style:
                    const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  ImageProvider _getImageProvider(SavingViewModel vm, String url) {
    if (url.startsWith('data:image') && vm.cachedImageData != null) {
      return MemoryImage(vm.cachedImageData!);
    }
    try {
      if (url.startsWith('data:image')) {
        final parts = url.split(',');
        if (parts.length < 2) return const AssetImage('assets/images/logo.png');
        final base64String = parts.last;
        return MemoryImage(base64Decode(base64String));
      }
      return NetworkImage(url);
    } catch (e) {
      return const AssetImage('assets/images/logo.png');
    }
  }
}

class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll('.', '');
    
    // Batasan maksimal 1 Miliar (1,000,000,000)
    if (cleanText.length > 10) {
      cleanText = cleanText.substring(0, 10);
    }
    final double? val = double.tryParse(cleanText);
    if (val != null && val > 1000000000) {
      cleanText = '1000000000';
    }

    final String formatted = cleanText.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}