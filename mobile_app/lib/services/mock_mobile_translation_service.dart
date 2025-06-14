// mobile_app/lib/services/mock_mobile_translation_service.dart

class MockMobileTranslationService {
  Future<Map<String, String>> fetchTranslations(String locale) async {
    print("MockMobileTranslationService: Fetching translations for locale '$locale'...");
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network

    if (locale == 'en') {
      return {
        "appTitle": "My App",
        "greeting": "Hello from Asset!", // Or "Hello from Mock!" if you want to differentiate from asset only slightly
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
    print("MockMobileTranslationService: Locale '$locale' not found, returning empty map.");
    return {}; // Default empty for unsupported locales
  }

  Future<Map<String, dynamic>> fetchAllTranslations() async {
    print("MockMobileTranslationService: Fetching all translations...");
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
}