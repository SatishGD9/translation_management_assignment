import 'package:admin_web_app/blocs/admin_translations_event.dart';
import 'package:admin_web_app/blocs/admin_translations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web_app/services/mock_admin_translation_service.dart';


class AdminTranslationsBloc extends Bloc<AdminTranslationsEvent, AdminTranslationsState> {
  final MockAdminTranslationService _translationService;

  AdminTranslationsBloc(this._translationService) : super(AdminTranslationsInitial()) {
    on<LoadAdminTranslations>(_onLoadTranslations);
    on<AddAdminTranslation>(_onAddTranslation);
    on<UpdateAdminTranslation>(_onUpdateTranslation);
    on<DeleteAdminTranslation>(_onDeleteTranslation);
  }

  Future<void> _onLoadTranslations(
      LoadAdminTranslations event, Emitter<AdminTranslationsState> emit) async {
    emit(AdminTranslationsLoading());
    try {
      final translations = await _translationService.getTranslations();
      emit(AdminTranslationsLoaded(translations));
    } catch (e) {
      emit(AdminTranslationsError(e.toString()));
    }
  }

  Future<void> _onAddTranslation(
      AddAdminTranslation event, Emitter<AdminTranslationsState> emit) async {
    // In a real app, you might want to show a loading state for the item being added
    // For simplicity, we'll just reload all after modification
    try {
      await _translationService.addTranslation(event.key, event.values);
      add(LoadAdminTranslations()); // Reload list
    } catch (e) {
      // Handle error, maybe emit a specific error state or keep current
      emit(AdminTranslationsError("Failed to add: ${e.toString()}"));
      // Optionally reload to revert to previous state if optimistic update failed
      add(LoadAdminTranslations());
    }
  }

  Future<void> _onUpdateTranslation(
      UpdateAdminTranslation event, Emitter<AdminTranslationsState> emit) async {
    try {
      await _translationService.updateTranslation(event.entry);
      add(LoadAdminTranslations());
    } catch (e) {
      emit(AdminTranslationsError("Failed to update: ${e.toString()}"));
      add(LoadAdminTranslations());
    }
  }

  Future<void> _onDeleteTranslation(
      DeleteAdminTranslation event, Emitter<AdminTranslationsState> emit) async {
    try {
      await _translationService.deleteTranslation(event.id);
      add(LoadAdminTranslations());
    } catch (e) {
      emit(AdminTranslationsError("Failed to delete: ${e.toString()}"));
      add(LoadAdminTranslations());
    }
  }
}