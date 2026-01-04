import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:red_panda_tracker/services/hive_service.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';
import 'package:red_panda_tracker/providers/index.dart';
import 'package:red_panda_tracker/screens/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for web
  await Hive.initFlutter();
  await HiveService.init();
  // Ensure Google Sheet tabs/headers exist (no-auth Apps Script)
  await SheetApi().initSheets();

  // Food database starts empty - users add their own via Chef's Creation

  runApp(const CalorieCommanderApp());
}

class CalorieCommanderApp extends StatelessWidget {
  const CalorieCommanderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        title: 'Calorie Commander',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF27D52), // Soft Coral/Orange
            surface: Colors.white,
            error: Color(0xFFE53935), // Bowl Red
            onPrimary: Colors.white,
            onSurface: Color(0xFF4A342E), // Deep Warm Brown
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFDF9),
          textTheme: GoogleFonts.quicksandTextTheme(),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF27D52),
            foregroundColor: Colors.white,
            shape: CircleBorder(),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
