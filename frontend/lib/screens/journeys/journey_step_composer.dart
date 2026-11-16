import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/message_center.dart';
import '../../services/feedback_cues.dart';
import '../../services/api_service.dart';
import '../../announcers/journey_text.dart';
import '../../services/journey_api.dart';
import '../../services/journey_models.dart';
import '../../services/tts_service.dart';
import '../../widgets/journey_prompts.dart';
import '../private_notes_screen.dart';

/// Guided, one-field-per-screen flows that build a single journey step.
/// Back (0) on a screen returns to the previous screen of the flow with what
/// was entered kept; every flow returns null if the teacher goes back from
/// its first screen (or after [takeExplained] reports why nothing was made).
class JourneyStepComposer {
  static bool _explained = false;

  /// True once, after a composer step already said why nothing was made, so
  /// the caller does not talk over it with a second message.
  static bool takeExplained() {
    final explained = _explained;
    _explained = false;
    return explained;
  }

  static void _explain(String message, {bool error = false}) {
    _explained = true;
    error ? MessageCenter.error(message) : MessageCenter.show(message);
  }

  const JourneyStepComposer._();

  static Future<JourneyStep?> narration(
    BuildContext context, {
    JourneyStep? initial,
  }) async {
    final text = await JourneyPrompts.askText(
      context,
      title: Speech.t.journeyKindNarration,
      label: Speech.t.journeyNarrationLabel,
      initial: initial?.text ?? '',
      max: 2000,
    );
    if (text == null) return null;
    return JourneyStep(kind: JourneyStepKind.narration, text: text);
  }

  /// Runs one-question [screens] in order. Each returns true to go on, false
  /// when the teacher pressed back (the previous screen opens again with what
  /// was entered kept), or null when it asked nothing (keep the direction).
  /// Back on the first screen leaves. True once every screen is done.
  static Future<bool> _screens(
    BuildContext context,
    List<Future<bool?> Function()> screens,
  ) async {
    var index = 0;
    var forward = true;
    while (index >= 0 && index < screens.length) {
      if (!context.mounted) return false;
      forward = await screens[index]() ?? forward;
      index += forward ? 1 : -1;
    }
    return index == screens.length;
  }

  /// Two to four options. Back on an option returns to the one before it
  /// (or to "Add option?"), keeping every text typed. Null when the teacher
  /// goes back from option 1.
  static Future<List<String>?> _options(
    BuildContext context, {
    required bool poll,
    List<String> initial = const [],
  }) async {
    final t = Speech.t;
    final texts = [...initial.take(4)];
    var number = 1;
    var askMore = false;
    while (context.mounted) {
      if (number > 4) return texts.take(4).toList();
      if (askMore) {
        final more = await JourneyPrompts.pick(
          context,
          title: t.journeyAddOptionTitle('$number'),
          introduction: poll
              ? t.journeyPollOptionsSoFar('${number - 1}')
              : t.journeyQuestionOptionsSoFar('${number - 1}'),
          choices: [t.journeyAddOption('$number'), t.journeyNoMoreOptions],
        );
        if (!context.mounted) return null;
        askMore = false;
        if (more == null) {
          number--;
          continue;
        }
        if (more == 1) return texts.take(number - 1).toList();
      }
      final text = await JourneyPrompts.askText(
        context,
        title: t.journeyOptionTitle('$number'),
        label: t.journeyTypeOption('$number'),
        initial: number <= texts.length ? texts[number - 1] : '',
        max: 300,
      );
      if (!context.mounted) return null;
      if (text == null) {
        if (number == 1) return null;
        if (number > 2) {
          askMore = true;
        } else {
          number--;
        }
        continue;
      }
      final earlier = texts.take(number - 1);
      if (earlier.any((o) => o.toLowerCase() == text.toLowerCase())) {
        _explain(JourneyAnnouncer.optionUsed, error: true);
        continue;
      }
      if (number <= texts.length) {
        texts[number - 1] = text;
      } else {
        texts.add(text);
      }
      number++;
      askMore = number > 2 && number <= 4;
    }
    return null;
  }

  /// (answered, replayFrom). answered is null when there was nothing to ask,
  /// false for back. replayFrom null means automatic.
  static Future<(bool?, int?)> _replay(
    BuildContext context, {
    required List<JourneyStep> steps,
    required int position,
  }) async {
    final content = [
      for (var i = 0; i < position; i++)
        if (steps[i].isContent) i,
    ];
    if (content.isEmpty) {
      // Shown, not spoken: the next screen opens at once and would cut it off.
      MessageCenter.show(JourneyAnnouncer.nothingToReplay, speak: false);
      return (null, null);
    }
    final t = Speech.t;
    final auto = JourneySteps.autoReplay(steps, position);
    final autoText = auto == null
        ? t.journeyReplayAutoNone
        : t.journeyReplayAutoFrom('${auto + 1}', steps[auto].spokenName);
    while (true) {
      if (!context.mounted) return (false, null);
      final choice = await JourneyPrompts.pick(
        context,
        title: t.journeyAfterWrongTitle,
        introduction: t.journeyAfterWrongIntro,
        choices: [autoText, t.journeyReplayChooseStep],
      );
      if (choice == null) return (false, null);
      if (choice == 0) return (true, null);
      if (!context.mounted) return (false, null);
      final picked = await JourneyPrompts.choose<int>(
        context,
        title: t.journeyReplayWhichStep,
        items: content,
        labelOf: (index) =>
            t.journeyStepLabel('${index + 1}', steps[index].spokenName),
      );
      // Back from the list returns to the automatic or choose question.
      if (picked != null) return (true, picked);
    }
  }

