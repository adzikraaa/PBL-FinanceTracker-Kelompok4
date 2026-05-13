import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';

// --- Model untuk State Lokal Penjualan ---
class SalesItem {
  final String namaProduk;
  final double profitPerCup;
  int quantity;

  SalesItem({
    required this.namaProduk,
    required this.profitPerCup,
    this.quantity = 0,
  });
}

class InsightView extends StatefulWidget {
  const InsightView({super.key});

  @override
  State<InsightView> createState() => _InsightViewState();
}

class _InsightViewState extends State<InsightView> with TickerProviderStateMixin {
  final List<String> _periods = [
    'Januari 2026', 'Februari 2026', 'Maret 2026', 'April 2026', 'Mei 2026',
  ];
  String _selectedPeriod = 'Januari 2026';
  
  double _targetProfit = 0.0;
  List<SalesItem> _salesData = [];
  bool _isDataLoaded = false;
  
  final _targetController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadProductsFromHistory();
      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  // --- Logic ---
  void _loadProductsFromHistory() {
    final finance = context.read<FinanceViewModel>();
    final history = finance.history;
    
    // Jika belum ada data sama sekali, biarkan kosong (Bukan dummy)
    Map<String, SalesItem> uniqueProducts = {};
    for (var item in history) {
      double modalPerUnit = item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0;
      double profit = item.hargaJualUnit - modalPerUnit;
      
      uniqueProducts[item.namaProduk] = SalesItem(
        namaProduk: item.namaProduk,
        profitPerCup: profit > 0 ? profit : 0,
        quantity: 0, // Default 0 sebelum diinput user
      );
    }
    
    setState(() {
      _salesData = uniqueProducts.values.toList();
    });
  }

  double get _untungTerkumpul {
    double total = 0;
    for (var item in _salesData) {
      total += (item.profitPerCup * item.quantity);
    }
    return total;
  }

  int get _totalTerjual {
    int total = 0;
    for (var item in _salesData) {
      total += item.quantity;
    }
    return total;
  }

  double get _sisaKeTarget {
    double sisa = _targetProfit - _untungTerkumpul;
    return sisa > 0 ? sisa : 0;
  }

  double get _percentAchieved {
    if (_targetProfit <= 0) return 0.0;
    double percent = _untungTerkumpul / _targetProfit;
    return percent > 1.0 ? 1.0 : percent;
  }

