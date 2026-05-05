import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/app_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppService()..init(),
      child: const HindiVerbsApp(),
    ),
  );
}

// ─── App Colors ───────────────────────────────────────────────────────────────

class AppColors {
  static const bg = Color(0xFF0B0B18);
  static const surface = Color(0xFF13132A);
  static const card = Color(0xFF1C1C3A);
  static const cardBright = Color(0xFF23234A);
  static const primary = Color(0xFF7C6FFF);
  static const primaryDark = Color(0xFF5A4FE0);
  static const accent = Color(0xFFFF6B9D);
  static const gold = Color(0xFFFFD700);
  static const green = Color(0xFF4ADE80);
  static const red = Color(0xFFFF5C5C);
  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF9090B8);
  static const border = Color(0xFF2A2A55);
}

// ─── App Widget ──────────────────────────────────────────────────────────────

class HindiVerbsApp extends StatelessWidget {
  const HindiVerbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'हिंदी Verbs Master',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.bg,
      ),
      cardColor: AppColors.card,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
