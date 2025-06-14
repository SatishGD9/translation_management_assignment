import 'package:translation_domain/translation_domain.dart';
import 'package:uuid/uuid.dart';

class MockAdminTranslationService {
  final Map<String, TranslationEntry> _translations = {
    'greeting_id': const TranslationEntry(
      id: 'greeting_id',
      key: 'greeting',
      translations: {'en': 'Hello', 'es': 'Hola', 'fr': 'Bonjour'},
    ),
    'farewell_id': const TranslationEntry(
      id: 'farewell_id',
      key: 'farewell',
      translations: {'en': 'Goodbye', 'es': 'Adiós', 'fr': 'Au revoir'},
    ),
  };
  final _uuid = const Uuid();

  Future<List<TranslationEntry>> getTranslations() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
    return _translations.values.toList();
  }

  Future<TranslationEntry> addTranslation(String key, Map<String, String> values) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = _uuid.v4();
    final newEntry = TranslationEntry(id: id, key: key, translations: values);
    _translations[id] = newEntry;
    return newEntry;
  }

  Future<TranslationEntry> updateTranslation(TranslationEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_translations.containsKey(entry.id)) {
      _translations[entry.id] = entry;
      return entry;
    }
    throw Exception('Translation not found');
  }

  Future<void> deleteTranslation(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _translations.remove(id);
  }

  // This method will be important for the tasks
  Future<Map<String, dynamic>> exportAllTranslationsAsJsonMap() async {
    await Future.delayed(const Duration(milliseconds: 100));
    Map<String, Map<String, String>> structured = {};
    _translations.forEach((_, entry) {
      entry.translations.forEach((locale, value) {
        if (!structured.containsKey(locale)) {
          structured[locale] = {};
        }
        structured[locale]![entry.key] = value;
      });
    });
    return structured; // e.g. {'en': {'greeting': 'Hello'}, 'es': {'greeting': 'Hola'}}
  }
}