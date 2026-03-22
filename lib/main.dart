import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/news_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080B14),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const TruthLensApp());
}

class TruthLensApp extends StatelessWidget {
  const TruthLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsProvider(),
      child: MaterialApp(
        title: 'TruthLens',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const bg = Color(0xFF080B14);
    const surface = Color(0xFF0F1320);
    const card = Color(0xFF141826);
    const neon = Color(0xFF00FFB2);
    const neonDim = Color(0xFF00C896);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: neon,
        secondary: neonDim,
        surface: surface,
        error: Color(0xFFFF4D6D),
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D1020),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E2540), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E2540), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF5A6A8A), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF2E3D5A), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        prefixIconColor: const Color(0xFF3A4A6A),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neon,
          foregroundColor: bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
