import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Import file konfigurasi yang kamu generate tadi
import 'shared/colors.dart'; // Import color palette
import 'viewmodels/auth_viewmodel.dart'; // Import AuthViewModel
import 'views/welcome_view.dart'; // Import WelcomeView

void main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BizPrice Tracker',
        theme: ThemeData(
          // Dark theme dengan color scheme dari Figma
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
        home: const WelcomeView(),
      ),
    );
  }
}
