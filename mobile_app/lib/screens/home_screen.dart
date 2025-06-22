import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/mobile_localization_bloc.dart';
import 'package:mobile_app/blocs/mobile_localization_event.dart';
import 'package:mobile_app/blocs/mobile_localization_state.dart';
import 'package:mobile_app/localization/app_localization.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/translation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationBloc = BlocProvider.of<MobileLocalizationBloc>(context);
    final currentLocale =
        context.watch<MobileLocalizationBloc>().state.currentLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('appTitle') ??
            'Translation App'),
        actions: [
          PopupMenuButton<Locale>(
            initialValue: currentLocale,
            onSelected: (Locale newLocale) {
              localizationBloc.add(SwitchLocaleEvent(newLocale));
            },
            itemBuilder: (BuildContext context) {
              return MobileApp.supportedLocales.map((Locale locale) {
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.languageCode.toUpperCase()),
                );
              }).toList();
            },
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: BlocConsumer<MobileLocalizationBloc, MobileLocalizationState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.error}")),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.appLocalizations == null) {
            // Only show global loader on initial load
            return const Center(child: CircularProgressIndicator());
          }
          if (state.appLocalizations == null) {
            return const Center(child: Text('Translations not loaded.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.translate('greeting'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.translate('farewell'),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.translate(
                      'missing_key_example'), // Example of a missing key
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (state
                    .isLoading) // Show loader for subsequent fetches/switches
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          localizationBloc.add(UpdateTranslationsFromServer());
                        },
                  child: Text(AppLocalizations.of(context)!
                      .translate('refresh_translations_button')),
                ),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionScreen()));
                        },
                  child: const Text("Go to Translation"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
