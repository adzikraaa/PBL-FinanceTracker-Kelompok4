import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/saving_item.dart';
import '../../viewmodels/savings_viewmodel.dart';

// ── Tema Hijau ──
const Color kHijauGelap = Color(0xFF0F2C23);
const Color kHijauCard = Color(0xFF163E32);
const Color kHijauAksen = Color(0xFF5DFF8B);
const Color kHijauTerang = Color(0xFF1B4E3E);
const Color kPutih = Colors.white;
const Color kAbu = Colors.white70;

class SavingsFormView extends StatefulWidget {
  final SavingItem? savingToEdit;

  const SavingsFormView({super.key, this.savingToEdit});

  @override
  State<SavingsFormView> createState() => _SavingsFormViewState();
}

class _SavingsFormViewState extends State<SavingsFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _currentAmountController;
  late TextEditingController _targetAmountController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.savingToEdit?.name ?? '');
    _currentAmountController = TextEditingController(
      text: widget.savingToEdit != null ? widget.savingToEdit!.currentAmount.toInt().toString() : '',
    );
    _targetAmountController = TextEditingController(
      text: widget.savingToEdit != null ? widget.savingToEdit!.targetAmount.toInt().toString() : '',
    );
    _notesController = TextEditingController(text: widget.savingToEdit?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentAmountController.dispose();
    _targetAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final vm = Provider.of<SavingsViewModel>(context, listen: false);
      final name = _nameController.text.trim();
      final current = double.tryParse(_currentAmountController.text) ?? 0;
      final target = double.tryParse(_targetAmountController.text) ?? 0;

      if (widget.savingToEdit != null) {
        // Update jumlah tabungan yang sudah ada
        vm.updateSavingAmount(widget.savingToEdit!.id, current);
      } else {
        // Tambah tabungan baru
        vm.addSaving(
          title: name,
          targetAmount: target,
          currentAmount: current,
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHijauGelap,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kHijauAksen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.savingToEdit == null ? 'Tambah Tabungan' : 'Edit Tabungan',
          style: const TextStyle(color: kPutih, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: kHijauTerang,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.savings, color: kHijauAksen, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Define Your\nGoal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kPutih,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Precise planning is the foundation of\nfinancial luxury. Fill in your vault details\nbelow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kAbu, fontSize: 12),
                    ),
                    const SizedBox(height: 32),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: kHijauCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'NAMA',
                            hint: 'e.g., European Summer Tour',
                            controller: _nameController,
                            validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'NOMINAL TABUNGAN',
                            hint: '0.00',
                            prefixText: 'RP  ',
                            controller: _currentAmountController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'NOMINAL TARGET',
                            hint: '5,000.00',
                            prefixText: 'RP  ',
                            controller: _targetAmountController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'CATATAN (OPSIONAL)',
                            style: TextStyle(color: kHijauAksen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            style: const TextStyle(color: kPutih, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Additional details or motivations...',
                              hintStyle: TextStyle(color: kAbu.withOpacity(0.5), fontSize: 14),
                              filled: true,
                              fillColor: kHijauTerang.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kHijauAksen),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHijauAksen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _saveForm,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            color: kHijauGelap,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.savingToEdit != null)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            final vm = Provider.of<SavingsViewModel>(context, listen: false);
                            vm.deleteSaving(widget.savingToEdit!.id);
                            Navigator.pop(context); // close form
                            Navigator.pop(context); // close detail if we came from detail
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          label: const Text(
                            'Delete Goal',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.note_add_outlined, color: kAbu, size: 20),
                          label: const Text(
                            'TAMBAH CATATAN',
                            style: TextStyle(
                              color: kAbu,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? prefixText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kHijauAksen,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: kPutih, fontSize: 18),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kAbu.withOpacity(0.3), fontSize: 18),
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: kHijauAksen, fontSize: 18, fontWeight: FontWeight.bold),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kHijauAksen),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: CustomPaint(
          painter: _SavingsFormBlobPainter(),
        ),
      ),
    );
  }
}

class _SavingsFormBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kHijauAksen.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.1), 180, paint);
    canvas.drawCircle(Offset(size.width * 1.0, size.height * 0.8), 250, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
