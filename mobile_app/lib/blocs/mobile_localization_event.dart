import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:translation_domain/translation_domain.dart';

abstract class MobileLocalizationEvent extends Equatable {
  const MobileLocalizationEvent();
  @override
  List<Object?> get props => [];
}

class LoadInitialLocalization extends MobileLocalizationEvent {
  final Locale initialLocale;
  const LoadInitialLocalization(this.initialLocale);
  @override
  List<Object?> get props => [initialLocale];
}

class SwitchLocaleEvent extends MobileLocalizationEvent {
  final Locale newLocale;
  const SwitchLocaleEvent(this.newLocale);
  @override
  List<Object?> get props => [newLocale];
}

// This event is for when new translations are fetched from the "server"
class UpdateTranslationsFromServer extends MobileLocalizationEvent {}

class GetTranslations extends MobileLocalizationEvent {
  const GetTranslations();
  @override
  List<Object> get props => [];
}
