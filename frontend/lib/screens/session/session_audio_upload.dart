// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../announcers/session_text.dart';
import '../../services/api_service.dart';
import '../../services/message_center.dart';
import '../../services/tts_service.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/key_instruction_wrapper.dart';

/// Teacher upload of a new class recording from inside a live class:
/// pick a file, enter its title, choose the classes, then upload.
class SessionAudioUpload {
  SessionAudioUpload({
    required this.context,
    required this.sessionId,
    required this.teacherSessions,
    required this.isActive,
    required this.setUploading,
    required this.reload,
    required TextEditingController title,
    required TextEditingController description,
  }) : _title = title,
       _description = description;

  final BuildContext context;
  final int sessionId;
  final List<Map<String, dynamic>> teacherSessions;
  final bool Function() isActive;
  final void Function(bool uploading) setUploading;
  final Future<void> Function() reload;

  final TextEditingController _title;
  final TextEditingController _description;

  void _speak(String text) {
    if (TtsService.isEnabled && isActive()) TtsService.speak(text);
  }

  Future<void> run() async {
    try {
      await TtsService.stop();
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (picked == null || picked.files.isEmpty || !isActive()) return;
      final file = picked.files.first;
      _title.clear();
      _description.clear();

      final confirmed = await _metadataDialog(file.name);
      if (confirmed != true) return;

      final title = _title.text.trim();
      if (title.isEmpty) {
        MessageCenter.error(SessionText.titleRequired);
        return;
      }
      if (isActive()) setUploading(true);

      final selected = <int>{sessionId};
      if (teacherSessions.isNotEmpty && isActive()) {
        final confirmedSessions = await _sessionsDialog(selected);
        if (confirmedSessions != true || selected.isEmpty) return;
      }

      final sessionState = await ApiService.getSessionState(sessionId);
      final classId = sessionState?['class_id'] as int?;
      final subjectId = sessionState?['subject_id'] as int?;
      if (classId == null || subjectId == null) {
        MessageCenter.error(SessionText.uploadContextMissing);
        return;
      }
      final uri = Uri.parse('${dotenv.env['API_BASE_URL']}/audio/upload');
      final headers = await ApiService.getHeaders();
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields['title'] = title
        ..fields['description'] = _description.text.trim()
        ..fields['session_ids'] = jsonEncode(selected.toList())
        ..fields['class_id'] = classId.toString()
        ..fields['subject_id'] = subjectId.toString();

      final ext = file.extension?.toLowerCase() ?? '';
      final contentType =
          const {
            'mp3': 'audio/mpeg',
            'wav': 'audio/wav',
            'm4a': 'audio/x-m4a',
            'mp4': 'audio/mp4',
            'ogg': 'audio/ogg',
            'webm': 'audio/webm',
          }[ext] ??
          'audio/mpeg';

      if (kIsWeb && file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else if (!kIsWeb && file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: file.name,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        MessageCenter.success(SessionText.uploadSuccess);
        await reload();
      } else {
        MessageCenter.error(
          ApiService.mapFailure(
            statusCode: response.statusCode,
            responseBody: responseBody,
            context: 'audio upload',
          ).message,
        );
      }
    } catch (e) {
      print('[AUDIO UPLOAD ERROR] $e');
      MessageCenter.error(
        ApiService.mapFailure(error: e, context: 'audio upload').message,
      );
    } finally {
      if (isActive()) setUploading(false);
    }
  }

  Future<bool?> _metadataDialog(String fileName) async {
    final titleNode = FocusNode(debugLabel: 'upload-audio-title');
    final descriptionNode = FocusNode(debugLabel: 'upload-audio-description');
    final cancelNode = FocusNode(debugLabel: 'upload-audio-cancel');
    final uploadNode = FocusNode(debugLabel: 'upload-audio-confirm');
    final controller = KeypadNavigationController();

    void submit(BuildContext dialogContext) {
      if (_title.text.trim().isEmpty) {
        _speak(SessionText.titleRequired);
        titleNode.requestFocus();
        controller.enterTextEditing(titleNode);
        return;
      }
      Navigator.pop(dialogContext, true);
    }

    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => KeypadInstructionWrapper(
          screenName: SessionText.uploadDetailsTitle,
          labels: const {
            1: 'Edit Title',
            2: 'Edit Description',
            3: 'Upload',
            0: 'Cancel',
          },
          actions: {
            1: () => controller.enterTextEditing(titleNode),
            2: () => controller.enterTextEditing(descriptionNode),
            3: () => submit(dialogContext),
            0: () => Navigator.pop(dialogContext, false),
          },
          navigationController: controller,
          focusTargets: [
            KeypadFocusTarget(
              node: titleNode,
              label: SessionText.titleField,
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: descriptionNode,
              label: SessionText.descriptionField,
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: cancelNode,
              label: SessionText.cancelUpload,
              onActivate: () => Navigator.pop(dialogContext, false),
            ),
            KeypadFocusTarget(
              node: uploadNode,
              label: SessionText.confirmUpload,
              onActivate: () => submit(dialogContext),
            ),
          ],
          child: AlertDialog(
            title: const Text(SessionText.uploadTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    SessionText.uploadFile(fileName),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _title,
                    focusNode: titleNode,
                    onTap: () => controller.enterTextEditing(titleNode),
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _description,
                    focusNode: descriptionNode,
                    onTap: () => controller.enterTextEditing(descriptionNode),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      controller.exitTextEditing();
                      cancelNode.requestFocus();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                focusNode: cancelNode,
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel (0)'),
              ),
              ElevatedButton(
                focusNode: uploadNode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIUtils.primaryColor,
                  foregroundColor: UIUtils.onPrimaryColor,
                ),
                onPressed: () => submit(dialogContext),
                child: const Text('Upload (3)'),
              ),
            ],
          ),
        ),
      );
    } finally {
      titleNode.dispose();
      descriptionNode.dispose();
      cancelNode.dispose();
      uploadNode.dispose();
    }
  }

  Future<bool?> _sessionsDialog(Set<int> selected) async {
    final cancelNode = FocusNode(debugLabel: 'audio-sessions-cancel');
    final confirmNode = FocusNode(debugLabel: 'audio-sessions-confirm');
    final sessionNodes = <int, FocusNode>{
      for (final session in teacherSessions)
        session['session_id'] as int: FocusNode(
          debugLabel: 'audio-session-${session['session_id']}',
        ),
    };
    StateSetter? updateDialog;

    void toggle(int id) {
      if (!selected.remove(id)) selected.add(id);
      updateDialog?.call(() {});
      _speak(
        selected.contains(id)
            ? SessionText.sessionSelected
            : SessionText.sessionUnselected,
      );
    }

    void confirm(BuildContext dialogContext) {
      if (selected.isEmpty) {
        _speak(SessionText.selectAtLeastOne);
        return;
      }
      Navigator.pop(dialogContext, true);
    }

    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setLocalState) {
            updateDialog = setLocalState;
            return KeypadInstructionWrapper(
              screenName: SessionText.chooseSessionsTitle,
              labels: const {0: 'Cancel', 1: SessionText.confirmSessions},
              actions: {
                0: () => Navigator.pop(dialogContext, false),
                1: () => confirm(dialogContext),
              },
              focusTargets: [
                for (final session in teacherSessions)
                  KeypadFocusTarget(
                    node: sessionNodes[session['session_id'] as int]!,
                    label: SessionText.sessionChoice(
                      SessionText.sessionTitle(session),
                      selected.contains(session['session_id']),
                    ),
                    onActivate: () => toggle(session['session_id'] as int),
                  ),
                KeypadFocusTarget(
                  node: cancelNode,
                  label: SessionText.cancelUpload,
                  onActivate: () => Navigator.pop(dialogContext, false),
                ),
                KeypadFocusTarget(
                  node: confirmNode,
                  label: SessionText.confirmSessions,
                  onActivate: () => confirm(dialogContext),
                ),
              ],
              child: AlertDialog(
                title: const Text(SessionText.addToSessions),
                content: SizedBox(
                  width: 360,
                  child: ListView(
                    shrinkWrap: true,
                    children: teacherSessions.map((session) {
                      final id = session['session_id'] as int;
                      return Focus(
                        focusNode: sessionNodes[id],
                        child: ExcludeFocus(
                          child: CheckboxListTile(
                            value: selected.contains(id),
                            title: Text(SessionText.sessionTitle(session)),
                            subtitle: Text('Session #$id'),
                            onChanged: (_) => toggle(id),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    focusNode: cancelNode,
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel (0)'),
                  ),
                  ElevatedButton(
                    focusNode: confirmNode,
                    onPressed: () => confirm(dialogContext),
                    child: const Text('Confirm (1)'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } finally {
      cancelNode.dispose();
      confirmNode.dispose();
      for (final node in sessionNodes.values) {
        node.dispose();
      }
    }
  }
}
