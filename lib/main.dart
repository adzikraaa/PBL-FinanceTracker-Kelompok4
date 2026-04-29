import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/config/firebase_options.dart';
import 'shared/colors.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/welcome_view.dart';
import 'views/home/home_view.dart';
import 'viewmodels/finance_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => FinanceViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BizPrice Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
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
        ),
        // Auth Gate: Otomatis pilih halaman
        home: Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            // Kita pakai .currentUser sesuai dengan isi AuthViewModel kamu
            if (auth.currentUser != null) {
              return const HomeView(); // Jika sudah login ke Dashboard
            }
            return const WelcomeView(); // Jika belum ke Login
          }
        ),
      ),
    );
  }
}