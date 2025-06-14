import 'package:equatable/equatable.dart';
import 'package:translation_domain/translation_domain.dart';

abstract class AdminTranslationsEvent extends Equatable {
  const AdminTranslationsEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminTranslations extends AdminTranslationsEvent {}

class AddAdminTranslation extends AdminTranslationsEvent {
  final String key;
  final Map<String, String> values;
  const AddAdminTranslation(this.key, this.values);
  @override List<Object> get props => [key, values];
}

class UpdateAdminTranslation extends AdminTranslationsEvent {
  final TranslationEntry entry;
  const UpdateAdminTranslation(this.entry);
  @override List<Object> get props => [entry];
}

class DeleteAdminTranslation extends AdminTranslationsEvent {
  final String id;
  const DeleteAdminTranslation(this.id);
  @override List<Object> get props => [id];
}