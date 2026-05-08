import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../data/models/saving_model.dart';

class SavingFormPage extends StatefulWidget {
  final String userId;
  final SavingModel? existingSaving;
  const SavingFormPage({super.key, required this.userId, this.existingSaving});

  @override
  State<SavingFormPage> createState() => _SavingFormPageState();
}

class _SavingFormPageState extends State<SavingFormPage> {
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
    final vm = context.read<SavingViewModel>();
    if (widget.existingSaving != null) {
      vm.loadForEdit(widget.existingSaving!);
      _titleController.text = widget.existingSaving!.title;
      _currentController.text = _formatNumber(widget.existingSaving!.currentAmount.toStringAsFixed(0));
      _targetController.text = _formatNumber(widget.existingSaving!.targetAmount.toStringAsFixed(0));
    }
  }

  @override
  void dispose() {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload gambar placeholder atau pratinjau
            GestureDetector(
              onTap: () => vm.pickImage(),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF163520),
                  borderRadius: BorderRadius.circular(16),
                  image: vm.imageUrl != null
                      ? DecorationImage(
                          image: _getImageProvider(vm.imageUrl!),
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
                          Text('Unggah gambar',
                              style: TextStyle(color: Colors.white70)),
                          Text('JPG, JPEG, PNG (MAX 5MB)',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12)),
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
                      vm.errorMessage!.contains('kosong')
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
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('NOMINAL TARGET'),
            _buildNumberField(
              controller: _targetController,
              onChanged: (val) {
                final cleanVal = val.replaceAll('.', '');
                vm.targetAmount = double.tryParse(cleanVal) ?? 0;
              },
              errorText: vm.errorMessage != null &&
                      vm.errorMessage!.contains('valid')
                  ? vm.errorMessage
                  : null,
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

  ImageProvider _getImageProvider(String url) {
    try {
      if (url.startsWith('data:image')) {
        final parts = url.split(',');
        if (parts.length < 2) return const AssetImage('assets/images/logo.png');
        final base64String = parts.last;
        return MemoryImage(base64Decode(base64String));
      }
      return NetworkImage(url);
    } catch (e) {
      // Jika gagal decode, tampilkan placeholder agar tidak crash
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

    final String cleanText = newValue.text.replaceAll('.', '');
    final String formatted = cleanText.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}