import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'screens/app_shell.dart';
import 'services/app_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(const ImphnenApp());
}

class ImphnenApp extends StatefulWidget {
  const ImphnenApp({super.key});

  @override
  State<ImphnenApp> createState() => _ImphnenAppState();
}

class _ImphnenAppState extends State<ImphnenApp> {
  final _controller = AppController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final dark = _controller.darkMode;
        const brandBlue = Color(0xFF6B7FE8);

        final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

        Widget app = MaterialApp(
          title: 'IMPHNEN ONLINE TOOLS',
          debugShowCheckedModeBanner: false,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: brandBlue,
              brightness: Brightness.light,
              surface: const Color(0xFFFFFBF7),
            ),
            scaffoldBackgroundColor: const Color(0xFFFFF9F5),
            fontFamily: GoogleFonts.pixelifySans().fontFamily,
            textTheme: GoogleFonts.pixelifySansTextTheme(
              ThemeData.light().textTheme,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFF9F5),
              surfaceTintColor: Colors.transparent,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFFFDDE8),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: brandBlue, width: 1.5),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFF2DEE3), width: 0.8),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFFB7A1FF),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF211F35),
                ).copyWith(
                  primary: const Color(0xFFC0B0FF),
                  secondary: const Color(0xFFFFAFC8),
                  tertiary: const Color(0xFF8DDAE3),
                  surface: const Color(0xFF211F35),
                  onSurface: const Color(0xFFF6F1FF),
                  onSurfaceVariant: const Color(0xFFC5BED6),
                  outline: const Color(0xFF5F5874),
                ),
            scaffoldBackgroundColor: const Color(0xFF171625),
            fontFamily: GoogleFonts.pixelifySans().fontFamily,
            textTheme: GoogleFonts.pixelifySansTextTheme(
              ThemeData.dark().textTheme,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF171625),
              surfaceTintColor: Colors.transparent,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF211F35),
              indicatorColor: const Color(0xFF49405F),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF252239),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFC0B0FF),
                  width: 1.5,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF211F35),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF403A56), width: 0.8),
              ),
            ),
          ),
          home: const AppShell(),
        );

        if (isIOS) {
          app = LiquidGlassWidgets.wrap(
            brightnessResolver: (context) =>
                dark ? Brightness.dark : Brightness.light,
            child: app,
          );
        }

        return AppControllerScope(controller: _controller, child: app);
      },
    );
  }
}
