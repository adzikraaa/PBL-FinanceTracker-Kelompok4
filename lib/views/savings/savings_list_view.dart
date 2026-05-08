import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/savings_viewmodel.dart';
import 'savings_form_view.dart';
import 'savings_detail_view.dart';

// ── Tema Hijau ──
const Color kHijauGelap = Color(0xFF0F2C23);
const Color kHijauCard = Color(0xFF163E32);
const Color kHijauAksen = Color(0xFF5DFF8B);
const Color kHijauTerang = Color(0xFF1B4E3E);
const Color kPutih = Colors.white;
const Color kAbu = Colors.white70;

class SavingsListView extends StatelessWidget {
  const SavingsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHijauGelap,
      body: Stack(
        children: [
          // Background blobs
          _buildBackground(),

          SafeArea(
            child: Consumer<SavingsViewModel>(
              builder: (context, vm, child) {
                final formatter = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        'Daftar Tabungan',
                        style: TextStyle(
                          color: kAbu,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL TABUNGAN',
                            style: TextStyle(
                              color: kAbu,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatter.format(vm.totalCurrentAmount),
                            style: const TextStyle(
                              color: kHijauAksen,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        itemCount: vm.savings.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = vm.savings[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SavingsDetailView(savingId: item.id!),
                                ),
                              );
                            },
                            child: _buildSavingCard(item, formatter),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 100), // Space for FAB & Bottom Nav
                  ],
                );
              },
            ),
          ),

          // FAB
          Positioned(
            bottom: 110,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: kHijauAksen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavingsFormView(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: kHijauGelap, size: 28),
            ),
          ),

          // Bottom Nav (Dummy/Visual only for this demo to match image)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingCard(savingItem, NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        color: kHijauCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kHijauTerang,
                  borderRadius: BorderRadius.circular(12),
                  image: savingItem.iconUrl != null
                      ? DecorationImage(
                          image: AssetImage(savingItem.iconUrl!),
                          fit: BoxFit.cover,
                          onError: (e, s) => {},
                        )
                      : null,
                ),
                child: savingItem.iconUrl == null
                    ? const Icon(Icons.image, color: kHijauAksen)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savingItem.name,
                      style: const TextStyle(
                        color: kPutih,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${formatter.format(savingItem.targetAmount)}',
                      style: const TextStyle(
                        color: kAbu,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(savingItem.progress * 100).toInt()}%',
                style: const TextStyle(
                  color: kPutih,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kHijauTerang,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: savingItem.progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: kHijauAksen,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: kHijauAksen.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SALDO: ${formatter.format(savingItem.currentAmount)}',
                style: const TextStyle(
                  color: kAbu,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'SISA: ${formatter.format(savingItem.remainingAmount)}',
                style: const TextStyle(
                  color: kAbu,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: CustomPaint(
          painter: _SavingsBlobPainter(),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20, top: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: kHijauGelap,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.calculate_outlined, color: kAbu, size: 24),
          Icon(Icons.account_balance_wallet_outlined, color: kAbu, size: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kHijauCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  const Icon(Icons.home_rounded, color: kHijauAksen, size: 24),
            ),
          ),
          Icon(Icons.pie_chart_outline, color: kAbu, size: 24),
          Icon(Icons.access_time, color: kAbu, size: 24),
        ],
      ),
    );
  }
}

class _SavingsBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kHijauAksen.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.1), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 200, paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.8), 180, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