  /// "Check before saving". back is true when the teacher pressed back, to
  /// return to the previous question; otherwise step is the saved step, or
  /// null if a restarted step was abandoned.
  static Future<({bool back, JourneyStep? step})> _review(
    BuildContext context,
    JourneyStep step, {
    required List<JourneyStep> steps,
    required int position,
  }) async {
    final t = Speech.t;
    final replay = step.kind != JourneyStepKind.question
        ? null
        : step.replayFrom != null
        ? t.journeyReviewReplayFrom('${step.replayFrom! + 1}')
        : t.journeyReviewReplayAuto;
    final choice = await JourneyPrompts.pick(
      context,
      title: t.journeyCheckBeforeSaving,
      introduction: [
        JourneyAnnouncer.stepDetails(step),
        ?replay,
      ].join(' '),
      choices: [t.journeySaveStep, t.journeyRestartStep],
    );
    if (choice == null) return (back: true, step: null);
    if (choice == 0) return (back: false, step: step);
    if (!context.mounted) return (back: false, step: null);
    if (step.kind == JourneyStepKind.poll) {
      return (back: false, step: await poll(context, initial: step));
    }
    return (
      back: false,
      step: await question(
        context,
        steps: steps,
        position: position,
        initial: step,
      ),
    );
  }

  static Future<JourneyStep?> question(
    BuildContext context, {
    required List<JourneyStep> steps,
    required int position,
    JourneyStep? initial,
  }) async {
    var text = initial?.text ?? '';
    var options = initial?.options ?? const <String>[];
    var correct = initial?.correctIndex;
    var explanation = initial?.explanation ?? '';
    var replay = initial?.replayFrom;
    JourneyStep? saved;
    JourneyStep draft() => JourneyStep(
      kind: JourneyStepKind.question,
      text: text,
      options: options,
      correctIndex: correct,
      explanation: explanation.isEmpty ? null : explanation,
      replayFrom: replay,
      sourceQuestionId: initial?.sourceQuestionId,
    );
    final done = await _screens(context, [
      () async {
        final value = await JourneyPrompts.askText(
          context,
          title: Speech.t.journeyKindQuestion,
          label: Speech.t.journeyQuestionLabel,
          initial: text,
        );
        if (value == null) return false;
        text = value;
        return true;
      },
      () async {
        final value = await _options(
          context,
          poll: false,
          initial: options,
        );
        if (value == null) return false;
        options = value;
        if (correct != null && correct! >= options.length) correct = null;
        return true;
      },
      () async {
        final value = await JourneyPrompts.pick(
          context,
          title: Speech.t.journeyWhichCorrect,
          introduction: correct == null
              ? null
              : Speech.t.journeyCurrentlyCorrect('${correct! + 1}'),
          choices: [
            for (var i = 0; i < options.length; i++)
              Speech.t.journeyOptionChoice('${i + 1}', options[i]),
          ],
        );
        if (value == null) return false;
        correct = value;
        return true;
      },
      () async {
        final value = await JourneyPrompts.askText(
          context,
          title: Speech.t.journeyExplanationTitle,
          label: Speech.t.journeyExplanationLabel,
          initial: explanation,
          optional: true,
        );
        if (value == null) return false;
        explanation = value;
        return true;
      },
      () async {
        final (answered, from) = await _replay(
          context,
          steps: steps,
          position: position,
        );
        if (answered != false) replay = from;
        return answered;
      },
      () async {
        final result = await _review(
          context,
          draft(),
          steps: steps,
          position: position,
        );
        if (result.back) return false;
        saved = result.step;
        return true;
      },
    ]);
    return done ? saved : null;
  }

  static Future<JourneyStep?> poll(
    BuildContext context, {
    JourneyStep? initial,
  }) async {
    var text = initial?.text ?? '';
    var options = initial?.options ?? const <String>[];
    JourneyStep? saved;
    final done = await _screens(context, [
      () async {
        final value = await JourneyPrompts.askText(
          context,
          title: Speech.t.journeyPollQuestionTitle,
          label: Speech.t.journeyPollQuestionLabel,
          initial: text,
        );
        if (value == null) return false;
        text = value;
        return true;
      },
      () async {
        final value = await _options(context, poll: true, initial: options);
        if (value == null) return false;
        options = value;
        return true;
      },
      () async {
        final result = await _review(
          context,
          JourneyStep(kind: JourneyStepKind.poll, text: text, options: options),
          steps: const [],
          position: 0,
        );
        if (result.back) return false;
        saved = result.step;
        return true;
      },
    ]);
    return done ? saved : null;
  }

