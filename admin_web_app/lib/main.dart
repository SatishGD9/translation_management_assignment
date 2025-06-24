import 'package:admin_web_app/blocs/admin_translations_state.dart';
import 'package:admin_web_app/constants.dart';
import 'package:admin_web_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web_app/blocs/admin_translations_bloc.dart';
import 'package:admin_web_app/services/mock_admin_translation_service.dart';
import 'package:admin_web_app/widgets/translation_list_item.dart'; // You'll create this
import 'package:admin_web_app/widgets/translation_form.dart'; // You'll create this
import 'package:translation_domain/translation_domain.dart';

import 'blocs/admin_translations_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation Admin',
      debugShowCheckedModeBanner: false,
      navigatorKey: Constants.navigatorKey,
      home: BlocProvider(
        create: (context) =>
            AdminTranslationsBloc(MockAdminTranslationService())
              ..add(LoadAdminTranslations()),
        child: const AdminHomePage(),
      ),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<String> _supportedLocales = ['en', 'es', 'fr']; // Example

  void _showTranslationForm({TranslationEntry? entry}) {
    showDialog(
      context: context,
      builder: (_) => TranslationFormDialog(
        // Pass BLoC context for dispatching events
        blocContext: context,
        existingEntry: entry,
        supportedLocales: _supportedLocales,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Translations')),
      body: BlocBuilder<AdminTranslationsBloc, AdminTranslationsState>(
        builder: (context, state) {
          if (state is AdminTranslationsLoading ||
              state is AdminTranslationsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminTranslationsLoaded) {
            if (state.translations.isEmpty) {
              return const Center(
                  child: Text('No translations yet. Add some!'));
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;

                  // Determine max extent based on screen width
                  double maxCrossAxisExtent;

                  if (screenWidth >= 1200) {
                    maxCrossAxisExtent = 625; // wide screens
                  } else if (screenWidth >= 800) {
                    maxCrossAxisExtent = 600; // medium screens
                  } else {
                    maxCrossAxisExtent =
                        screenWidth; // full width on small screens
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxCrossAxisExtent,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: state.translations.length,
                    itemBuilder: (context, index) {
                      final entry = state.translations[index];
                      return TranslationListItem(
                        entry: entry,
                        onEdit: () => _showTranslationForm(entry: entry),
                        onDelete: () {
                          context.read<AdminTranslationsBloc>().add(
                                DeleteAdminTranslation(entry.recordId),
                              );
                        },
                      );
                    },
                  );
                },
              ),
            );
          }
          if (state is AdminTranslationsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTranslationForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
