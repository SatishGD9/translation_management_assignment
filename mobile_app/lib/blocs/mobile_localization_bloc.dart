import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/mobile_localization_event.dart';
import 'package:mobile_app/services/mock_mobile_translation_service.dart';
import '../localization/app_localization.dart';
import 'mobile_localization_state.dart';

class MobileLocalizationBloc
    extends Bloc<MobileLocalizationEvent, MobileLocalizationState> {
  final MockMobileTranslationService _translationService;
  AppLocalizations? _currentLocalizations;

  MobileLocalizationBloc(this._translationService)
      : super(const MobileLocalizationState(currentLocale: Locale('en'))) {
    // Default locale
    on<LoadInitialLocalization>(_onLoadInitialLocalization);
    on<SwitchLocaleEvent>(_onSwitchLocale);
    on<UpdateTranslationsFromServer>(_onUpdateTranslationsFromServer);
    on<GetTranslations>(_onGetTranslations);
  }

  Future<void> _onLoadInitialLocalization(LoadInitialLocalization event,
      Emitter<MobileLocalizationState> emit) async {
    emit(state.copyWith(isLoading: true, currentLocale: event.initialLocale));
    await _loadTranslationsForLocale(event.initialLocale, emit,
        useServerTranslations: false);
  }

  Future<void> _onSwitchLocale(
      SwitchLocaleEvent event, Emitter<MobileLocalizationState> emit) async {
    if (event.newLocale == state.currentLocale) return;
    emit(state.copyWith(
        isLoading: true, currentLocale: event.newLocale, clearError: true));
    // When switching locale, try to use already fetched server translations first
    await _loadTranslationsForLocale(event.newLocale, emit,
        useServerTranslations: true);
  }

  Future<void> _onUpdateTranslationsFromServer(
      UpdateTranslationsFromServer event,
      Emitter<MobileLocalizationState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final allNewTranslations =
          await _translationService.fetchAllTranslations();
      final serverTranslationsMap = Map<String, Map<String, String>>.from(
          allNewTranslations.map(
              (key, value) => MapEntry(key, Map<String, String>.from(value))));

      emit(state.copyWith(allServerTranslations: serverTranslationsMap));
      // After updating all translations, reload for the current locale
      await _loadTranslationsForLocale(state.currentLocale, emit,
          useServerTranslations: true);
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, error: "Failed to fetch all translations: $e"));
    }
  }

  Future<void> _loadTranslationsForLocale(
      Locale locale, Emitter<MobileLocalizationState> emit,
      {required bool useServerTranslations}) async {
    _currentLocalizations = AppLocalizations(locale);
    bool success = false;

    if (useServerTranslations &&
        state.allServerTranslations.containsKey(locale.languageCode)) {
      // Use translations fetched from server if available for this locale
      final localeSpecificTranslations =
          state.allServerTranslations[locale.languageCode]!;
      await _currentLocalizations!.loadFromMap(localeSpecificTranslations);
      success = true;
      debugPrint("Loaded ${locale.languageCode} from server cache.");
    } else {
      // Fallback to mock service for individual locale (or initial asset load if service fails)
      try {
        final Map<String, String> translations =
            await _translationService.fetchTranslations(locale.languageCode);
        if (translations.isNotEmpty) {
          await _currentLocalizations!.loadFromMap(translations);
          success = true;
          debugPrint("Loaded ${locale.languageCode} from mock service.");
        } else {
          // If service returns empty, try loading from local assets as a last resort
          debugPrint(
              "Mock service returned empty for ${locale.languageCode}, trying local assets.");
          await _currentLocalizations!
              .load(); // Tries assets/translations/xx.json
          success = true; // Assume local load might have some defaults
        }
      } catch (e) {
        debugPrint(
            "Error fetching from mock service for ${locale.languageCode}: $e. Trying local assets.");
        await _currentLocalizations!
            .load(); // Load from local assets as fallback
        success = true; // Assume local load might have some defaults
      }
    }

    emit(state.copyWith(
        appLocalizations: _currentLocalizations,
        isLoading: false,
        currentLocale: locale, // Ensure currentLocale is updated
        error: success
            ? null
            : "Failed to load translations for ${locale.languageCode}",
        clearError: success));
  }

  Future<void> _onGetTranslations(
      GetTranslations event, Emitter<MobileLocalizationState> emit) async {
    emit(state.copyWith(isLoading: true));
    final translations = await _translationService.getTranslations();
    emit(state.copyWith(translations: translations, isLoading: false));
  }
}
