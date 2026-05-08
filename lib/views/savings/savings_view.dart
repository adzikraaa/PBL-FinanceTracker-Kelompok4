import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/savings_viewmodel.dart';
import '../../data/models/saving_model.dart';

const Color _kBg = Color(0xFF0D2818);
const Color _kCard = Color(0xFF163520);
const Color _kGreen = Color(0xFF4ADE80);
const Color _kGreenBtn = Color(0xFF22C55E);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite70 = Color(0xB3FFFFFF);
const Color _kWhite40 = Color(0x66FFFFFF);
const Color _kWhite20 = Color(0x33FFFFFF);

class SavingsView extends StatefulWidget {
  const SavingsView({super.key});

  @override
  State<SavingsView> createState() => _SavingsViewState();
}

class _SavingsViewState extends State<SavingsView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late AnimationController _sparkleController;

  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _sparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sparkleController.dispose();
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  String _formatRupiah(double value) {
    if (value >= 1000000) {
      final jt = value / 1000000;
      return 'Rp ${jt == jt.truncateToDouble() ? jt.toStringAsFixed(0) : jt.toStringAsFixed(1)} jt';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)} rb';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  static String _previewRupiah(String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '').trim();
    final val = double.tryParse(cleaned);
    if (val == null || val <= 0) return '';
    if (val >= 1000000000) {
      final m = val / 1000000000;
      return '= Rp ${m == m.truncateToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(2)} miliar';
    }
    if (val >= 1000000) {
      final m = val / 1000000;
      return '= Rp ${m == m.truncateToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)} juta';
    }
    if (val >= 1000) {
      return '= Rp ${(val / 1000).toStringAsFixed(0)} ribu';
    }
    return '= Rp ${val.toStringAsFixed(0)}';
  }

  void _showAddDialog(SavingsViewModel vm) {
    _nameCtrl.clear();
    _targetCtrl.clear();
    _currentCtrl.clear();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _AddSavingDialog(
        nameCtrl: _nameCtrl,
        targetCtrl: _targetCtrl,
        currentCtrl: _currentCtrl,
        onSave: () async {
          final name = _nameCtrl.text.trim();
          final target = double.tryParse(_targetCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
          final current = double.tryParse(_currentCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
          if (name.isNotEmpty && target > 0) {
            Navigator.pop(context);
            await vm.addSaving(title: name, targetAmount: target, currentAmount: current);
          }
        },
      ),
    );
  }

  void _showEditDialog(SavingsViewModel vm, SavingModel item) {
    _currentCtrl.text = item.currentAmount.toStringAsFixed(0);
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _EditSavingDialog(
        item: item,
        currentCtrl: _currentCtrl,
        formatRupiah: _formatRupiah,
        onSave: (newAmount) async {
          Navigator.pop(context);
          await vm.updateSaving(item.id!, newAmount);
        },
        onDelete: () async {
          Navigator.pop(context);
          await vm.removeSaving(item.id!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              _buildBg(),
              _buildSparkles(),
              SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      _buildHeader(context),
                      if (vm.isLoading)
                        const Expanded(child: Center(child: CircularProgressIndicator(color: _kGreen)))
                      else if (vm.error != null)
                        Expanded(child: Center(child: Text(vm.error!, style: const TextStyle(color: Colors.redAccent))))
                      else ...[
                        _buildSummaryCard(vm),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Text('Daftar Tabungan', style: TextStyle(color: _kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text('${vm.savings.length} item', style: const TextStyle(color: _kWhite40, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: vm.savings.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: vm.savings.length,
                                  itemBuilder: (_, i) => _buildSavingCard(vm.savings[i], vm, i),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 24,
                child: _buildFab(vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1F12), Color(0xFF0D2818), Color(0xFF0F2E1A)],
        ),
      ),
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _SparklesPainter(t: _sparkleController.value),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kWhite20)),
              child: const Icon(Icons.arrow_back_ios_new, color: _kWhite, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tabungan', style: TextStyle(color: _kWhite, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Kelola target tabunganmu', style: TextStyle(color: _kWhite40, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Aktif', style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SavingsViewModel vm) {
    final pct = vm.savingsPercentage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A4428), Color(0xFF163520)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kGreen.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: _kGreen.withOpacity(0.08), blurRadius: 20, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80, height: 80,
                        child: CircularProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          strokeWidth: 7,
                          backgroundColor: _kWhite20,
                          valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('${pct.toInt()}%', style: const TextStyle(color: _kWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL TERKUMPUL', style: TextStyle(color: _kWhite40, fontSize: 10, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(_formatRupiah(vm.totalSavings), style: const TextStyle(color: _kGreen, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('TOTAL TARGET', style: TextStyle(color: _kWhite40, fontSize: 10, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(_formatRupiah(vm.totalTarget), style: const TextStyle(color: _kWhite70, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress Keseluruhan', style: TextStyle(color: _kWhite70, fontSize: 12)),
                    Text('Sisa ${_formatRupiah(vm.totalTarget - vm.totalSavings)}', style: const TextStyle(color: _kWhite40, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0.0, 1.0),
                    backgroundColor: _kWhite20,
                    valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingCard(SavingModel item, SavingsViewModel vm, int idx) {
    final progress = item.targetAmount > 0 ? (item.currentAmount / item.targetAmount).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toInt();
    final sisa = item.targetAmount - item.currentAmount;
    final colors = [
      const Color(0xFF22C55E), const Color(0xFF3B82F6),
      const Color(0xFFF59E0B), const Color(0xFFEC4899), const Color(0xFF8B5CF6),
    ];
    final accent = colors[idx % colors.length];

    return GestureDetector(
      onTap: () => _showEditDialog(vm, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: _kWhite20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: accent.withOpacity(0.3))),
                  child: Icon(Icons.savings_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(color: _kWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Sisa ${_formatRupiah(sisa > 0 ? sisa : 0)}', style: const TextStyle(color: _kWhite40, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('$pct%', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatRupiah(item.currentAmount), style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(_formatRupiah(item.targetAmount), style: const TextStyle(color: _kWhite40, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: _kWhite20,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: _kCard, shape: BoxShape.circle, border: Border.all(color: _kWhite20)),
            child: const Icon(Icons.savings_outlined, color: _kWhite40, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada tabungan', style: TextStyle(color: _kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Tambahkan target tabungan pertamamu!', style: TextStyle(color: _kWhite40, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFab(SavingsViewModel vm) {
    return GestureDetector(
      onTap: () => _showAddDialog(vm),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: _kGreenBtn,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: _kGreen.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)],
        ),
        child: const Icon(Icons.add, color: Color(0xFF0D2818), size: 28),
      ),
    );
  }
}

// ── Dialog Tambah ────────────────────────────────────────────────────────────
class _AddSavingDialog extends StatefulWidget {
  final TextEditingController nameCtrl, targetCtrl, currentCtrl;
  final VoidCallback onSave;
  const _AddSavingDialog({required this.nameCtrl, required this.targetCtrl, required this.currentCtrl, required this.onSave});

  @override
  State<_AddSavingDialog> createState() => _AddSavingDialogState();
}

class _AddSavingDialogState extends State<_AddSavingDialog> {
  String _targetPreview = '';
  String _currentPreview = '';

  @override
  void initState() {
    super.initState();
    widget.targetCtrl.addListener(_updateTargetPreview);
    widget.currentCtrl.addListener(_updateCurrentPreview);
  }

  void _updateTargetPreview() {
    setState(() => _targetPreview = _SavingsViewState._previewRupiah(widget.targetCtrl.text));
  }

  void _updateCurrentPreview() {
    setState(() => _currentPreview = _SavingsViewState._previewRupiah(widget.currentCtrl.text));
  }

  @override
  void dispose() {
    widget.targetCtrl.removeListener(_updateTargetPreview);
    widget.currentCtrl.removeListener(_updateCurrentPreview);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF163520),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _kGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.savings_outlined, color: _kGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Tambah Tabungan', style: TextStyle(color: _kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            _field('Nama Tabungan', widget.nameCtrl, 'Contoh: Modal Baru'),
            const SizedBox(height: 12),
            _fieldWithPreview('Target (Rp)', widget.targetCtrl, 'Contoh: 500000000', _targetPreview),
            const SizedBox(height: 12),
            _fieldWithPreview('Sudah Terkumpul (Rp)', widget.currentCtrl, 'Contoh: 300000000', _currentPreview),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Batal', style: TextStyle(color: _kWhite40)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: widget.onSave,
                style: ElevatedButton.styleFrom(backgroundColor: _kGreenBtn, foregroundColor: const Color(0xFF0D2818), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _kWhite70, fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: const TextStyle(color: _kWhite),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: _kWhite40),
          filled: true, fillColor: _kWhite20,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ]);
  }

  Widget _fieldWithPreview(String label, TextEditingController ctrl, String hint, String preview) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _kWhite70, fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: _kWhite),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: _kWhite40),
          filled: true, fillColor: _kWhite20,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      if (preview.isNotEmpty) ...[  
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_outline, color: _kGreen, size: 13),
            const SizedBox(width: 5),
            Text(preview, style: const TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    ]);
  }
}

// ── Dialog Edit/Delete ───────────────────────────────────────────────────────
class _EditSavingDialog extends StatefulWidget {
  final SavingModel item;
  final TextEditingController currentCtrl;
  final String Function(double) formatRupiah;
  final void Function(double) onSave;
  final VoidCallback onDelete;

  const _EditSavingDialog({required this.item, required this.currentCtrl, required this.formatRupiah, required this.onSave, required this.onDelete});

  @override
  State<_EditSavingDialog> createState() => _EditSavingDialogState();
}

class _EditSavingDialogState extends State<_EditSavingDialog> {
  String _preview = '';

  @override
  void initState() {
    super.initState();
    _preview = _SavingsViewState._previewRupiah(widget.currentCtrl.text);
    widget.currentCtrl.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() => _preview = _SavingsViewState._previewRupiah(widget.currentCtrl.text));
  }

  @override
  void dispose() {
    widget.currentCtrl.removeListener(_updatePreview);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF163520),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(widget.item.title, style: const TextStyle(color: _kWhite, fontSize: 16, fontWeight: FontWeight.bold))),
              IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22)),
            ]),
            const SizedBox(height: 4),
            Text('Target: ${widget.formatRupiah(widget.item.targetAmount)}', style: const TextStyle(color: _kWhite40, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('Update jumlah terkumpul (Rp)', style: TextStyle(color: _kWhite70, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: widget.currentCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: _kWhite),
              decoration: InputDecoration(
                hintText: 'Jumlah saat ini', hintStyle: const TextStyle(color: _kWhite40),
                filled: true, fillColor: _kWhite20,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            if (_preview.isNotEmpty) ...[  
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline, color: _kGreen, size: 13),
                  const SizedBox(width: 5),
                  Text(_preview, style: const TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Batal', style: TextStyle(color: _kWhite40)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(widget.currentCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
                  widget.onSave(val.clamp(0, widget.item.targetAmount));
                },
                style: ElevatedButton.styleFrom(backgroundColor: _kGreenBtn, foregroundColor: const Color(0xFF0D2818), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Sparkles Painter ─────────────────────────────────────────────────────────
class _SparklesPainter extends CustomPainter {
  final double t;
  static final _rng = Random(42);
  static final _sparkles = List.generate(18, (_) => [_rng.nextDouble(), _rng.nextDouble() * 0.5, _rng.nextDouble() * 6 + 3, _rng.nextDouble() * 2 * pi, _rng.nextDouble() * 1.5 + 0.5]);

  _SparklesPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _sparkles) {
      final pulse = (sin(t * 2 * pi * s[4] + s[3]) + 1) / 2;
      final opacity = (0.5 * pulse).clamp(0.0, 1.0);
      if (opacity < 0.05) continue;
      final paint = Paint()..color = const Color(0xFF4ADE80).withOpacity(opacity)..style = PaintingStyle.fill;
      final cx = s[0] * size.width;
      final cy = s[1] * size.height;
      final r = s[2] * (0.7 + 0.3 * pulse);
      final path = Path();
      for (int i = 0; i < 8; i++) {
        final a = i * pi / 4 - pi / 2;
        final rad = i.isEven ? r : r * 0.35;
        final x = cx + cos(a) * rad;
        final y = cy + sin(a) * rad;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter old) => old.t != t;
}
