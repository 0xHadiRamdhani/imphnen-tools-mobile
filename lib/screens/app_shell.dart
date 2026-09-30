import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../app_strings.dart';
import '../services/app_controller.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'tools_screen.dart';
import 'security_screen.dart';
import '../services/security_workspace.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _securityWorkspace = SecurityWorkspace();

  @override
  void initState() {
    super.initState();
    _securityWorkspace.load();
  }

  @override
  void dispose() {
    _securityWorkspace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = AppControllerScope.of(context).indonesian;
    final labels = [
      tr(language, 'home'),
      tr(language, 'tools'),
      tr(language, 'favorites'),
      'Security',
      tr(language, 'settings'),
    ];
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(onOpenSecurity: _goSecurity),
            ToolsScreen(onBack: _goHome),
            const FavoritesScreen(),
            SecurityScreen(workspace: _securityWorkspace),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: isIOS
          ? GlassTabBar.bottom(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) => setState(() => _selectedIndex = index),
              indicatorExpansion: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              settings: LiquidGlassSettings(
                blur: 15,
                thickness: 30,
                glassColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x33000000)
                    : const Color(0x33FFFFFF),
              ),
              selectedIconColor: Theme.of(context).colorScheme.primary,
              unselectedIconColor: Theme.of(context).colorScheme.onSurface,
              selectedLabelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              enableBlend: false,
              iconSize: 22,
              glowOpacity: 0.0,
              tabs: [
                GlassTab(
                  icon: const Icon(Pixel.home),
                  activeIcon: const Icon(Pixel.home),
                  label: labels[0],
                  glowColor: Theme.of(context).colorScheme.primary,
                ),
                GlassTab(
                  icon: const Icon(Pixel.grid),
                  activeIcon: const Icon(Pixel.grid),
                  label: labels[1],
                  glowColor: Theme.of(context).colorScheme.primary,
                ),
                GlassTab(
                  icon: const Icon(Pixel.heart),
                  activeIcon: const Icon(Pixel.heart),
                  label: labels[2],
                  glowColor: Theme.of(context).colorScheme.primary,
                ),
                GlassTab(
                  icon: const Icon(Pixel.shield),
                  activeIcon: const Icon(Pixel.shield),
                  label: labels[3],
                  glowColor: Theme.of(context).colorScheme.primary,
                ),
                GlassTab(
                  icon: const Icon(Pixel.sliders2),
                  activeIcon: const Icon(Pixel.sliders2),
                  label: labels[4],
                  glowColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            )
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Pixel.home),
                  selectedIcon: const Icon(Pixel.home),
                  label: labels[0],
                ),
                NavigationDestination(
                  icon: const Icon(Pixel.grid),
                  selectedIcon: const Icon(Pixel.grid),
                  label: labels[1],
                ),
                NavigationDestination(
                  icon: const Icon(Pixel.heart),
                  selectedIcon: const Icon(Pixel.heart),
                  label: labels[2],
                ),
                NavigationDestination(
                  icon: const Icon(Pixel.shield),
                  selectedIcon: const Icon(Pixel.shield),
                  label: labels[3],
                ),
                NavigationDestination(
                  icon: const Icon(Pixel.sliders2),
                  selectedIcon: const Icon(Pixel.sliders2),
                  label: labels[4],
                ),
              ],
            ),
    );
  }

  void _goHome() => setState(() => _selectedIndex = 0);

  void _goSecurity() => setState(() => _selectedIndex = 3);
}
