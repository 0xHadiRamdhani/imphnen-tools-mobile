import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  static const _favoritesKey = 'imphnen.mobile.favorites';
  static const _recentKey = 'imphnen.mobile.recent';
  static const _themeKey = 'imphnen.mobile.dark';
  static const _languageKey = 'imphnen.mobile.indonesian';

  Set<String> favorites = {};
  List<String> recent = [];
  bool darkMode = false;
  bool indonesian = true;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    favorites = (preferences.getStringList(_favoritesKey) ?? []).toSet();
    recent = preferences.getStringList(_recentKey) ?? [];
    darkMode = preferences.getBool(_themeKey) ?? false;
    indonesian = preferences.getBool(_languageKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (!favorites.add(id)) favorites.remove(id);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_favoritesKey, favorites.toList());
    notifyListeners();
  }

  Future<void> addRecent(String id) async {
    recent = [id, ...recent.where((item) => item != id)].take(12).toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_recentKey, recent);
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    favorites.clear();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_favoritesKey);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    recent.clear();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_recentKey);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, value);
    notifyListeners();
  }

  Future<void> setIndonesian(bool value) async {
    indonesian = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_languageKey, value);
    notifyListeners();
  }
}

class AppControllerScope extends InheritedNotifier<AppController> {
  const AppControllerScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppControllerScope>();
    assert(
      scope != null,
      'AppControllerScope is missing from the widget tree.',
    );
    return scope!.notifier!;
  }
}
