import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_app/blocs/mobile_localization_bloc.dart';
import 'package:mobile_app/blocs/mobile_localization_event.dart';
import 'package:mobile_app/blocs/mobile_localization_state.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/localization/app_localization.dart';
import 'package:mobile_app/screens/home_screen.dart'; // Create this
import 'package:mobile_app/services/mock_mobile_translation_service.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Important for async before runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  static final List<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale('es', ''),
    const Locale('fr', ''),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MobileLocalizationBloc(MockMobileTranslationService())
            ..add(LoadInitialLocalization(
                supportedLocales.first)), // Load English initially
      child: BlocBuilder<MobileLocalizationBloc, MobileLocalizationState>(
        builder: (context, localizationState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dynamic Translations App',
            locale: localizationState.currentLocale,
            supportedLocales: supportedLocales,
            localizationsDelegates: [
              AppLocalizationsDelegate(
                  allServerTranslations: localizationState
                      .allServerTranslations), // Our custom delegate
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode &&
                    (locale?.countryCode == null || // Allow just 'en'
                        supportedLocale.countryCode == locale?.countryCode)) {
                  return supportedLocale;
                }
              }
              return supportedLocales
                  .first; // Default to the first supported locale
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
