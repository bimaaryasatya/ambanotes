import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static const _prefKey = 'is_dark_mode';

  final isDarkMode = false.obs;

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<ThemeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_prefKey) ?? false;
    _applySystemUi();
    return this;
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    Get.changeThemeMode(themeMode);
    _applySystemUi();
  }

  void _applySystemUi() {
    final dark = isDarkMode.value;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            dark ? const Color(0xFF0E1517) : Colors.white,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
