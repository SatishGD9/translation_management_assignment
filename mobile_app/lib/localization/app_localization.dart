import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  Map<String,String> get localizedString => _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Method to load translations from a Map (which could come from an API)
  Future<bool> loadFromMap(Map<String, String> translations) async {
    _localizedStrings = translations;
    return Future.value(true);
  }

  // Fallback: load from local JSON asset (e.g., initial_translations/en.json)
  // This will be less used once dynamic loading is fully implemented
  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      return true;
    } catch (e) {
      print("Error loading translations for ${locale.languageCode}: $e");
      // Load default (e.g., English) if current locale fails or is not found
      if (locale.languageCode != 'en') {
        print("Falling back to English translations.");
        String jsonString = await rootBundle.loadString('assets/translations/en.json');
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        _localizedStrings = jsonMap.map((key, value) {
          return MapEntry(key, value.toString());
        });
      }
      return false; // Indicate that default might be partial or failed
    }
  }


  String translate(String key) {
    return _localizedStrings[key] ?? '**$key**'; // Fallback for missing keys
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // This delegate can no longer be 'const' because it will hold data.
  final Map<String, Map<String, String>>? allServerTranslations; // Data from BLoC

  // Constructor to accept the BLoC's data
  AppLocalizationsDelegate({this.allServerTranslations});

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);

    // 1. Try to get translations for the current locale from the BLoC's data
    final Map<String, String>? serverDataForLocale = allServerTranslations?[locale.languageCode];

    if (serverDataForLocale != null && serverDataForLocale.isNotEmpty) {
      print("Delegate: Loading '${locale.languageCode}' from BLoC (serverTranslations)");
      // Use 'await' if loadFromMap is async
      await localizations.loadFromMap(serverDataForLocale);
    } else {
      // 2. If no server data for this locale, fall back to loading from local assets
      print("Delegate: No server data for '${locale.languageCode}', loading from assets.");
      await localizations.load(); // This loads from assets/translations/xx.json
    }
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) {
    // Reload if the underlying 'allServerTranslations' data has changed.
    // This is key for BLoC updates to trigger a localization reload.
    // We compare the map instances. If the BLoC creates a new map in its state,
    // this will be true.
    return old.allServerTranslations != allServerTranslations;
  }
}