  static Future<JourneyStep?> fromBank(
    BuildContext context, {
    required JourneyApi api,
    required int classId,
    required int subjectId,
    required List<JourneyStep> steps,
    required int position,
  }) async {
    final List<JourneyStep> bank;
    try {
      bank = await api.bankQuestions(classId, subjectId);
    } on JourneyApiException catch (error) {
      _explain(error.message, error: true);
      return null;
    }
    if (bank.isEmpty) {
      _explain(JourneyAnnouncer.bankEmpty);
      return null;
    }
    if (!context.mounted) return null;
    JourneyStep? chosen;
    int? replay;
    JourneyStep? saved;
    final done = await _screens(context, [
      () async {
        final value = await JourneyPrompts.choose<JourneyStep>(
          context,
          title: Speech.t.journeyQuestionBank,
          items: bank,
          labelOf: (step) => Speech.t.journeyBankQuestionLabel(
            step.text,
            '${step.options.length}',
          ),
        );
        if (value == null) return false;
        chosen = value;
        return true;
      },
      () async {
        final (answered, from) = await _replay(
          context,
          steps: steps,
          position: position,
        );
        if (answered != false) replay = from;
        return answered;
      },
      () async {
        final result = await _review(
          context,
          replay == null ? chosen! : chosen!.copyWith(replayFrom: replay),
          steps: steps,
          position: position,
        );
        if (result.back) return false;
        saved = result.step;
        return true;
      },
    ]);
    return done ? saved : null;
  }

  /// Back from any later screen returns to "Add a recording".
  static Future<JourneyStep?> recording(
    BuildContext context, {
    required JourneyApi api,
    required int classId,
    required int subjectId,
  }) async {
    while (true) {
      if (!context.mounted) return null;
      final choice = await JourneyPrompts.pick(
        context,
        title: Speech.t.journeyAddRecording,
        choices: [
          Speech.t.journeyChooseMyRecordings,
          Speech.t.journeyUploadRecordingFile,
          Speech.t.journeyRecordNew,
        ],
      );
      if (choice == null || !context.mounted) return null;
      if (choice == 1) {
        final upload = await _upload(
          context,
          classId: classId,
          subjectId: subjectId,
        );
        if (upload.back) continue;
        return upload.step;
      }
      if (choice == 2) {
        unawaited(TtsService.speak(JourneyAnnouncer.recordViaNotes));
        await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => const PrivateNotesScreen()),
        );
        if (!context.mounted) return null;
      }
      final List<({int id, String title})> recordings;
      try {
        recordings = await api.recordings(classId, subjectId);
      } on JourneyApiException catch (error) {
        _explain(error.message, error: true);
        return null;
      }
      if (recordings.isEmpty) {
        _explain(JourneyAnnouncer.noRecordings);
        return null;
      }
      if (!context.mounted) return null;
      final picked = await JourneyPrompts.choose<({int id, String title})>(
        context,
        title: Speech.t.journeyMyRecordings,
        items: recordings,
        labelOf: (recording) => recording.title,
      );
      if (picked == null) continue;
      return JourneyStep(
        kind: JourneyStepKind.audio,
        audioId: picked.id,
        title: picked.title,
      );
    }
  }

  /// back is true when no file was chosen or the name was left with back.
  static Future<({bool back, JourneyStep? step})> _upload(
    BuildContext context, {
    required int classId,
    required int subjectId,
  }) async {
    unawaited(TtsService.speak(JourneyAnnouncer.openingFiles));
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
      withData: kIsWeb,
    );
    if (picked == null || picked.files.isEmpty || !context.mounted) {
      // "Add a recording" opens again and says why first.
      MessageCenter.carryToNextScreen(JourneyAnnouncer.noFile);
      return (back: true, step: null);
    }
    final file = picked.files.first;
    final title = await JourneyPrompts.askText(
      context,
      title: Speech.t.journeyRecordingName,
      label: Speech.t.journeyRecordingNameLabel,
      initial: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
      max: 160,
    );
    if (title == null) return (back: true, step: null);
    unawaited(FeedbackCues.play(Cue.loading));
    unawaited(TtsService.speak(JourneyAnnouncer.uploading));
    final result = kIsWeb || file.path == null
        ? (file.bytes == null
              ? null
              : await ApiService.uploadAudioBytes(
                  fileBytes: file.bytes!,
                  filename: file.name,
                  title: title,
                  classId: classId,
                  subjectId: subjectId,
                ))
        : await ApiService.uploadAudio(
            filePath: file.path!,
            title: title,
            classId: classId,
            subjectId: subjectId,
          );
    final audio = result?['audio'];
    if (audio is! Map || audio['audio_id'] is! int) {
      _explain(JourneyAnnouncer.uploadUnconfirmed, error: true);
      return (back: false, step: null);
    }
    MessageCenter.success(JourneyAnnouncer.uploaded(title));
    return (
      back: false,
      step: JourneyStep(
        kind: JourneyStepKind.audio,
        audioId: audio['audio_id'] as int,
        title: title,
      ),
    );
  }
}
