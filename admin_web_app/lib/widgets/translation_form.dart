import 'package:admin_web_app/blocs/admin_translations_bloc.dart';
import 'package:admin_web_app/blocs/admin_translations_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translation_domain/translation_domain.dart';

class TranslationFormDialog extends StatefulWidget {
  final BuildContext blocContext; // To access the BLoC
  final TranslationEntry? existingEntry;
  final List<String> supportedLocales;

  const TranslationFormDialog({
    super.key,
    required this.blocContext,
    this.existingEntry,
    required this.supportedLocales,
  });

  @override
  State<TranslationFormDialog> createState() => _TranslationFormDialogState();
}

class _TranslationFormDialogState extends State<TranslationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late Map<String, TextEditingController> _localeControllers;

  bool get _isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.existingEntry?.key ?? '');
    _localeControllers = {};
    for (var locale in widget.supportedLocales) {
      _localeControllers[locale] = TextEditingController(
        text: widget.existingEntry?.translations[locale] ?? '',
      );
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _localeControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final key = _keyController.text.trim();
      final translations = <String, String>{};
      _localeControllers.forEach((locale, controller) {
        translations[locale] = controller.text.trim();
      });

      final adminBloc = BlocProvider.of<AdminTranslationsBloc>(widget.blocContext);

      if (_isEditing) {
        final updatedEntry = widget.existingEntry!.copyWith(
          key: key,
          translations: translations,
        );
        adminBloc.add(UpdateAdminTranslation(updatedEntry));
      } else {
        adminBloc.add(AddAdminTranslation(key, translations));
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Translation' : 'Add New Translation'),
      content: SingleChildScrollView( // Important for smaller dialogs or many locales
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Translation Key',
                  hintText: 'e.g., greeting, common.ok',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Key cannot be empty';
                  }
                  // Add more validation if needed (e.g., no spaces, specific format)
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Translations:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...widget.supportedLocales.map((locale) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _localeControllers[locale],
                    decoration: InputDecoration(
                      labelText: 'Value for "${locale.toUpperCase()}"',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      // Optionally, make some locales mandatory
                      // if (locale == 'en' && (value == null || value.trim().isEmpty)) {
                      //   return 'English translation cannot be empty';
                      // }
                      return null;
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text(_isEditing ? 'Save Changes' : 'Add Translation'),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}