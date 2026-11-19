import 'package:flutter/material.dart';

import '../l10n/speech.dart';
import '../widgets/journey_menu.dart';

/// Things used now and then, kept off the home screen (S33).
class HomeMoreMenu extends StatelessWidget {
  const HomeMoreMenu({super.key, required this.choices});

  final List<JourneyChoice> choices;

  @override
  Widget build(BuildContext context) => JourneyMenu(
    title: Speech.t.homeMore,
    brief: Speech.t.homeMoreBrief,
    choices: choices,
  );
}
