import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_state.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/core/di/service_locator.dart';
import '../../widgets/language/language_step_widget.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Step for selecting languages in the onboarding flow
class LanguageStep extends StatefulWidget {
  final List<String> selectedLanguages;
  final Function(List<String>) onLanguagesSelected;
  final LoggerInterface logger;

  const LanguageStep({
    super.key,
    required this.selectedLanguages,
    required this.onLanguagesSelected,
    required this.logger,
  });

  @override
  State<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends State<LanguageStep> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Initialize the bloc and load languages
        final bloc = ServiceLocator.instance<LanguageBloc>();
        // First load all available languages
        bloc.add(const LanguagesLoaded());
        // Then load user's selected languages
        bloc.add(const UserLanguagesLoaded());
        return bloc;
      },
      child: BlocConsumer<LanguageBloc, LanguageState>(
        listener: (context, state) {
          // Only update the onboarding bloc with selected languages when they change
          // This prevents sending empty arrays accidentally
          final selectedCodes = state.selectedLanguageCodes;
          if (selectedCodes.isNotEmpty) {
            // Update the onboarding bloc with selected languages
            context.read<OnboardingBloc>().add(
                  LanguagesUpdated(selectedCodes),
                );
          }

          // Only navigate when languages are saved successfully AND we're coming from the Next button
          if (state.saveSuccess && !_hasNavigated) {
            _hasNavigated = true;
            // Notify parent widget that languages are selected and saved
            widget.onLanguagesSelected(state.selectedLanguageCodes);
          }
        },
        builder: (context, state) {
          return LanguageStepWidget(
            onContinue: () {
              // Save selected languages when user taps continue
              if (state.selectedLanguageCodes.isNotEmpty) {
                // Convert selected ISO codes to language IDs
                final selectedIds = state.selectedLanguageCodes
                    .where(
                        (isoCode) => state.languageIdMap.containsKey(isoCode))
                    .map((isoCode) => state.languageIdMap[isoCode]!)
                    .toList();

                if (selectedIds.isNotEmpty) {
                  widget.logger.i(
                      'LanguageStep: Saving languages with IDs: $selectedIds');
                  // Trigger language saving in the bloc
                  context.read<LanguageBloc>().add(
                        LanguagesSaved(selectedIds),
                      );
                } else {
                  widget.logger
                      .w('LanguageStep: No valid language IDs found to save');
                }
              } else {
                widget.logger.w('LanguageStep: No languages selected to save');
              }
            },
          );
        },
      ),
    );
  }
}
