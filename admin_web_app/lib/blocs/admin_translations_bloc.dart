import 'package:admin_web_app/blocs/admin_translations_event.dart';
import 'package:admin_web_app/blocs/admin_translations_state.dart';
import 'package:admin_web_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web_app/services/mock_admin_translation_service.dart';

class AdminTranslationsBloc
    extends Bloc<AdminTranslationsEvent, AdminTranslationsState> {
  final MockAdminTranslationService _translationService;

  AdminTranslationsBloc(this._translationService)
      : super(AdminTranslationsInitial()) {
    on<LoadAdminTranslations>(_loadTranslations);
    on<AddAdminTranslation>(_onAddTranslation);
    on<UpdateAdminTranslation>(_onUpdateTranslation);
    on<DeleteAdminTranslation>(_onDeleteTranslation);
  }

  Future<void> _loadTranslations(
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
    try {
      bool translations =
          await _translationService.addTranslation(event.key, event.values);
      if (translations) {
        add(LoadAdminTranslations());
        ScaffoldMessenger.of(Constants.navigatorKey.currentContext!)
            .showSnackBar(
          const SnackBar(
            content: Text("Translation added successfully"),
          ),
        );
      } else {
        emit(const AdminTranslationsError("Failed to add"));
      }
    } catch (e, message) {
      debugPrint("Failed to add: ${e.toString()} $message");
      emit(AdminTranslationsError("Failed to add: ${e.toString()} $message"));
    }
  }

  Future<void> _onUpdateTranslation(UpdateAdminTranslation event,
      Emitter<AdminTranslationsState> emit) async {
    try {
      bool result = await _translationService.updateTranslation(event.entry);
      if (result) {
        add(LoadAdminTranslations());
        ScaffoldMessenger.of(Constants.navigatorKey.currentContext!)
            .showSnackBar(
          const SnackBar(
            content: Text("Translation updated successfully"),
          ),
        );
      }
    } catch (e) {
      emit(AdminTranslationsError("Failed to update: ${e.toString()}"));
      add(LoadAdminTranslations());
    }
  }

  Future<void> _onDeleteTranslation(DeleteAdminTranslation event,
      Emitter<AdminTranslationsState> emit) async {
    try {
      bool result = await _translationService.deleteTranslations(event.id);
      if (result) {
        add(LoadAdminTranslations());
        ScaffoldMessenger.of(Constants.navigatorKey.currentContext!)
            .showSnackBar(
          const SnackBar(
            content: Text("Translation deleted successfully"),
          ),
        );
      }
    } catch (e) {
      emit(AdminTranslationsError("Failed to delete: ${e.toString()}"));
      add(LoadAdminTranslations());
    }
  }
}
