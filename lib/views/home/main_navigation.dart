import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'home_view.dart';
import '../savings/saving_list_page.dart';
import '../finance/hitung_hpp_page.dart';
import '../insight/insight_view.dart';
import '../riwayat/riwayat_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Order consistent with the icons:
    // 0: HitungHppPage
    // 1: SavingListPage
    // 2: HomeView
    // 3: InsightView
    // 4: RiwayatView
    final List<Widget> pages = [
      const HitungHppPage(),
      SavingListPage(userId: userId),
      const HomeView(),
      const InsightView(),
      const RiwayatView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      body: Stack(
        children: [
          IndexedStack(
            index: vm.selectedIndex,
            children: pages,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(HomeViewModel vm) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navWidth = constraints.maxWidth;
          final itemWidth = navWidth / navCount;
          final circleLeft = itemWidth * vm.selectedIndex + (itemWidth / 2) - circleSize / 2;

          return SizedBox(
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
                      navIcons[vm.selectedIndex],
                      color: const Color(0xFF0C1B13),
                      size: 24,
                    ),
                  ),
                ),

                // Tap areas + inactive icons
                Row(
                  children: List.generate(navCount, (i) {
                    final isActive = i == vm.selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          vm.onNavTapManual(i);
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
          );
        },
      ),
    );
  }
}