// mobile_app/lib/services/mock_mobile_translation_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translation_domain/translation_domain.dart';

class MockMobileTranslationService {
  Future<Map<String, String>> fetchTranslations(String locale) async {
    debugPrint(
        "MockMobileTranslationService: Fetching translations for locale '$locale'...");
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network

    if (locale == 'en') {
      return {
        "appTitle": "My App",
        "greeting":
            "Hello from Asset!", // Or "Hello from Mock!" if you want to differentiate from asset only slightly
        "farewell": "Goodbye from Asset!",
        "refresh_translations_button": "Refresh Translations",
        "missing_key_example": "This key exists in EN"
      };
    } else if (locale == 'es') {
      return {
        "appTitle": "Mi Aplicación",
        "greeting": "¡Hola desde Archivo!",
        "farewell": "¡Adiós desde Archivo!",
        "refresh_translations_button": "Actualizar Traducciones"
      };
    } else if (locale == 'fr') {
      return {
        "appTitle": "Mon Application",
        "greeting": "Bonjour de Fichier!",
        "farewell": "Au revoir de Fichier!",
        "refresh_translations_button": "Actualiser les Traductions"
      };
    }
    debugPrint(
        "MockMobileTranslationService: Locale '$locale' not found, returning empty map.");
    return {}; // Default empty for unsupported locales
  }

  Future<Map<String, dynamic>> fetchAllTranslations() async {
    debugPrint("MockMobileTranslationService: Fetching all translations...");
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    return {
      'en': {
        "appTitle": "My App",
        "greeting": "Hello from Asset!",
        "farewell": "Goodbye from Asset!",
        "refresh_translations_button": "Refresh Translations",
        "missing_key_example": "This key exists in EN"
      },
      'es': {
        "appTitle": "Mi Aplicación",
        "greeting": "¡Hola desde Archivo!",
        "farewell": "¡Adiós desde Archivo!",
        "refresh_translations_button": "Actualizar Traducciones"
      },
      'fr': {
        "appTitle": "Mon Application",
        "greeting": "Bonjour de Fichier!",
        "farewell": "Au revoir de Fichier!",
        "refresh_translations_button": "Actualiser les Traductions"
      }
    };
  }

  Future<List<TranslationEntry>> getTranslations() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
    List<TranslationEntry> translations = [];
    QuerySnapshot<Map<String, dynamic>> transaction = await FirebaseFirestore
        .instance
        .collection('translations')
        .get(); // await FileBasedTranslationService.getTranslations();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in transaction.docs) {
      final data = doc.data();

      // Access values from the document
      String recordId = doc.id; // document ID

      // Example: if you're storing multiple TranslationEntry objects in each doc
      data.forEach((key, value) {
        // You can also convert to a TranslationEntry if you want:
        final entry = TranslationEntry(
          id: value['id'],
          key: value['key'],
          recordId: recordId,
          translations: Map<String, String>.from(value['translations']),
        );
        translations.add(entry);
        print('Parsed TranslationEntry: ${entry.key} → ${entry.translations}');
      });
    }
    print(transaction.docs.length);
    return translations;
  }
}
