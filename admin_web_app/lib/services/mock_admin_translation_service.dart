import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translation_domain/translation_domain.dart';
import 'package:uuid/uuid.dart';

class MockAdminTranslationService {
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
      });
    }
    return translations;
  }

  Future<bool> addTranslation(String key, Map<String, String> values) async {
    try {
      Uuid uuid = const Uuid();
      final id = uuid.v4();
      await FirebaseFirestore.instance.collection('translations').add(
        {
          "greeting_id": {
            "id": id,
            "key": key,
            "translations": {
              "en": values["en"],
              "es": values['es'],
              "fr": values["fr"]
            }
          }
        },
      );
      return true;
    } catch (e) {
      debugPrint("Failed to add: ${e.toString()}");
      return false;
    }
  }

  Future<bool> deleteTranslations(String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network

    try {
      await FirebaseFirestore.instance
          .collection('translations')
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      debugPrint("Failed to delete: ${e.toString()}");
      return false;
    }
  }

  Future<bool> updateTranslation(TranslationEntry entry) async {
    try {
      await FirebaseFirestore.instance
          .collection('translations')
          .doc(entry.recordId)
          .update(
        {
          "greeting_id": {
            "id": entry.id,
            "key": entry.key,
            "translations": {
              "en": entry.translations["en"],
              "es": entry.translations['es'],
              "fr": entry.translations["fr"]
            }
          }
        },
      );

      return true;
    } catch (e) {
      debugPrint("Failed to delete: ${e.toString()}");
      return false;
    }
  }
}
