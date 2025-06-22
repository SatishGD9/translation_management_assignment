import 'dart:convert';

import 'package:admin_web_app/blocs/admin_translations_bloc.dart';
import 'package:admin_web_app/blocs/admin_translations_event.dart';
import 'package:admin_web_app/services/open_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translation_domain/translation_domain.dart';

class TranslationFormDialog extends StatefulWidget {
  final BuildContext blocContext;
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
  bool loadingAiSuggestions = false;
  @override
  void initState() {
    super.initState();
    _keyController =
        TextEditingController(text: widget.existingEntry?.key ?? '');
    _localeControllers = {
      for (var locale in widget.supportedLocales)
        locale: TextEditingController(
          text: widget.existingEntry?.translations[locale] ?? '',
        ),
    };
  }

  @override
  void dispose() {
    _keyController.dispose();
    _localeControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final key = _keyController.text.trim();
      final translations = {
        for (var entry in _localeControllers.entries)
          entry.key: entry.value.text.trim(),
      };

      final bloc = BlocProvider.of<AdminTranslationsBloc>(widget.blocContext);

      if (_isEditing) {
        TranslationEntry updatedEntry = widget.existingEntry!.copyWith(
          key: key,
          translations: translations,
        );
        bloc.add(UpdateAdminTranslation(updatedEntry));
      } else {
        bloc.add(AddAdminTranslation(key, translations));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );

    return Dialog(
      insetPadding:
          const EdgeInsets.all(32), // controls overall spacing from screen edge
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // wider dialog
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Translation' : 'Add New Translation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  loadingAiSuggestions
                      ? SizedBox(
                          height: 40,
                          width: 180,
                          child: CustomShimmer(
                            child: Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Get AI Suggestion',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            await loasSuggestionsFromAi();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text("Get AI Suggestion"),
                        )
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Key field
                    TextFormField(
                      controller: _keyController,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Translation Key',
                        hintText: 'e.g., greeting, common.ok',
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Key cannot be empty'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Translations header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Translations:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...widget.supportedLocales.map((locale) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: _localeControllers[locale],
                          decoration: inputDecoration.copyWith(
                            labelText: 'Value for "${locale.toUpperCase()}"',
                          ),
                          style: const TextStyle(fontSize: 16),
                          maxLines: 4,
                          minLines: 4,
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: Text(
                              _isEditing ? 'Save Changes' : 'Add Translation'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loasSuggestionsFromAi() async {
    try {
      loadingAiSuggestions = true;
      setState(() {});
      OpenRouter openRouter = OpenRouter();
      String result = await openRouter.fetchTranslationSuggestion(
        englishText: _localeControllers['en']!.text,
        targetLanguage: widget.supportedLocales.join(','),
      );
      final RegExp regex = RegExp(r'```json\s*([\s\S]*?)```', multiLine: true);
      final match = regex.firstMatch(result);

      if (match != null) {
        String jsonBlock = match.group(1)!.trim();

        final Map<String, dynamic> translations = jsonDecode(jsonBlock);

        _localeControllers['es']!.text = translations['es'] ?? '';
        _localeControllers['fr']!.text = translations['fr'] ?? '';
        loadingAiSuggestions = false;
        setState(() {});
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No translations found"),
              backgroundColor: Colors.red,
            ),
          );
        }
        loadingAiSuggestions = false;
        setState(() {});
      }
    } catch (e, message) {
      loadingAiSuggestions = false;
      setState(() {});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error getting AI suggestions"),
            backgroundColor: Colors.red,
          ),
        );
      }

      debugPrint(e.toString() + message.toString());
    }
  }
}

class CustomShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const CustomShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