  // --- Formatter ---
  String _formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';
    if (amount >= 1000000) {
      double val = amount / 1000000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} Jt';
    } else if (amount >= 1000) {
      double val = amount / 1000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} Rb';
    }
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatCurrencyFull(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818), // Dark Green Background
      body: Stack(
        children: [
          // Background subtle glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34A853).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildMainProgressCard(),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(),
                  const SizedBox(height: 24),
                  _buildCatatPenjualanSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Insight',
                  style: TextStyle(
                    color: Color(0xFF86EFAC), // Bright Green
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Grafik Perhitungan HPP & BEP',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                style: const TextStyle(color: Color(0xFF163520), fontSize: 13, fontWeight: FontWeight.w600),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF163520), size: 18),
                items: _periods
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedPeriod = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProgressCard() {
    int percentInt = (_percentAchieved * 100).round();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Top (Empty space for Set Target button)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _showEditDataModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3E635), // Light Yellow-Green
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle_outline, color: Color(0xFF163520), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Set Target',
                          style: TextStyle(
                            color: Color(0xFF163520),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Circular Progress
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _targetProfit == 0 ? 0 : _percentAchieved,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFDCFCE7), // Very light green
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)), // Solid green
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _targetProfit == 0 ? '0%' : '$percentInt%',
                        style: const TextStyle(
                          color: Color(0xFF163520),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'tercapai',
                        style: TextStyle(
                          color: Color(0xFF4B5563), // Gray
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF22C55E), 'Untung terkumpul'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFDCFCE7), 'Kurang dari target'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Alert Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _targetProfit == 0 
                          ? 'Belum ada target. Set target profit Anda sekarang!'
                          : percentInt >= 100 
                              ? 'Luar biasa! Target profit Anda telah tercapai.'
                              : 'Bagus! Kamu sudah mencapai $percentInt% dari target. Terus catat penjualan untuk mencapai target!',
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.2, // Width to height ratio
        children: [
          _buildMetricCard('UNTUNG TERKUMPUL', _formatCurrency(_untungTerkumpul), true),
          _buildMetricCard('SISA KE TARGET', _formatCurrency(_sisaKeTarget), false),
          _buildMetricCard('TARGET PROFIT', _formatCurrency(_targetProfit), false),
          _buildMetricCard('TOTAL TERJUAL', '$_totalTerjual cup', true, hasGlow: true),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, bool isDark, {bool hasGlow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A2B) : const Color(0xFFA3E635),
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF86EFAC).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF163520).withOpacity(0.6),
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF163520),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatPenjualanSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF122A1C), // Darker panel
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catat Penjualan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih produk & jumlah yang laku hari ini',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            
            // List Produk
            if (_salesData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada produk di Riwayat HPP.\nSilakan hitung HPP terlebih dahulu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              )
            else
              ..._salesData.map((item) => _buildProductRow(item)),

            const SizedBox(height: 16),
            
            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _salesData.isEmpty ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Penjualan berhasil dicatat!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80), // Bright Green
                  foregroundColor: const Color(0xFF0D2818),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.save_alt, size: 20),
                label: const Text(
                  'Simpan Penjualan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(SalesItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Produk Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Untung/cup: ${_formatCurrencyFull(item.profitPerCup)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // Counter
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (item.quantity > 0) {
                    setState(() => item.quantity--);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.remove, color: Colors.white70, size: 16),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => item.quantity++);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Modal Edit Data / Set Target ---
  void _showEditDataModal() {
    _targetController.text = _targetProfit > 0 ? _targetProfit.toInt().toString() : '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0D2818),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Data',
                        style: TextStyle(
                          color: Color(0xFF86EFAC),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Target Profit Input
                  const Text(
                    'TARGET PROFIT',
                    style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF163520),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Goal',
                          style: TextStyle(color: Color(0xFF22C55E), fontSize: 10),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Rp ',
                              style: TextStyle(color: Color(0xFF4ADE80), fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _targetController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(color: Colors.white24),
                                ),
                                onChanged: (val) {
                                  // Kosongkan agar logic di simpan saja
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Live Catat Penjualan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'CATAT PENJUALAN',
                        style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1),
                      ),
                      Text(
                        'LIVE',
                        style: TextStyle(color: Color(0xFF86EFAC), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_salesData.isEmpty)
                    const Text('Belum ada produk.', style: TextStyle(color: Colors.white54, fontSize: 13))
                  else
                    ..._salesData.map((item) => _buildModalProductRow(item, setModalState)),
                  
                  const SizedBox(height: 24),
                  
                  // Summary in Modal
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1F12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Penjualan Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          _formatCurrencyFull(_untungTerkumpul),
                          style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Simpan Perubahan Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _targetProfit = double.tryParse(_targetController.text) ?? 0.0;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Target dan Penjualan berhasil diperbarui!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD60A), // Yellow
                        foregroundColor: const Color(0xFF1A0F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.save_outlined, size: 22),
                      label: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalProductRow(SalesItem item, StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF163520),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Dummy product icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1F12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.coffee, color: Colors.white54, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaProduk,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatCurrencyFull(item.profitPerCup),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
            // Counter
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (item.quantity > 0) {
                      setState(() { item.quantity--; }); // Update main screen
                      setModalState(() {}); // Update modal
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4A2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, color: Colors.white54, size: 16),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() { item.quantity++; }); // Update main screen
                    setModalState(() {}); // Update modal
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4A2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
