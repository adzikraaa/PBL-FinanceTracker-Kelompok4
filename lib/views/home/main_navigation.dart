import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/saving_viewmodel.dart';
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
  late final String _userId;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Build pages once so they are NOT recreated on every build()
    _pages = [
      const HitungHppPage(),
      SavingListPage(userId: _userId),
      const HomeView(),
      const InsightView(),
      const RiwayatView(),
    ];

    // Pre-initialise the SavingViewModel listener so data is available
    // immediately (Home card, Insight, etc.).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SavingViewModel>().listenSavings(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      // extendBody allows the page content to extend BEHIND the navbar
      // so we keep the floating-over-content visual effect.
      extendBody: true,
      body: IndexedStack(
        index: vm.selectedIndex,
        children: _pages,
      ),
      // Using bottomNavigationBar guarantees it renders on the very first
      // frame, unlike Stack+Positioned+LayoutBuilder which can have
      // first-frame timing issues on Flutter web.
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

    // Use MediaQuery for width instead of LayoutBuilder to avoid
    // first-frame constraint timing issues.
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 40; // accounting for left+right padding
    final itemWidth = navWidth / navCount;
    final circleLeft =
        itemWidth * vm.selectedIndex + (itemWidth / 2) - circleSize / 2;

    return Container(
      // Transparent background so extendBody works (content shows behind)
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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
      ),
    );
  }
}