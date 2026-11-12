import 'dart:async';

import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import 'journey_menu.dart';
import 'keypad_confirmation_dialog.dart';
import 'keypad_paged_list.dart';
import 'keypad_text_step.dart';

/// Small async building blocks so each journey flow is a sequence of
/// one-question screens, each fully usable with the keypad alone.
class JourneyPrompts {
  const JourneyPrompts._();

  /// One text field. Returns null when the user goes back.
  static Future<String?> askText(
    BuildContext context, {
    required String title,
    required String label,
    String initial = '',
    int max = 1000,
    bool optional = false,
  }) async {
    final controller = TextEditingController(text: initial);
    final route = MaterialPageRoute<String>(
      builder: (routeContext) => KeypadTextStep(
        title: title,
        label: optional ? '$label. Optional, leave empty to skip' : label,
        controller: controller,
        validate: (value) {
          final text = value.trim();
          if (!optional && text.isEmpty) {
            return 'Nothing entered. Press OK on the field and type, or press 0 to go back.';
          }
          if (text.length > max) return 'Too long. Use at most $max characters.';
          return null;
        },
        onContinue: (value) async {
          final text = value.trim();
          unawaited(
            TtsService.speak(text.isEmpty ? 'Skipped.' : 'You entered: $text'),
          );
          Navigator.pop(routeContext, text);
        },
      ),
    );
    final result = await Navigator.of(context).push(route);
    await route.completed;
    controller.dispose();
    return result;
  }

  /// A five-per-page keypad list over items already in memory.
  static Future<T?> choose<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
  }) => Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (listContext) => KeypadPagedList<T>(
        title: title,
        scope: items,
        labelOf: labelOf,
        onSelected: (item) => Navigator.pop(listContext, item),
        loadPage: (query) async => memoryPage(items, labelOf, query),
      ),
    ),
  );

  static KeypadListPage<T> memoryPage<T>(
    List<T> items,
    String Function(T) labelOf,
    KeypadListQuery query,
  ) {
    final search = query.search.toLowerCase();
    final matches = search.isEmpty
        ? items
        : items.where((item) => labelOf(item).toLowerCase().contains(search)).toList();
    final start = int.tryParse(query.cursor ?? '0') ?? 0;
    final end = (start + KeypadListQuery.pageSize).clamp(0, matches.length);
    return KeypadListPage(
      items: matches.sublist(start.clamp(0, matches.length), end),
      nextCursor: end < matches.length ? '$end' : null,
    );
  }

  /// Up to five numbered answers. Returns the chosen index, or null for back.
  static Future<int?> pick(
    BuildContext context, {
    required String title,
    required List<String> choices,
    String? introduction,
  }) => Navigator.of(context).push<int>(
    MaterialPageRoute(
      builder: (menuContext) => JourneyMenu(
        title: title,
        introduction: introduction,
        choices: [
          for (var index = 0; index < choices.length; index++)
            JourneyChoice(
              choices[index],
              () => Navigator.pop(menuContext, index),
            ),
        ],
      ),
    ),
  );

  /// Key 1 cancels and key 2 confirms.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => KeypadConfirmationDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
        ),
      ) ==
      true;
}
