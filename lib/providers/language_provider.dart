import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language';
  String _currentLanguage = 'vi';

  LanguageProvider() {
    _loadLanguage();
  }

  String get currentLanguage => _currentLanguage;
  Locale get locale => Locale(_currentLanguage);
  bool get isEnglish => _currentLanguage == 'en';
  bool get isVietnamese => _currentLanguage == 'vi';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'vi';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    await setLanguage(locale.languageCode);
  }
} 