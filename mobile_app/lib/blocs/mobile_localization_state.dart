import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/localization/app_localization.dart';

class MobileLocalizationState extends Equatable {
  final Locale currentLocale;
  final AppLocalizations? appLocalizations; // Holds loaded strings
  final bool isLoading;
  final String? error;
  // This stores all translations fetched from server, structured by locale
  final Map<String, Map<String, String>> allServerTranslations;

  const MobileLocalizationState({
    required this.currentLocale,
    this.appLocalizations,
    this.isLoading = false,
    this.error,
    this.allServerTranslations = const {},
  });

  MobileLocalizationState copyWith({
    Locale? currentLocale,
    AppLocalizations? appLocalizations,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, Map<String, String>>? allServerTranslations,
  }) {
    return MobileLocalizationState(
      currentLocale: currentLocale ?? this.currentLocale,
      appLocalizations: appLocalizations ?? this.appLocalizations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      allServerTranslations: allServerTranslations ?? this.allServerTranslations,
    );
  }

  @override
  List<Object?> get props => [currentLocale, appLocalizations, isLoading, error, allServerTranslations];
}
