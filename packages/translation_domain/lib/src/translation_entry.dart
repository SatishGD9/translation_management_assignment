import 'package:equatable/equatable.dart';

class TranslationEntry extends Equatable {
  final String id; // Unique ID, could be the key itself if keys are unique
  final String key;
  final String recordId;
  final Map<String, String> translations; // e.g., {'en': 'Hello', 'es': 'Hola'}

  const TranslationEntry({
    required this.id,
    required this.key,
    required this.translations,
    required this.recordId,
  });

  TranslationEntry copyWith({
    String? id,
    String? key,
    String? recordId,
    Map<String, String>? translations,
  }) {
    return TranslationEntry(
      id: id ?? this.id,
      key: key ?? this.key,
      recordId: recordId ?? this.recordId,
      translations: translations ?? this.translations,
    );
  }

  @override
  List<Object?> get props => [id, key, translations, recordId];

  // For simple JSON serialization (real app might use json_serializable)
  factory TranslationEntry.fromJson(Map<String, dynamic> json) {
    return TranslationEntry(
      id: json['id'] as String,
      key: json['key'] as String,
      recordId: json['recordId'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'translations': translations,
    };
  }
}
