import 'package:equatable/equatable.dart';
import 'package:translation_domain/translation_domain.dart';

abstract class AdminTranslationsState extends Equatable {
  const AdminTranslationsState();
  @override
  List<Object> get props => [];
}

class AdminTranslationsInitial extends AdminTranslationsState {}

class AdminTranslationsLoading extends AdminTranslationsState {}

class AdminTranslationsLoaded extends AdminTranslationsState {
  final List<TranslationEntry> translations;
  const AdminTranslationsLoaded(this.translations);
  @override
  List<Object> get props => [translations];
}

class AdminTranslationsError extends AdminTranslationsState {
  final String message;
  const AdminTranslationsError(this.message);
  @override
  List<Object> get props => [message];
}
