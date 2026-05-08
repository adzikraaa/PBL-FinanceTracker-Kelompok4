import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/savings_viewmodel.dart';
import 'savings_form_view.dart';

// ── Tema Hijau ──
const Color kHijauGelap = Color(0xFF0F2C23);
const Color kHijauCard = Color(0xFF163E32);
const Color kHijauAksen = Color(0xFF5DFF8B);
const Color kHijauTerang = Color(0xFF1B4E3E);
const Color kPutih = Colors.white;
const Color kAbu = Colors.white70;

class SavingsDetailView extends StatelessWidget {
  final String savingId;

  const SavingsDetailView({super.key, required this.savingId});

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
        title: const Text(
          'Kembali',
          style: TextStyle(color: kPutih, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Consumer<SavingViewModel>(
            builder: (context, vm, child) {
              final savingItem = vm.savings.firstWhere(
                (item) => item.id == savingId,
                orElse: () => vm.savings.first,
              );

              final formatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Display
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: kHijauTerang,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: savingItem.iconUrl != null
                              ? Image.asset(
                                  savingItem.iconUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                      Icons.directions_car,
                                      size: 80,
                                      color: kHijauAksen),
                                )
                              : const Icon(Icons.directions_car,
                                  size: 80, color: kHijauAksen),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'SAVINGS GOAL',
                        style: TextStyle(
                            color: kHijauAksen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        savingItem.name,
                        style: const TextStyle(
                            color: kPutih,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Progress Card
                      Container(
                        decoration: BoxDecoration(
                          color: kHijauCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PROGRESS',
                                        style: TextStyle(
                                            color: kAbu,
                                            fontSize: 10,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(savingItem.progress * 100).toInt()}%',
                                      style: const TextStyle(
                                          color: kHijauAksen,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text('Complete',
                                        style: TextStyle(
                                            color: kPutih, fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('REMAINING',
                                        style: TextStyle(
                                            color: kAbu,
                                            fontSize: 10,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatter
                                          .format(savingItem.remainingAmount),
                                      style: const TextStyle(
                                          color: kPutih,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: kHijauTerang,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: savingItem.progress,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: kHijauAksen,
                                      borderRadius: BorderRadius.circular(4),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Monthly Goal Card
                      Container(
                        decoration: BoxDecoration(
                          color: kHijauCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: kHijauAksen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('MONTHLY GOAL',
                                      style: TextStyle(
                                          color: kAbu,
                                          fontSize: 10,
                                          letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatter.format(savingItem.targetAmount /
                                        12), // Dummy calculation
                                    style: const TextStyle(
                                        color: kPutih,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kHijauTerang,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.trending_up,
                                  color: kHijauAksen, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Expected Completion Card
                      Container(
                        decoration: BoxDecoration(
                          color: kHijauCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EXPECTED COMPLETION',
                                      style: TextStyle(
                                          color: kAbu,
                                          fontSize: 10,
                                          letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(
                                    savingItem.expectedCompletion ?? 'Dec 2025',
                                    style: const TextStyle(
                                        color: kPutih,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kHijauTerang,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.calendar_today,
                                  color: kAbu, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Edit Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kHijauAksen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SavingsFormView(savingToEdit: savingItem),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit,
                              color: kHijauGelap, size: 20),
                          label: const Text(
                            'Edit Goal',
                            style: TextStyle(
                                color: kHijauGelap,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Delete Button
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
                            vm.deleteSaving(savingItem.id);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                          label: const Text(
                            'Delete Goal',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // padding bottom
                    ],
                  ),
                ),
              );
            },
          ),
          // Bottom Nav
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
            onTap: () {
              // Pop 2 times to return to HomeView
              Navigator.popUntil(context, (route) => route.isFirst);
            },
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

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: CustomPaint(
          painter: _SavingsDetailBlobPainter(),
        ),
      ),
    );
  }
}

class _SavingsDetailBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kHijauAksen.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.7), 200, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
