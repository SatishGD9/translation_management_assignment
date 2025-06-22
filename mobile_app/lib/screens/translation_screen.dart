import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/mobile_localization_bloc.dart';
import 'package:mobile_app/blocs/mobile_localization_event.dart';
import 'package:mobile_app/blocs/mobile_localization_state.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MobileLocalizationBloc>().add(const GetTranslations());
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translations'),
        actions: [
          IconButton(
              onPressed: () {
                context
                    .read<MobileLocalizationBloc>()
                    .add(const GetTranslations());
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: BlocBuilder<MobileLocalizationBloc, MobileLocalizationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          if (state.translations.isEmpty) {
            return const Center(child: Text('No translations found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              // ✅ Scroll support
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title row with translation key and actions

                  /// Translations list
                  if (state.translations.isNotEmpty)
                    SingleChildScrollView(
                      controller: scrollController,
                      child: ListView.separated(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: state.translations.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        state.translations[index].key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: state.translations[index]
                                        .translations.entries
                                        .map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                entry.key.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
