import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../viewmodels/riwayat_viewmodel.dart';
import 'home_view.dart';
import '../savings/saving_list_page.dart';
import '../finance/hitung_hpp_page.dart';
import '../insight/insight_view.dart';
import '../riwayat/riwayat_view.dart';
import '../../data/services/firestore_seeder.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late final String _userId;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    _pages = [
      const HitungHppPage(),
      SavingListPage(userId: _userId),
      const HomeView(),
      const InsightView(),
      const RiwayatView(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final hasSeeded = await FirestoreSeeder.hasSeeded(user.uid);
        if (!hasSeeded) {
          await FirestoreSeeder.seedMockData(
            user.uid,
            email: user.email,
            displayName: user.displayName,
          );
        }
      }

      if (!mounted) return;
      context.read<SavingViewModel>().listenSavings(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      extendBody: true,
      body: IndexedStack(
        index: vm.selectedIndex.clamp(0, _pages.length - 1),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(context, vm),
    );
  }

  Widget _buildBottomNav(BuildContext context, HomeViewModel vm) {
    const navIcons = [
      Icons.calculate_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.home,
      Icons.show_chart,
      Icons.history,
    ];
    const int navCount = 5;
    const double navHeight = 68.0;
    const double circleSize = 48.0;
    const double circleTop = (navHeight - circleSize) / 2;

    const kNavBg = Color(0xFF132018);
    const kNavBorder = Color(0xFF2C4334);
    const kNavIcon = Color(0xFF6B7E72);
    const kNavActive = Color(0xFF6CF688);

    final screenWidth = MediaQuery.of(context).size.width;

    // Gunakan nilai maksimum antara viewPadding dan padding biasa
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    final safeBottom =
        viewPadding > paddingBottom ? viewPadding : paddingBottom;

    // Jika sistem gagal mendeteksi height navbar bawaan (seperti di beberapa Samsung)
    // atau mereturn 0, kita beri nilai default 30 agar total margin menjadi 50 (30 + 20).
    final extraPadding = safeBottom > 0 ? safeBottom : 30.0;

    // Base margin agar tidak terlalu mepet (awalnya 20)
    final baseMargin = 20.0;

    final navWidth = screenWidth - 40;
    final itemWidth = navWidth / navCount;
    final safeIndex = vm.selectedIndex.clamp(0, navCount - 1);
    final circleLeft = itemWidth * safeIndex + (itemWidth / 2) - circleSize / 2;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
          bottom: baseMargin + extraPadding, left: 20, right: 20),
      child: SizedBox(
        height: navHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background pill
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: kNavBg.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: kNavBorder, width: 1.5),
                ),
              ),
            ),

            // Animated active circle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              left: circleLeft,
              top: circleTop,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: kNavActive,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kNavActive.withOpacity(0.45),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  navIcons[safeIndex],
                  color: const Color(0xFF0C1B13),
                  size: 24,
                ),
              ),
            ),

            // Tap areas + inactive icons
            Row(
              children: List.generate(navCount, (i) {
                final isActive = i == safeIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      vm.onNavTapManual(i);
                      if (i != 4) {
                        context
                            .read<RiwayatViewModel>()
                            .clearSelectedHistoryId();
                      }
                    },
                    child: SizedBox(
                      height: navHeight,
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isActive ? 0.0 : 1.0,
                          child: Icon(
                            navIcons[i],
                            color: kNavIcon,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
