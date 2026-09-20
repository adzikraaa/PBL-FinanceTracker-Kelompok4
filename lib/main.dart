import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/config/firebase_options.dart';
import 'shared/colors.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/saving_viewmodel.dart';
import 'viewmodels/finance_viewmodel.dart';
import 'viewmodels/loadingscreen.dart';
import 'viewmodels/riwayat_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'viewmodels/premium_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  //await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => FinanceViewModel()),
        ChangeNotifierProvider(create: (_) => RiwayatViewModel()),
        ChangeNotifierProvider(create: (_) => SavingViewModel()),
        ChangeNotifierProvider(create: (_) => PremiumViewModel()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: MyApp.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'BizPrice Tracker',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryPurple,
            secondary: AppColors.accentYellow,
            surface: AppColors.darkCard,
            error: AppColors.errorRed,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.darkBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.darkScaffold,
            elevation: 0,
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF132A1D),
            contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
            actionTextColor: Color(0xFF6CF688),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        // Tampilkan LoadingScreen saat pertama kali buka app
        home: const LoadingScreen(),
      ),
    );
  }
}
