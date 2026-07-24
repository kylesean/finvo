// features/chat/widgets/welcome/welcome_guide_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/welcome_guide_provider.dart';
import 'greeting_header.dart';
import 'suggestion_card.dart';

/// Welcome guide component
/// Displayed when chat page has no messages, provides contextual suggestions based on time of day
class WelcomeGuideWidget extends ConsumerWidget {
  /// Callback when user taps a suggestion card
  /// Parameter is the suggested prompt, used to send to AI
  final void Function(String prompt) onSuggestionTap;

  const WelcomeGuideWidget({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideState = ref.watch(welcomeGuideProvider);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          // Limit max width, keep centered and compact on large screens
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Greeting header
              GreetingHeader(
                greeting: guideState.greeting,
                subtitle: guideState.subtitle,
              ),
              const SizedBox(height: 28),
              // Contextual suggestion cards - using Column + gap
              ...guideState.suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < guideState.suggestions.length - 1 ? 10 : 0,
                  ),
                  child: SuggestionCard(
                    icon: suggestion.icon,
                    title: suggestion.title,
                    prompt: suggestion.prompt,
                    description: suggestion.description,
                    onTap: () => onSuggestionTap(suggestion.prompt),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
