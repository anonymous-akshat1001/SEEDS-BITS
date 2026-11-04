import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/ui_utils.dart';
// Allows user to pick audio files
import 'package:file_picker/file_picker.dart';
// Audio playback library
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Used for multipart file upload
import 'package:http/http.dart' as http;
// Helps define MIME types and tells backend which type(mp3, etc) audio file it is
import 'package:http_parser/http_parser.dart';
// JSON encode/decode
import 'dart:convert';
import 'dart:async';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/learning_playback_controller.dart';
import '../services/learning_progress_store.dart';
import '../services/offline_lesson_store.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/accessible_tile.dart';
import '../widgets/key_instruction_wrapper.dart';
import '../widgets/keypad_confirmation_dialog.dart';
import '../widgets/learning_controls.dart';
import '../utils/keypad_actions.dart';
import 'playlist_screens.dart';
import 'downloads_screen.dart';
import 'private_notes_screen.dart';

// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];

// Widget definition which allows the screen to change with time
class AudioLibraryScreen extends StatefulWidget {
  final int?
  sessionId; // Optional - if provided, allows selecting audio for session
  final int? classId;
  final int? subjectId;

  // Constructor
  const AudioLibraryScreen({
    super.key,
    this.sessionId,
    this.classId,
    this.subjectId,
  });

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}

// State Class where the logic lives
class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  // Handles audio playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, FocusNode> _focusNodes = {};

  FocusNode _focusNode(String name) => _focusNodes.putIfAbsent(
    name,
    () => FocusNode(debugLabel: 'audio-library-$name'),
  );

  List<KeypadFocusTarget> get _focusTargets => [
    KeypadFocusTarget(
      node: _focusNode('back'),
      label: 'Back',
      onActivate: () => Navigator.of(context).maybePop(),
    ),
    KeypadFocusTarget(
      node: _focusNode('refresh'),
      label: 'Refresh audio files, key 1',
      onActivate: _loadAudioFiles,
    ),
    if (widget.sessionId != null)
      KeypadFocusTarget(
        node: _focusNode('pause-session'),
        label: 'Pause audio for the whole session, key 4',
        onActivate: _pauseSessionAudio,
      ),
    KeypadFocusTarget(
      node: _focusNode('upload'),
      label: 'Upload audio, key 2',
      onActivate: _uploadAudioFile,
      isEnabled: () => !_isUploading,
    ),
    for (var index = 0; index < _audioFiles.length; index++) ...[
      KeypadFocusTarget(
        node: _focusNode(
          'preview-${_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']}',
        ),
        label:
            '${_playingAudioId == (_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']) ? 'Stop preview of' : 'Preview'} '
            '${_audioFiles[index]['title']} privately. Only you can hear this. '
            '${_audioFiles[index]['description'] ?? ''}',
        onActivate: () => _playAudioLocally(
          (_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']) as int,
          '${_audioFiles[index]['title']}',
        ),
      ),
      if (widget.sessionId != null)
        KeypadFocusTarget(
          node: _focusNode(
            'broadcast-${_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']}',
          ),
          label:
              'Play ${_audioFiles[index]['title']} for everyone in the session',
          onActivate: () => _selectForSession(
            (_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']) as int,
            '${_audioFiles[index]['title']}',
          ),
        ),
    ],
  ];

  // Stores audio file metadata from backend
  List<Map<String, dynamic>> _audioFiles = [];

  // fetching audio list
  bool _isLoading = true;
  // uploading audio file
  bool _isUploading = false;
  // tracks which audio file is playing
  int? _playingAudioId;
  // Currently selected for session playback
  int? _selectedAudioId;
  // Visible copy of the latest spoken status or error
  String? _statusMessage;
  bool _statusIsError = false;
  bool _loadedOnce = false;

  // Controllers for upload dialog input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _announce(String message, {bool error = false, SpeechPriority? priority}) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _statusIsError = error;
    });
    TtsService.speak(
      message,
      priority:
          priority ??
          (error ? SpeechPriority.critical : SpeechPriority.requested),
    );
  }

  // Called once when the screen is created
  @override
  void initState() {
    super.initState();
    // fetch audio files from backend
    _loadAudioFiles();
    // attach listerners to audio player
    _setupAudioPlayer();
    TtsService.registerRecordedPlayback(
      _audioPlayer,
      isPlaying: () => mounted && _playingAudioId != null,
      canResume: () => mounted && (ModalRoute.of(context)?.isCurrent ?? true),
      onResumeSkipped: () {
        if (mounted) setState(() => _playingAudioId = null);
      },
      item: () => _audioPlayer.source,
      pause: _audioPlayer.pause,
      resume: _audioPlayer.resume,
    );
  }

  // Tells who are the listeners to the audio playing currently
  void _setupAudioPlayer() {
    // Triggered when audio finishes playing
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }

      // Clear playing state
      setState(() => _playingAudioId = null);

      _speakIfEnabled("Preview finished");
    });

    // Triggered when player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }

      // Detect stop and reset UI state
      if (state == PlayerState.stopped) {
        setState(() => _playingAudioId = null);
      }
    });
  }

  // Function to load audio files from the backend(aysnc because network request)
  Future<void> _loadAudioFiles() async {
    // Prevents calling setState after widget is destroyed
    if (!mounted) {
      return;
    }

    // show loading spinner
    setState(() => _isLoading = true);

    try {
      // fetch audio list from backend
      final path = widget.sessionId != null
          ? '/audio/session/${widget.sessionId}'
          : '/audio/list';
      final result = await ApiService.get(path, useAuth: true);

      if (result != null) {
        if (!mounted) {
          return;
        }

        setState(() {
          // backend may return a direct list or list wrapped { files: [...] }
          if (result is List) {
            _audioFiles = result.cast<Map<String, dynamic>>();
          } else if (result is Map && result.containsKey('files')) {
            _audioFiles = (result['files'] as List)
                .cast<Map<String, dynamic>>();
          }
        });

        _announce(
          _audioFiles.isEmpty
              ? 'No recordings yet. Press 2 to upload audio.'
              : '${_audioFiles.length} recordings loaded.',
          priority: _loadedOnce ? null : SpeechPriority.incidental,
        );
        _loadedOnce = true;
      } else {
        _announce(
          'Could not load recordings. Check your internet connection, then press 1 to retry.',
          error: true,
        );
      }
    } catch (e) {
      print('[AUDIO LIBRARY] Error loading files: $e');
      _showError(
        'Could not load recordings. Check your internet connection, then press 1 to retry.',
      );
    } finally {
      if (!mounted) {
        return;
      }
      // Hide loading indicator
      setState(() => _isLoading = false);
    }
  }

  // Function to upload audio files - only by teacher
  Future<void> _uploadAudioFile() async {
    if (_isUploading) return;
    try {
      await TtsService.stop();
      // Opens system file picker - restricted to only audio files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      // Extract selected file
      final file = result.files.first;

      final titleNode = FocusNode(debugLabel: 'library-upload-title');
      final descriptionNode = FocusNode(
        debugLabel: 'library-upload-description',
      );
      final cancelNode = FocusNode(debugLabel: 'library-upload-cancel');
      final uploadNode = FocusNode(debugLabel: 'library-upload-confirm');
      final keypadController = KeypadNavigationController();

      void submit(BuildContext dialogContext) {
        if (_titleController.text.trim().isEmpty) {
          _showError('Title is required');
          keypadController.enterTextEditing(titleNode);
          return;
        }
        final title = _titleController.text;
        final description = _descriptionController.text;
        Navigator.pop(dialogContext);
        _performUpload(file, title, description);
      }

      // Show upload dialog
      await showDialog(
        context: context,
        builder: (dialogContext) => KeypadInstructionWrapper(
          screenName: 'Upload audio',
          labels: const {
            1: 'Edit Title',
            2: 'Edit Description',
            3: 'Upload',
            0: 'Cancel',
          },
          actions: {
            1: () => keypadController.enterTextEditing(titleNode),
            2: () => keypadController.enterTextEditing(descriptionNode),
            3: () => submit(dialogContext),
            0: () => Navigator.pop(dialogContext),
          },
          navigationController: keypadController,
          focusTargets: [
            KeypadFocusTarget(
              node: titleNode,
              label: 'Audio title, required',
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: descriptionNode,
              label: 'Audio description, optional',
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: cancelNode,
              label: 'Cancel upload',
              onActivate: () => Navigator.pop(dialogContext),
            ),
            KeypadFocusTarget(
              node: uploadNode,
              label: 'Upload audio',
              onActivate: () => submit(dialogContext),
            ),
          ],
          child: AlertDialog(
            // Asks user for title and description
            title: const Text('Upload Audio'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('File: ${file.name}'),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _titleController,
                    focusNode: titleNode,
                    onTap: () => keypadController.enterTextEditing(titleNode),
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      labelStyle: TextStyle(color: UIUtils.subtextColor),
                      filled: true,
                      fillColor: UIUtils.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: UIUtils.paddingSymmetric(
                        context,
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _descriptionController,
                    focusNode: descriptionNode,
                    onTap: () =>
                        keypadController.enterTextEditing(descriptionNode),
                    style: TextStyle(
                      fontSize: UIUtils.fontSize(context, 14),
                      color: UIUtils.textColor,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: UIUtils.subtextColor),
                      filled: true,
                      fillColor: UIUtils.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: UIUtils.paddingSymmetric(
                        context,
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      keypadController.exitTextEditing();
                      cancelNode.requestFocus();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                focusNode: cancelNode,
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel (0)',
                  style: TextStyle(color: UIUtils.subtextColor),
                ),
              ),
              ElevatedButton(
                focusNode: uploadNode,
                onPressed: () => submit(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIUtils.primaryColor,
                  foregroundColor: UIUtils.onPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('Upload (3)'),
              ),
            ],
          ),
        ),
      );
      titleNode.dispose();
      descriptionNode.dispose();
      cancelNode.dispose();
      uploadNode.dispose();
    } catch (e) {
      print('[UPLOAD] Error: $e');
      _showError("Failed to pick file");
    }
  }

  // Actual upload happens separately
  Future<void> _performUpload(
    PlatformFile file,
    String title,
    String description,
  ) async {
    if (title.trim().isEmpty) {
      _showError("Title is required");
      return;
    }

    int? classId = widget.classId;
    int? subjectId = widget.subjectId;
    if (widget.sessionId != null && (classId == null || subjectId == null)) {
      final state = await ApiService.get(
        '/sessions/${widget.sessionId}/state',
        useAuth: true,
      );
      if (state is Map) {
        classId = int.tryParse('${state['class_id']}');
        subjectId = int.tryParse('${state['subject_id']}');
      }
    }
    if (classId == null || subjectId == null) {
      final context = await ApiService.getAccessContext();
      final workspaces = context?['workspaces'];
      if (workspaces is List && workspaces.length == 1) {
        classId = int.tryParse('${workspaces.first['class_id']}');
        subjectId = int.tryParse('${workspaces.first['subject_id']}');
      }
    }
    if (classId == null || subjectId == null) {
      _showError(
        'Choose a class and subject workspace on the Teacher Dashboard before uploading audio.',
      );
      return;
    }

    setState(() => _isUploading = true);
    _announce('Uploading $title. You will hear progress every 25 percent.');

    try {
      final headers = await ApiService.getHeaders();
      final uri = Uri.parse('$baseUrl/audio/upload');

      // Multipart request support files and form fields
      var request = http.MultipartRequest('POST', uri);
      // Adds metadata fields
      request.headers.addAll(headers);
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['class_id'] = classId.toString();
      request.fields['subject_id'] = subjectId.toString();
      if (widget.sessionId != null) {
        request.fields['session_ids'] = jsonEncode([widget.sessionId]);
      }

      // Determine MIME type from file extension
      String contentType = 'audio/mpeg'; // Default
      final extension = file.extension?.toLowerCase() ?? '';

      switch (extension) {
        case 'mp3':
          contentType = 'audio/mpeg';
          break;
        case 'wav':
          contentType = 'audio/wav';
          break;
        case 'm4a':
          contentType = 'audio/x-m4a';
          break;
        case 'mp4':
          contentType = 'audio/mp4';
          break;
        case 'ogg':
          contentType = 'audio/ogg';
          break;
        case 'webm':
          contentType = 'audio/webm';
          break;
        default:
      }

      print('[UPLOAD] File: ${file.name}');
      print('[UPLOAD] Extension: $extension');
      print('[UPLOAD] Content-Type: $contentType');

      // Handle file based on platform
      if (kIsWeb) {
        // Web uses bytes (no file path)
        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
              // Determine correct file type for backend
              contentType: MediaType.parse(contentType),
            ),
          );
        }
      } else {
        // Mobile uses filesystem path
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              file.path!,
              filename: file.name,
              contentType: MediaType.parse(contentType),
            ),
          );
        }
      }

      final response = await _sendWithProgress(request, title);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _announce('$title uploaded.');
        _titleController.clear();
        _descriptionController.clear();
        // Refresh list after upload
        await _loadAudioFiles();
      } else {
        print('[UPLOAD] Error: ${response.statusCode} $responseBody');
        _showError(
          ApiService.mapFailure(
            statusCode: response.statusCode,
            responseBody: responseBody,
            context: 'audio upload',
          ).message,
        );
      }
    } catch (e) {
      print('[UPLOAD] Error: $e');
      _showError(
        ApiService.mapFailure(error: e, context: 'audio upload').message,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Sends [request] while announcing upload progress every 25 percent.
  Future<http.StreamedResponse> _sendWithProgress(
    http.MultipartRequest request,
    String title,
  ) async {
    final total = request.contentLength;
    final body = request.finalize();
    final streamed = http.StreamedRequest(request.method, request.url)
      ..contentLength = total
      ..followRedirects = request.followRedirects
      ..headers.addAll(request.headers);
    var sent = 0;
    var milestone = 0;
    body.listen(
      (chunk) {
        streamed.sink.add(chunk);
        sent += chunk.length;
        if (total <= 0) return;
        final reached = (sent * 100 ~/ total) ~/ 25 * 25;
        if (reached > milestone && reached < 100) {
          milestone = reached;
          _announce('$title: $reached percent uploaded.');
        }
      },
      onDone: streamed.sink.close,
      onError: streamed.sink.addError,
      cancelOnError: true,
    );
    return streamed.send();
  }

  // Local Audio Preview
  Future<void> _playAudioLocally(int audioId, String title) async {
    try {
      if (_playingAudioId == audioId) {
        await _audioPlayer.stop();
        setState(() => _playingAudioId = null);
        await _speakIfEnabled("Preview of $title stopped");
        return;
      }

      await _audioPlayer.stop();
      // Backend streaming endpoint
      final url = await ApiService.mediaUrl('/audio/$audioId/stream');
      // Streams audio directly from backend
      await _audioPlayer.play(UrlSource(url));
      // updates UI state
      setState(() => _playingAudioId = audioId);
      await _speakIfEnabled("Previewing $title privately");
    } catch (e) {
      print('[PLAY] Error: $e');
      _showError(
        'Could not play $title. Check your connection and try again.',
      );
    }
  }

  // Select audio for current session
  Future<void> _selectForSession(int audioId, String title) async {
    if (widget.sessionId == null) {
      _showError("No active session");
      return;
    }

    try {
      // Marks audio as selected for session
      final result = await ApiService.selectAudio(
        widget.sessionId!,
        audioId,
        canSend: () => mounted,
      );
      if (!mounted) return;

      if (result.isSuccess) {
        // update UI
        setState(() => _selectedAudioId = audioId);
        await _speakIfEnabled("Selected $title for session");
        if (!mounted) return;

        // Ask if they want to play immediately
        final play = await showDialog<bool>(
          context: context,
          builder: (_) => KeypadConfirmationDialog(
            title: 'Audio Selected',
            message: 'Play "$title" for everyone in the session now?',
            cancelLabel: 'Not Yet',
            confirmLabel: 'Play Now',
            cancelKey: 0,
            confirmKey: 1,
          ),
        );

        if (play == true && mounted) {
          await _playForSession(audioId);
        }
      } else {
        _showError(result.failure!.message);
      }
    } catch (e) {
      print('[SELECT] Error: $e');
      _showError("Failed to select audio");
    }
  }

  Future<void> _playForSession(int audioId) async {
    if (widget.sessionId == null) return;

    try {
      // Triggers backend broadcast - every participant hears audio
      final result = await ApiService.playAudio(
        widget.sessionId!,
        audioId: audioId,
        speed: 1.0,
        canSend: () => mounted,
      );
      if (!mounted) return;

      if (result.isSuccess) {
        await _speakIfEnabled("Class playback request accepted");
      } else {
        _showError(result.failure!.message);
      }
    } catch (e) {
      print('[PLAY SESSION] Error: $e');
      _showError("Failed to start playback");
    }
  }

  // Pause currently playing audio
  Future<void> _pauseSessionAudio() async {
    if (widget.sessionId == null) return;

    try {
      final result = await ApiService.pauseAudio(
        widget.sessionId!,
        canSend: () => mounted,
      );
      if (!mounted) return;

      if (result.isSuccess) {
        await _speakIfEnabled("Class pause request accepted");
      } else {
        _showError(result.failure!.message);
      }
    } catch (e) {
      print('[PAUSE] Error: $e');
      _showError("Failed to pause audio");
    }
  }

  // Shows the error visibly (live region) and speaks it once.
  void _showError(String message) => _announce(message, error: true);

  Future<void> _speakIfEnabled(String text) async {
    if (TtsService.isEnabled) {
      await TtsService.speak(text);
    }
  }

  // Frees memory and text controllers
  @override
  void dispose() {
    TtsService.unregisterRecordedPlayback(_audioPlayer);
    // Cancel any pending operations
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();

    // Stop and dispose audio player BEFORE disposing
    _audioPlayer.stop();
    _audioPlayer.dispose();
    TtsService.stop();

    // Call super.dispose last
    super.dispose();
  }

  // Build Final UI for Audio Screen
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool compact = tiny || UIUtils.isShort(context);
    return KeypadInstructionWrapper(
      screenName: 'Audio library',
      navigationSections:
          'recordings, playback and speech controls, recording sharing, and upload tools when available',
      labels: {
        0: 'Back',
        1: 'Refresh Audio Files',
        2: 'Upload Audio',
        if (widget.sessionId != null) 4: 'Pause Session Audio',
      },
      actions: {
        0: () => Navigator.pop(context),
        1: _loadAudioFiles,
        2: _uploadAudioFile,
        if (widget.sessionId != null) 4: _pauseSessionAudio,
      },
      focusTargets: _focusTargets,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _focusNode('back'),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            widget.sessionId != null
                ? 'Audio - Session ${widget.sessionId}'
                : 'Audio Library',
            style: TextStyle(
              fontSize: UIUtils.fontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          toolbarHeight: tiny ? 40 : null,
          actions: [
            IconButton(
              focusNode: _focusNode('refresh'),
              tooltip: 'Refresh audio files',
              onPressed: _loadAudioFiles,
              icon: const Icon(Icons.refresh),
            ),
            if (widget.sessionId != null)
              IconButton(
                focusNode: _focusNode('pause-session'),
                icon: Icon(
                  Icons.pause_rounded,
                  size: UIUtils.iconSize(context, 24),
                  color: UIUtils.accentColor,
                ),
                tooltip: 'Pause audio for the whole session, key 4',
                onPressed: _pauseSessionAudio,
              ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isUploading)
                    LinearProgressIndicator(
                      color: UIUtils.accentColor,
                      backgroundColor: UIUtils.cardBorderColor,
                    ),
                  if (_statusMessage != null)
                    Padding(
                      padding: UIUtils.paddingSymmetric(
                        context,
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 16),
                            fontWeight: FontWeight.w700,
                            color: _statusIsError
                                ? UIUtils.errorColor
                                : UIUtils.textColor,
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: UIUtils.paddingAll(context, compact ? 6 : 10),
                    child: ElevatedButton.icon(
                      focusNode: _focusNode('upload'),
                      onPressed: _isUploading ? null : _uploadAudioFile,
                      icon: Icon(
                        Icons.upload_file_rounded,
                        size: UIUtils.iconSize(context, 18),
                      ),
                      label: Text(
                        compact ? 'Upload Audio' : 'Upload New Audio',
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(
                            context,
                            compact ? 12 : 14,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIUtils.primaryColor,
                        foregroundColor: UIUtils.onPrimaryColor,
                        padding: UIUtils.paddingSymmetric(
                          context,
                          vertical: compact ? 10 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(compact ? 8 : 12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  Padding(
                    padding: UIUtils.paddingSymmetric(context, horizontal: 10),
                    child: Text(
                      '${_audioFiles.length} recordings',
                      style: TextStyle(
                        fontSize: UIUtils.fontSize(context, 14),
                        fontWeight: FontWeight.w700,
                        color: UIUtils.textColor,
                      ),
                    ),
                  ),

                  SizedBox(height: UIUtils.spacing(context, compact ? 2 : 4)),

                  Expanded(
                    child: _audioFiles.isEmpty
                        ? Center(
                            child: Text(
                              'No recordings yet. Press 2 to upload audio.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 13),
                                color: UIUtils.subtextColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: UIUtils.paddingAll(
                              context,
                              compact ? 4 : 8,
                            ),
                            itemCount: _audioFiles.length,
                            itemBuilder: (context, index) {
                              final audio = _audioFiles[index];
                              final audioId = audio['audio_id'] ?? audio['id'];
                              final title = audio['title'] ?? 'Untitled';
                              final description = audio['description'] ?? '';
                              final uploadedAt = audio['uploaded_at'] ?? '';
                              final isPlaying = _playingAudioId == audioId;
                              final isSelected = _selectedAudioId == audioId;

                              return Card(
                                margin: EdgeInsets.only(
                                  bottom: UIUtils.spacing(
                                    context,
                                    compact ? 6 : 10,
                                  ),
                                  left: compact ? 4 : 10,
                                  right: compact ? 4 : 10,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: UIUtils.cardBorderColor,
                                    width: 1.5,
                                  ),
                                ),
                                color: isSelected
                                    ? UIUtils.accentColor.withValues(alpha: 0.18)
                                    : UIUtils.cardColor,
                                child: Padding(
                                  padding: UIUtils.paddingAll(
                                    context,
                                    compact ? 8 : 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isPlaying
                                                ? Icons.music_note_rounded
                                                : Icons.audiotrack_rounded,
                                            color: isPlaying
                                                ? UIUtils.successColor
                                                : UIUtils.accentColor,
                                            size: UIUtils.iconSize(
                                              context,
                                              compact ? 20 : 24,
                                            ),
                                          ),
                                          SizedBox(
                                            width: UIUtils.spacing(context, 6),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        title,
                                                        style: TextStyle(
                                                          fontSize:
                                                              UIUtils.fontSize(
                                                                context,
                                                                15,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              UIUtils.textColor,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isSelected)
                                                      Container(
                                                        padding:
                                                            UIUtils.paddingSymmetric(
                                                              context,
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: UIUtils
                                                              .primaryColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          'Selected',
                                                          style: TextStyle(
                                                            color: UIUtils
                                                                .onPrimaryColor,
                                                            fontSize:
                                                                UIUtils.fontSize(
                                                                  context,
                                                                  9,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (description.isNotEmpty &&
                                                    !tiny)
                                                  Text(
                                                    description,
                                                    style: TextStyle(
                                                      fontSize:
                                                          UIUtils.fontSize(
                                                            context,
                                                            11,
                                                          ),
                                                      color:
                                                          UIUtils.subtextColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (uploadedAt.isNotEmpty && !tiny)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: UIUtils.spacing(context, 4),
                                            left: 30 * UIUtils.scale(context),
                                          ),
                                          child: Text(
                                            'Uploaded: $uploadedAt',
                                            style: TextStyle(
                                              fontSize: UIUtils.fontSize(
                                                context,
                                                10,
                                              ),
                                              color: UIUtils.subtextColor,
                                            ),
                                          ),
                                        ),

                                      SizedBox(
                                        height: UIUtils.spacing(
                                          context,
                                          compact ? 4 : 6,
                                        ),
                                      ),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Wrap(
                                          alignment: WrapAlignment.end,
                                          spacing: UIUtils.spacing(context, 4),
                                          runSpacing: UIUtils.spacing(
                                            context,
                                            4,
                                          ),
                                          children: [
                                            ElevatedButton.icon(
                                              focusNode: _focusNode(
                                                'preview-$audioId',
                                              ),
                                              onPressed: () =>
                                                  _playAudioLocally(
                                                    audioId,
                                                    title,
                                                  ),
                                              icon: Icon(
                                                isPlaying
                                                    ? Icons.stop_rounded
                                                    : Icons.headphones_rounded,
                                                size: UIUtils.iconSize(
                                                  context,
                                                  18,
                                                ),
                                              ),
                                              label: Text(
                                                compact
                                                    ? (isPlaying
                                                          ? 'Stop'
                                                          : 'Preview')
                                                    : (isPlaying
                                                          ? 'Stop Preview'
                                                          : 'Preview (Only Me)'),
                                                semanticsLabel: isPlaying
                                                    ? 'Stop preview of $title'
                                                    : 'Preview $title privately',
                                                style: TextStyle(
                                                  fontSize: UIUtils.fontSize(
                                                    context,
                                                    compact ? 11 : 12,
                                                  ),
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    UIUtils.accentColor,
                                                foregroundColor:
                                                    UIUtils.onAccentColor,
                                                padding:
                                                    UIUtils.paddingSymmetric(
                                                      context,
                                                      horizontal: compact
                                                          ? 8
                                                          : 12,
                                                      vertical: compact ? 5 : 6,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                            ),

                                            if (widget.sessionId != null) ...[
                                              ElevatedButton.icon(
                                                focusNode: _focusNode(
                                                  'broadcast-$audioId',
                                                ),
                                                onPressed: () =>
                                                    _selectForSession(
                                                      audioId,
                                                      title,
                                                    ),
                                                icon: Icon(
                                                  Icons.campaign_rounded,
                                                  size: UIUtils.iconSize(
                                                    context,
                                                    18,
                                                  ),
                                                ),
                                                label: Text(
                                                  compact
                                                      ? 'Session'
                                                      : 'Play in Session',
                                                  semanticsLabel:
                                                      'Play $title for everyone in the session',
                                                  style: TextStyle(
                                                    fontSize: UIUtils.fontSize(
                                                      context,
                                                      compact ? 11 : 12,
                                                    ),
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      UIUtils.primaryColor,
                                                  foregroundColor:
                                                      UIUtils.onPrimaryColor,
                                                  padding:
                                                      UIUtils.paddingSymmetric(
                                                        context,
                                                        horizontal: compact
                                                            ? 8
                                                            : 12,
                                                        vertical: compact
                                                            ? 5
                                                            : 6,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
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
  }
}

/// ──────────────────────────────────────────────────────────────────────────────
/// Offline Audio Library – Sessions/Classes List
///
/// Shows a list of active classes/sessions (like the dashboard home page)
/// plus a "Search by ID" field. Tapping a class opens ClassAudioScreen
/// which shows all audio files uploaded by that class's teacher.
/// ──────────────────────────────────────────────────────────────────────────────
class OfflineAudioLibraryScreen extends StatefulWidget {
  const OfflineAudioLibraryScreen({super.key, this.classId, this.subjectId});

  final int? classId;
  final int? subjectId;

  @override
  State<OfflineAudioLibraryScreen> createState() =>
      _OfflineAudioLibraryScreenState();
}

class _OfflineAudioLibraryScreenState extends State<OfflineAudioLibraryScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  bool _userInfoLoaded = false;
  bool _sessionsLoaded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, FocusNode> _focusNodes = {};
  final KeypadNavigationController _navigation = KeypadNavigationController();
  bool _isTeacher = false;
  int? _currentUserId;
  bool _continuing = false;
  String? _sessionsIssue;

  FocusNode _focusNode(String name) => _focusNodes.putIfAbsent(
    name,
    () => FocusNode(debugLabel: 'recorded-library-$name'),
  );

  List<KeypadFocusTarget> get _focusTargets => [
    KeypadFocusTarget(
      node: _focusNode('browse'),
      label: 'Focus first active class. Use D-pad to browse active sessions',
      onActivate: _focusFirstActiveClass,
    ),
    KeypadFocusTarget(
      node: _focusNode('back'),
      label: 'Back',
      onActivate: () => Navigator.of(context).maybePop(),
    ),
    KeypadFocusTarget(
      node: _focusNode('refresh'),
      label: 'Refresh classes',
      onActivate: _loadSessions,
    ),
    KeypadFocusTarget(
      node: _searchFocusNode,
      label: 'Search class by name',
      isTextField: true,
    ),
    KeypadFocusTarget(
      node: _focusNode('search'),
      label: 'Search',
      onActivate: _searchByName,
    ),
    KeypadFocusTarget(
      node: _focusNode('all'),
      label: 'All recorded audio files',
      onActivate: _openAllAudioFiles,
    ),
    KeypadFocusTarget(
      node: _focusNode('continue'),
      label: 'Continue learning. Find your last unfinished recorded lesson',
      isEnabled: () => !_continuing,
      onActivate: _continueLearning,
    ),
    KeypadFocusTarget(
      node: _focusNode('downloads'),
      label:
          'Downloaded lessons. Open saved recordings without loading online lists',
      onActivate: () => Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const DownloadsScreen()),
      ),
    ),
    KeypadFocusTarget(
      node: _focusNode('notes'),
      label:
          'Private notes and teacher recording drafts. Works from local storage',
      onActivate: () => Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => const PrivateNotesScreen()),
      ),
    ),
    if (!_isTeacher)
      KeypadFocusTarget(
        node: _focusNode('playlists'),
        label: 'My private playlists',
        onActivate: _openMyPlaylists,
      ),
    for (var index = 0; index < _sessions.length; index++)
      KeypadFocusTarget(
        node: _focusNode('session-${_sessions[index]['session_id']}'),
        label:
            '${_sessions[index]['title']}. Class ${index + 1} of ${_sessions.length}',
        onActivate: () => _openClassAudio(_sessions[index]),
      ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSessions();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isTeacher = (prefs.getString('role') ?? '').toLowerCase() == 'teacher';
      _currentUserId = prefs.getInt('user_id');
      _userInfoLoaded = true;
      _isLoading =
          !_sessionsLoaded; // hide spinner only if sessions are also done
    });
  }

  Future<void> _continueLearning() async {
    if (_continuing) return;
    setState(() => _continuing = true);
    void report(String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: ExcludeSemantics(child: Text(message))));
      TtsService.speak(message, priority: SpeechPriority.critical);
    }

    try {
      final store = await LearningProgressStore.forCurrentUser();
      final recent = (await store.recent())
          .where((lesson) => !lesson.completed)
          .toList();
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      if (preferences.getInt('user_id') != store.userId) {
        report('Your account changed. Open the library again.');
        return;
      }
      if (recent.isEmpty) {
        report(
          'No unfinished lesson is saved for this account. Choose a recorded lesson to start learning.',
        );
        return;
      }
      final audio = await ApiService.getAudioList();
      if (!mounted) return;
      if (preferences.getInt('user_id') != store.userId) {
        report('Your account changed. Open the library again.');
        return;
      }
      if (audio == null) {
        report(
          'Could not check lesson access. Connect to the internet and retry. Your saved progress is kept.',
        );
        return;
      }
      final authorized = audio
          .whereType<Map<String, dynamic>>()
          .where(
            (entry) =>
                (widget.classId == null ||
                    entry['class_id'] == widget.classId) &&
                (widget.subjectId == null ||
                    entry['subject_id'] == widget.subjectId),
          )
          .toList();
      final availableIds = authorized.map((entry) => entry['audio_id']).toSet();
      final available = recent
          .where((lesson) => availableIds.contains(lesson.audioId))
          .toList();
      if (available.isEmpty) {
        report(
          'Your unfinished lessons are not currently available in this library. Your saved progress and bookmarks are kept.',
        );
        return;
      }
      if (available.first.audioId != recent.first.audioId) {
        await TtsService.speak(
          'The most recent lesson is unavailable here. Opening your next most recent available unfinished lesson. Saved progress is kept.',
        );
        if (!mounted) return;
        if (preferences.getInt('user_id') != store.userId) {
          report('Your account changed. Open the library again.');
          return;
        }
      }
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => ClassAudioScreen(
            sessionId: 0,
            sessionTitle: 'Continue Learning',
            isTeacher: _isTeacher,
            classId: widget.classId,
            subjectId: widget.subjectId,
            initialAudioId: available.first.audioId,
          ),
        ),
      );
    } on LearningStorageException catch (error) {
      report(error.message);
    } on Exception catch (error) {
      debugPrint('[LEARNING] Continue learning failed (${error.runtimeType})');
      report(
        'Could not open saved learning progress. Check storage, your connection, and sign-in, then retry.',
      );
    } finally {
      if (mounted) setState(() => _continuing = false);
    }
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;

    try {
      final result = await ApiService.getResult(
        '/sessions/active',
        useAuth: true,
        requestTimeout: const Duration(seconds: 20),
      );
      if (!mounted) return;
      final data = result.data;
      if (result.isSuccess &&
          data is List &&
          data.every(
            (item) => item is Map<String, dynamic> && item['session_id'] is int,
          )) {
        setState(() {
          _sessions = data.cast<Map<String, dynamic>>();
          _sessionsIssue = null;
        });
        TtsService.speak(
          _sessions.isEmpty
              ? 'No active classes right now. Press 3 for all audio files.'
              : '${_sessions.length} active classes loaded.',
          priority: SpeechPriority.incidental,
        );
      } else {
        final message =
            '${result.failure?.message ?? 'The class list could not be read.'} '
            'Active classes could not be refreshed. Press 1 to retry. Saved downloads remain available.';
        setState(() => _sessionsIssue = message);
        TtsService.speak(message, priority: SpeechPriority.critical);
      }
    } finally {
      if (mounted) {
        setState(() {
          _sessionsLoaded = true;
          _isLoading =
              !_userInfoLoaded; // hide spinner only if user info is also done
        });
      }
    }
  }

  void _openClassAudio(Map<String, dynamic> session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassAudioScreen(
          sessionId: session['session_id'] as int,
          sessionTitle: session['title'] as String? ?? 'Session',
          teacherId: session['created_by'] as int?,
          isTeacher: _isTeacher,
          classId: session['class_id'] as int?,
          subjectId: session['subject_id'] as int?,
        ),
      ),
    );
  }

  void _searchByName() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final exact = _sessions.where((s) {
      final title = (s['title'] ?? '').toString().toLowerCase();
      return title == query;
    }).toList();

    // Search in loaded sessions first
    final partial = _sessions.where((s) {
      final title = (s['title'] ?? '').toString().toLowerCase();
      return title.contains(query);
    }).toList();

    final matches = exact.isNotEmpty ? exact : partial;
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: ExcludeSemantics(
            child: Text('No class found with this session name'),
          ),
        ),
      );
      TtsService.speak('No class found with this session name.');
      return;
    }

    _openClassAudio(matches.first);
    _searchController.clear();
  }

  /// Opens the personal (teacher) or global (student) audio library.
  void _openAllAudioFiles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassAudioScreen(
          sessionId: 0,
          sessionTitle: _isTeacher ? 'My Audio Library' : 'All Audio Files',
          teacherId: _isTeacher ? _currentUserId : null,
          isTeacher: _isTeacher,
          classId: widget.classId,
          subjectId: widget.subjectId,
        ),
      ),
    );
  }

  void _focusFirstActiveClass() {
    if (_isLoading) {
      TtsService.speak('Classes are still loading. Try key 5 again shortly.');
      return;
    }
    if (_sessionsIssue != null) {
      TtsService.speak(_sessionsIssue!);
      return;
    }
    if (_sessions.isEmpty) {
      TtsService.speak(
        'There are no active classes. Staying in the audio library.',
      );
      return;
    }
    final session = _sessions.first;
    final node = _focusNode('session-${session['session_id']}');
    if (node.context != null) {
      Scrollable.ensureVisible(node.context!, alignment: 0.5);
    }
    _navigation.focusAndAnnounce(
      node,
      '${session['title']}. First active class. '
      'Use D-pad up and down to browse active class sessions. '
      'Press OK to open the selected class recordings.',
    );
  }

  void _openMyPlaylists() {
    if (_isTeacher) return;
    TtsService.speak('Opening My Playlists. Playlist contents are private.');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentPlaylistsScreen()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return KeypadInstructionWrapper(
      screenName:
          'Recorded Audio Library. Online lists require internet. Downloaded lessons open separately for offline playback.',
      navigationSections:
          'continue learning, saved downloads and private notes, class search, and active class sessions',
      labels: {
        ...offlineAudioLibraryKeyLabels,
        if (!_isTeacher) 4: 'My Private Playlists',
      },
      actions: {
        1: () {
          setState(() {
            _sessionsLoaded = false;
            _isLoading = true;
          });
          _loadSessions();
        },
        2: () => _searchFocusNode.requestFocus(),
        3: _openAllAudioFiles,
        if (!_isTeacher) 4: _openMyPlaylists,
        5: _focusFirstActiveClass,
        0: () => Navigator.of(context).pop(),
      },
      navigationController: _navigation,
      focusTargets: _focusTargets,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _focusNode('back'),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Recorded Audio Library',
            style: TextStyle(
              fontSize: UIUtils.fontSize(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          toolbarHeight: tiny ? 40 : null,
          actions: [
            IconButton(
              focusNode: _focusNode('downloads'),
              tooltip: 'Downloaded lessons',
              icon: const Icon(Icons.download_done),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              ),
            ),
            IconButton(
              focusNode: _focusNode('notes'),
              tooltip: 'Private notes and recording drafts',
              icon: const Icon(Icons.mic_none),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const PrivateNotesScreen()),
              ),
            ),
            IconButton(
              focusNode: _focusNode('refresh'),
              icon: Icon(
                Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor,
              ),
              tooltip: 'Refresh',
              onPressed: () {
                setState(() {
                  _sessionsLoaded = false;
                  _isLoading = true;
                });
                _loadSessions();
              },
            ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_sessionsIssue != null)
                      Semantics(liveRegion: true, child: Text(_sessionsIssue!)),
                    OutlinedButton(
                      focusNode: _focusNode('browse'),
                      onPressed: _focusFirstActiveClass,
                      child: const Text('5: Browse active classes'),
                    ),
                    OutlinedButton.icon(
                      focusNode: _focusNode('continue'),
                      onPressed: _continuing ? null : _continueLearning,
                      icon: const Icon(Icons.history),
                      label: Text(
                        _continuing
                            ? 'Finding your lesson'
                            : 'Continue Learning',
                      ),
                    ),
                    // ── Instruction ──────────────────────────────────────
                    Container(
                      padding: UIUtils.paddingAll(context, 12),
                      decoration: BoxDecoration(
                        color: UIUtils.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: UIUtils.cardBorderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: UIUtils.accentColor,
                            size: UIUtils.iconSize(context, 20),
                          ),
                          SizedBox(width: UIUtils.spacing(context, 8)),
                          Expanded(
                            child: Text(
                              'Select a class to play recorded lessons. '
                              'Online lessons require internet. Use Downloaded lessons for saved audio.',
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(context, 13),
                                color: UIUtils.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: UIUtils.spacing(context, 14)),

                    // ── Search by Session Name ─────────────────────────────
                    Container(
                      padding: UIUtils.paddingAll(context, 12),
                      decoration: BoxDecoration(
                        color: UIUtils.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: UIUtils.isHighContrast
                              ? UIUtils.accentColor
                              : UIUtils.cardBorderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Class by Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: UIUtils.fontSize(context, 14),
                              color: UIUtils.textColor,
                            ),
                          ),
                          SizedBox(height: UIUtils.spacing(context, 8)),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Session/Class Name',
                                    hintStyle: TextStyle(
                                      fontSize: UIUtils.fontSize(context, 13),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 18,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: UIUtils.cardBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: UIUtils.accentColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) => _searchByName(),
                                ),
                              ),
                              SizedBox(width: UIUtils.spacing(context, 8)),
                              ElevatedButton.icon(
                                focusNode: _focusNode('search'),
                                onPressed: _searchByName,
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: UIUtils.iconSize(context, 16),
                                ),
                                label: Text(
                                  "Go",
                                  style: TextStyle(
                                    fontSize: UIUtils.fontSize(context, 13),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: UIUtils.primaryColor,
                                  foregroundColor: UIUtils.onPrimaryColor,
                                  padding: UIUtils.paddingSymmetric(
                                    context,
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: UIUtils.spacing(context, 16)),

                    // ── Personal / All Audio Library ──────────────────
                    Card(
                      margin: EdgeInsets.only(
                        bottom: UIUtils.spacing(context, 16),
                      ),
                      color: UIUtils.cardColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: UIUtils.cardBorderColor,
                        ),
                      ),
                      child: InkWell(
                        focusNode: _focusNode('all'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClassAudioScreen(
                                sessionId:
                                    0, // 0 simply means 'Not a specific class'
                                sessionTitle: _isTeacher
                                    ? 'My Audio Library'
                                    : 'All Audio Files',
                                teacherId: _isTeacher ? _currentUserId : null,
                                isTeacher: _isTeacher,
                                classId: widget.classId,
                                subjectId: widget.subjectId,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: UIUtils.paddingAll(context, 14),
                          child: Row(
                            children: [
                              Container(
                                width: 44 * UIUtils.scale(context),
                                height: 44 * UIUtils.scale(context),
                                decoration: BoxDecoration(
                                  color: UIUtils.backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.library_music_rounded,
                                  color: UIUtils.accentColor,
                                  size: UIUtils.iconSize(context, 22),
                                ),
                              ),
                              SizedBox(width: UIUtils.spacing(context, 12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isTeacher
                                          ? 'My Audio Library'
                                          : 'All Audio Files',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: UIUtils.fontSize(context, 15),
                                        color: UIUtils.textColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: UIUtils.spacing(context, 3),
                                    ),
                                    Text(
                                      _isTeacher
                                          ? 'Manage and upload your audio files'
                                          : 'Browse all uploaded audio files',
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(context, 12),
                                        color: UIUtils.subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: UIUtils.accentColor,
                                size: UIUtils.iconSize(context, 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (!_isTeacher) ...[
                      OutlinedButton.icon(
                        focusNode: _focusNode('playlists'),
                        onPressed: _openMyPlaylists,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('4: My Playlists · Private'),
                      ),
                      SizedBox(height: UIUtils.spacing(context, 16)),
                    ],

                    // ── Classes / Sessions Header ────────────────────────
                    Row(
                      children: [
                        Icon(
                          Icons.class_rounded,
                          size: UIUtils.iconSize(context, 20),
                          color: UIUtils.accentColor,
                        ),
                        SizedBox(width: UIUtils.spacing(context, 6)),
                        Expanded(
                          child: Text(
                            'Active Classes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: UIUtils.fontSize(context, 16),
                              color: UIUtils.textColor,
                            ),
                          ),
                        ),
                        Text(
                          '${_sessions.length} found',
                          style: TextStyle(
                            fontSize: UIUtils.fontSize(context, 12),
                            color: UIUtils.subtextColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: UIUtils.spacing(context, 10)),

                    // ── Sessions List ────────────────────────────────────
                    if (_sessions.isEmpty)
                      Container(
                        padding: UIUtils.paddingAll(context, 32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: UIUtils.iconSize(context, 48),
                              color: UIUtils.subtextColor,
                            ),
                            SizedBox(height: UIUtils.spacing(context, 8)),
                            Text(
                              'No active classes found.',
                              style: TextStyle(
                                color: UIUtils.subtextColor,
                                fontSize: UIUtils.fontSize(context, 14),
                              ),
                            ),
                            SizedBox(height: UIUtils.spacing(context, 6)),
                            Text(
                              'Use "Search by Session Name" above to access a class quickly.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: UIUtils.subtextColor,
                                fontSize: UIUtils.fontSize(context, 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_sessions.length, (i) {
                        final session = _sessions[i];
                        final title =
                            session['title'] ??
                            'Session ${session['session_id']}';
                        final sessionId = session['session_id'] ?? 0;

                        return Card(
                          margin: EdgeInsets.only(
                            bottom: UIUtils.spacing(context, 8),
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: UIUtils.isHighContrast
                                  ? UIUtils.accentColor
                                  : UIUtils.cardBorderColor,
                            ),
                          ),
                          color: UIUtils.cardColor,
                          child: InkWell(
                            focusNode: _focusNode('session-$sessionId'),
                            onTap: () => _openClassAudio(session),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: UIUtils.paddingAll(context, 14),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 44 * UIUtils.scale(context),
                                    height: 44 * UIUtils.scale(context),
                                    decoration: BoxDecoration(
                                      color: UIUtils.backgroundColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.library_music_rounded,
                                      color: UIUtils.accentColor,
                                      size: UIUtils.iconSize(context, 22),
                                    ),
                                  ),
                                  SizedBox(width: UIUtils.spacing(context, 12)),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: UIUtils.fontSize(
                                              context,
                                              15,
                                            ),
                                            color: UIUtils.textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: UIUtils.spacing(context, 3),
                                        ),
                                        Text(
                                          'Session #$sessionId',
                                          style: TextStyle(
                                            fontSize: UIUtils.fontSize(
                                              context,
                                              11,
                                            ),
                                            color: UIUtils.subtextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: UIUtils.subtextColor,
                                    size: UIUtils.iconSize(context, 22),
                                  ),
                                ],
                              ),
                            ),
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

/// ──────────────────────────────────────────────────────────────────────────────
/// Class Audio Screen
///
/// Shows audio files for a SPECIFIC class/session. The audio files are filtered
/// by the teacher who created the session (uploaded_by == created_by).
/// Teachers get an upload button; students can only browse and play.
/// ──────────────────────────────────────────────────────────────────────────────
class ClassAudioScreen extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;
  final int? teacherId; // created_by user_id of the session
  final bool isTeacher;
  final int? classId;
  final int? subjectId;
  final int? initialAudioId;
  final bool downloadedOnly;

  const ClassAudioScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
    this.teacherId,
    this.isTeacher = false,
    this.classId,
    this.subjectId,
    this.initialAudioId,
    this.downloadedOnly = false,
  });

  @override
  State<ClassAudioScreen> createState() => _ClassAudioScreenState();
}

class _ClassAudioScreenState extends State<ClassAudioScreen>
    with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final _learning = LearningPlaybackController(
    seek: _audioPlayer.seek,
    setSpeed: _audioPlayer.setPlaybackRate,
    resume: () async {
      await _audioPlayer.resume();
      if (mounted) setState(() => _isPlaying = true);
    },
    isPlaying: () =>
        mounted && _isPlaying && _audioPlayer.state == PlayerState.playing,
    onIssue: _showError,
  );
  LearningControls get _learningControls => LearningControls(
    controller: _learning,
    nodeFor: _controlNode,
    showSpeedControls: false,
    showSeekControls: false,
    pauseForNotes: () async {
      if (_playPending) {
        throw const LearningStorageException(
          'Wait for the recording player before opening study notes.',
        );
      }
      await _audioPlayer.pause();
      if (mounted) setState(() => _isPlaying = false);
      await _learning.flush();
    },
  );
  bool _playPending = false;
  Completer<void>? _playSettled;
  int _playRevision = 0;
  bool _initialLessonHandled = false;
  OfflineLessonStore? _offlineStore;
  final Map<String, FocusNode> _controlNodes = {};
  final Map<int, FocusNode> _audioNodes = {};
  final FocusNode _subjectFilterFocusNode = FocusNode(
    debugLabel: 'audio-subject-filter',
  );

  List<Map<String, dynamic>> _allAudioFiles = [];
  List<Map<String, dynamic>> _audioFiles = [];
  bool _isLoading = true;
  bool _isUploadingAudio = false;
  int? _resolvedTeacherId;
  String _playbackStatus = 'Stopped';
  String? _libraryStatus;
  bool _libraryError = false;
  int? _selectedSubjectId;
  List<Map<String, dynamic>> _teacherSessions = [];

  // Playback state
  int? _playingAudioId;
  String? _playingAudioTitle;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double? _totalDuration;
  double _audioSpeed = 1.0;

  FocusNode _controlNode(String name) => _controlNodes.putIfAbsent(
    name,
    () => FocusNode(debugLabel: 'class-audio-$name'),
  );

  FocusNode _audioNode(int id) => _audioNodes.putIfAbsent(
    id,
    () => FocusNode(debugLabel: 'audio-item-$id'),
  );

  int _idOf(Map<String, dynamic> audio) =>
      (audio['audio_id'] ?? audio['id']) as int;

  String? _audioStatus(int audioId) => _playingAudioId != audioId
      ? null
      : _isPlaying
      ? 'Playing'
      : 'Paused';

  String _audioLabel(int index) {
    final audio = _audioFiles[index];
    final status = _audioStatus(_idOf(audio));
    return [
      '${audio['title'] ?? 'Untitled'}',
      if (status != null) status,
      '${audio['subject_name'] ?? 'Subject'}',
      if ('${audio['description'] ?? ''}'.isNotEmpty) '${audio['description']}',
    ].join('. ');
  }

  void _repeatHelp() => TtsService.speak(
    buildTtsInstructions(
      widget.isTeacher
          ? classAudioTeacherKeyLabels
          : classAudioStudentKeyLabels,
      screenName: widget.downloadedOnly
          ? 'Downloaded lessons. Existing offline access is checked before playing.'
          : 'Audio Library. Online recordings require internet. Download lessons for offline playback.',
    ),
  );

  Duration get _position =>
      Duration(milliseconds: (_currentPosition * 1000).round());
  Duration? get _duration => _totalDuration == null
      ? null
      : Duration(milliseconds: (_totalDuration! * 1000).round());

  List<KeypadFocusTarget> get _focusTargets => [
    KeypadFocusTarget(
      node: _controlNode('back'),
      label: 'Back',
      onActivate: () => Navigator.of(context).maybePop(),
    ),
    KeypadFocusTarget(
      node: _controlNode('refresh'),
      label: 'Refresh audio files, key 1',
      onActivate: _loadAudioFiles,
    ),
    if (_playingAudioId != null) ...[
      KeypadFocusTarget(
        node: _controlNode('seek'),
        label:
            'Lesson position ${learningSpokenPosition(_position, _duration)}. '
            'Use left or right to move 10 seconds.',
        onDecrease: () => _seekBy(-10),
        onIncrease: () => _seekBy(10),
        isEnabled: () => _totalDuration != null,
      ),
      KeypadFocusTarget(
        node: _controlNode('rewind'),
        label: 'Back 10 seconds, key $playerRewindKey',
        onActivate: () => _seekBy(-10),
      ),
      KeypadFocusTarget(
        node: _controlNode('play'),
        label: _isPlaying
            ? 'Pause ${_playingAudioTitle ?? 'lesson'}, key $playerPlayPauseKey'
            : 'Resume ${_playingAudioTitle ?? 'lesson'}, key $playerPlayPauseKey',
        onActivate: _togglePlayPause,
      ),
      KeypadFocusTarget(
        node: _controlNode('forward'),
        label: 'Forward 10 seconds, key $playerForwardKey',
        onActivate: () => _seekBy(10),
      ),
      KeypadFocusTarget(
        node: _controlNode('slower'),
        label:
            'Slower, key $playerSlowerKey. Now ${learningSpeedNumber(_audioSpeed)} times',
        onActivate: () => _changeSpeed(-0.25),
        isEnabled: () => _audioSpeed > 0.25,
      ),
      KeypadFocusTarget(
        node: _controlNode('stop'),
        label: 'Stop ${_playingAudioTitle ?? 'lesson'}, key 8',
        onActivate: _stopAudio,
      ),
      KeypadFocusTarget(
        node: _controlNode('faster'),
        label:
            'Faster, key $playerFasterKey. Now ${learningSpeedNumber(_audioSpeed)} times',
        onActivate: () => _changeSpeed(0.25),
        isEnabled: () => _audioSpeed < 3.0,
      ),
      ..._learningControls.focusTargets(context),
    ],
    if (widget.subjectId == null && _availableSubjects.isNotEmpty)
      KeypadFocusTarget(
        node: _subjectFilterFocusNode,
        label:
            'Subject filter, ${_selectedSubjectName ?? 'All subjects'}, key 2. Use left or right to change',
        onActivate: _cycleSubjectFilter,
        onDecrease: () => _cycleSubjectFilter(-1),
        onIncrease: _cycleSubjectFilter,
      ),
    if (!widget.downloadedOnly)
      KeypadFocusTarget(
        node: _controlNode('downloads'),
        label: 'Download lessons or manage saved recordings',
        onActivate: _openDownloads,
      ),
    KeypadFocusTarget(
      node: _controlNode('stop-speech'),
      label: 'Stop speech',
      onActivate: TtsService.stop,
    ),
    KeypadFocusTarget(
      node: _controlNode('repeat-help'),
      label: 'Repeat audio library help',
      onActivate: _repeatHelp,
    ),
    for (var index = 0; index < _audioFiles.length; index++)
      KeypadFocusTarget(
        node: _audioNode(_idOf(_audioFiles[index])),
        label: _audioLabel(index),
        onActivate: () => _playOrPauseAudio(
          _idOf(_audioFiles[index]),
          '${_audioFiles[index]['title'] ?? 'Untitled'}',
        ),
      ),
    if (_audioFiles.isEmpty) ...[
      if (widget.isTeacher)
        KeypadFocusTarget(
          node: _controlNode('upload-empty'),
          label: 'Upload first audio',
          onActivate: _uploadAudio,
          isEnabled: () => !_isUploadingAudio,
        ),
      KeypadFocusTarget(
        node: _controlNode('empty-retry'),
        label: 'Refresh empty audio library',
        onActivate: _loadAudioFiles,
      ),
    ],
    if (widget.isTeacher)
      KeypadFocusTarget(
        node: _controlNode('upload'),
        label: 'Add audio, key 3',
        onActivate: _handleAddAudio,
        isEnabled: () => !_isUploadingAudio,
      ),
  ];

  String? get _selectedSubjectName {
    for (final subject in _availableSubjects) {
      if (subject['subject_id'] == _selectedSubjectId) {
        return '${subject['subject_name']}';
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _learning.addListener(_learningChanged);
    _resolvedTeacherId = widget.teacherId;
    _selectedSubjectId = widget.subjectId;
    if (widget.isTeacher) {
      _loadTeacherSessions();
    }
    _loadAudioFiles();
    _setupAudioListeners();
    TtsService.registerRecordedPlayback(
      _audioPlayer,
      isPlaying: () => mounted && _isPlaying,
      canResume: () => mounted && (ModalRoute.of(context)?.isCurrent ?? true),
      onResumeSkipped: () {
        if (mounted) setState(() => _isPlaying = false);
      },
      item: () => _audioPlayer.source,
      pause: _audioPlayer.pause,
      resume: _audioPlayer.resume,
    );
  }

  Future<void> _openDownloads() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadsScreen(candidates: _audioFiles),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_learning.flush());
    }
  }

  void _learningChanged() {
    if (mounted) {
      setState(() {
        _currentPosition = _learning.position.inMilliseconds / 1000;
        _audioSpeed = _learning.speed;
      });
    }
  }

  Future<void> _loadTeacherSessions() async {
    final sessions = await ApiService.getActiveSessions();
    if (sessions != null && mounted) {
      final mapped = sessions
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final current = mapped.where(
        (session) => session['session_id'] == widget.sessionId,
      );
      final currentSession = current.isEmpty ? null : current.first;
      final workspaceClassId =
          currentSession?['class_id'] as int? ?? widget.classId;
      final workspaceSubjectId =
          currentSession?['subject_id'] as int? ?? widget.subjectId;
      setState(() {
        _teacherSessions =
            workspaceClassId == null || workspaceSubjectId == null
            ? mapped
            : mapped
                  .where(
                    (session) =>
                        session['class_id'] == workspaceClassId &&
                        session['subject_id'] == workspaceSubjectId,
                  )
                  .toList();
      });
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted &&
          (state == PlayerState.playing || state == PlayerState.paused)) {
        _learning.observePlayback(state == PlayerState.playing);
      }
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) _learning.updatePosition(pos);
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() => _totalDuration = dur.inSeconds.toDouble());
        if (_learning.ready) _learning.updateDuration(dur);
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) async {
      if (!mounted) return;
      final revision = _playRevision;
      if (_playPending) await _playSettled?.future;
      if (!mounted || revision != _playRevision || !_learning.ready) return;
      final looping = await _learning.handleCompletion();
      if (mounted && revision == _playRevision && !looping) {
        final title = _playingAudioTitle ?? 'Lesson';
        setState(() {
          _isPlaying = false;
          _currentPosition = 0;
          _playingAudioId = null;
          _playingAudioTitle = null;
          _playbackStatus = 'Finished $title';
        });
        _speakIfEnabled('$title finished.');
      }
    });
  }

  Future<void> _loadAudioFiles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      print(
        '[CLASS AUDIO] Fetching audio list... teacherId=$_resolvedTeacherId sessionId=${widget.sessionId}',
      );
      final List<dynamic>? result;
      if (widget.downloadedOnly) {
        final store = _offlineStore ??=
            await OfflineLessonStore.forCurrentUser();
        result = (await store.list())
            .where((lesson) => lesson.complete)
            .map(
              (lesson) => <String, dynamic>{
                'audio_id': lesson.audioId,
                'title': lesson.title,
                'class_id': lesson.classId,
                'subject_id': lesson.subjectId,
                'description':
                    'Downloaded recording. Access renewal required after 30 days.',
                'subject_name': 'Saved subject ${lesson.subjectId}',
              },
            )
            .toList();
      } else {
        result = widget.sessionId == 0
            ? await ApiService.getAudioList()
            : await ApiService.getAudioListBySession(widget.sessionId);
      }
      print(
        '[CLASS AUDIO] getAudioList result type=${result?.runtimeType} count=${result?.length}',
      );

      if (result == null) {
        print(
          '[CLASS AUDIO] API returned null - check backend connection and user_id param',
        );
        if (mounted) {
          _setLibraryStatus(
            widget.downloadedOnly
                ? 'Could not read downloaded lessons. Press 1 to retry.'
                : 'Could not load recordings. Check your internet connection and sign-in, then press 1 to retry.',
            error: true,
          );
        }
        return;
      }

      if (mounted) {
        // Safely parse JSON to avoid List<dynamic> cast exceptions
        List<Map<String, dynamic>> allFiles = result
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        print('[CLASS AUDIO] Total files from API: ${allFiles.length}');

        if (widget.sessionId == 0 && _resolvedTeacherId != null) {
          allFiles = allFiles
              .where(
                (f) =>
                    f['uploaded_by']?.toString() ==
                    _resolvedTeacherId.toString(),
              )
              .toList();
        }
        if (widget.classId != null) {
          allFiles = allFiles
              .where((file) => file['class_id'] == widget.classId)
              .toList();
        }
        setState(() {
          _allAudioFiles = allFiles;
          final subjectIds = allFiles
              .map((file) => file['subject_id'])
              .whereType<int>()
              .toSet();
          if (_selectedSubjectId != null &&
              !subjectIds.contains(_selectedSubjectId)) {
            _selectedSubjectId = widget.subjectId;
          }
          _applyAudioFilters();
        });
        await _setLibraryStatus(
          _audioFiles.isEmpty
              ? 'No recordings yet for ${widget.sessionTitle}.'
              : '${_audioFiles.length} recordings loaded for ${widget.sessionTitle}.',
        );
        if (mounted &&
            !_initialLessonHandled &&
            widget.initialAudioId != null) {
          _initialLessonHandled = true;
          final selected = _audioFiles.where(
            (audio) => audio['audio_id'] == widget.initialAudioId,
          );
          if (selected.isEmpty) {
            _showError(
              'This lesson is no longer available. Your saved progress and bookmarks are kept.',
            );
          } else {
            await _playOrPauseAudio(
              widget.initialAudioId!,
              '${selected.first['title']}',
            );
          }
        }
      }
    } catch (e) {
      print('[CLASS AUDIO] Error loading files: $e');
      _setLibraryStatus(
        '${ApiService.mapFailure(error: e, context: 'audio list').message} Press 1 to retry.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _availableSubjects {
    final byId = <int, Map<String, dynamic>>{};
    for (final audio in _allAudioFiles) {
      final id = audio['subject_id'];
      if (id is int) {
        byId[id] = {
          'subject_id': id,
          'subject_name': audio['subject_name'] ?? 'Subject $id',
        };
      }
    }
    return byId.values.toList()..sort(
      (first, second) =>
          '${first['subject_name']}'.compareTo('${second['subject_name']}'),
    );
  }

  void _applyAudioFilters() {
    _audioFiles =
        _allAudioFiles.where((audio) {
          if (widget.subjectId != null &&
              audio['subject_id'] != widget.subjectId) {
            return false;
          }
          return _selectedSubjectId == null ||
              audio['subject_id'] == _selectedSubjectId;
        }).toList()..sort(
          (first, second) => '${first['title']}'.toLowerCase().compareTo(
            '${second['title']}'.toLowerCase(),
          ),
        );
  }

  void _selectSubject(int? subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
      _applyAudioFilters();
    });
    final selected = subjectId == null
        ? null
        : _availableSubjects.cast<Map<String, dynamic>?>().firstWhere(
            (entry) => entry?['subject_id'] == subjectId,
            orElse: () => null,
          );
    _speakIfEnabled(
      selected == null
          ? 'Showing audio from all subjects'
          : 'Showing ${selected['subject_name']} audio. ${_audioFiles.length} files',
    );
  }

  void _cycleSubjectFilter([int direction = 1]) {
    if (widget.subjectId != null) {
      _speakIfEnabled('This library is already limited to one subject');
      return;
    }
    final ids = <int?>[
      null,
      ..._availableSubjects.map((entry) => entry['subject_id'] as int),
    ];
    final currentIndex = ids.indexOf(_selectedSubjectId);
    var next = (currentIndex + direction) % ids.length;
    if (next < 0) next += ids.length;
    _selectSubject(ids[next]);
  }

  Future<void> _playOrPauseAudio(int audioId, String title) async {
    if (_playPending) {
      await _speakIfEnabled('Please wait for the lesson player.');
      return;
    }
    final revision = ++_playRevision;
    final settled = _playSettled = Completer<void>();
    setState(() => _playPending = true);
    try {
      if (_playingAudioId == audioId) {
        if (_isPlaying) {
          await _audioPlayer.pause();
          if (!mounted || revision != _playRevision) return;
          setState(() {
            _isPlaying = false;
            _playbackStatus = 'Paused $title';
          });
          await _learning.flush();
          await _speakIfEnabled(
            'Paused at ${learningSpokenPosition(_position, _duration)}.',
          );
        } else {
          await _audioPlayer.resume();
          if (!mounted || revision != _playRevision) return;
          setState(() {
            _isPlaying = true;
            _playbackStatus = 'Playing $title';
          });
          await _speakIfEnabled(
            learningPlayingAnnouncement(
              title,
              _position,
              _duration,
              _audioSpeed,
            ),
          );
        }
        return;
      }

      await _audioPlayer.pause();
      if (!mounted || revision != _playRevision) return;
      setState(() => _isPlaying = false);
      if (!await LearningControls.prepare(context, _learning, audioId, title)) {
        return;
      }
      if (!mounted || revision != _playRevision) return;
      setState(() {
        _playingAudioId = audioId;
        _playingAudioTitle = title;
        _currentPosition = _learning.position.inMilliseconds / 1000;
        _totalDuration = _learning.duration == null
            ? null
            : _learning.duration!.inMilliseconds / 1000;
        _audioSpeed = _learning.speed;
      });

      final Source source;
      if (widget.downloadedOnly) {
        final store = _offlineStore ??=
            await OfflineLessonStore.forCurrentUser();
        try {
          await store.renew(audioId);
        } on OfflineLessonException catch (error) {
          if (!error.mayUseExistingAccess) rethrow;
          await _speakIfEnabled(
            'Internet unavailable. Checking your saved offline access.',
          );
        }
        final records = await store.list();
        final record = records.firstWhere(
          (lesson) => lesson.audioId == audioId,
        );
        source = DeviceFileSource(
          await store.localPath(audioId),
          mimeType: record.mimeType,
        );
      } else {
        source = UrlSource(await ApiService.mediaUrl('/audio/$audioId/stream'));
      }
      if (!mounted || revision != _playRevision) return;
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      if (!mounted || revision != _playRevision) return;
      await _audioPlayer.setPlaybackRate(_audioSpeed);
      if (!mounted || revision != _playRevision) return;
      await _audioPlayer.play(source, position: _learning.position);
      if (!mounted || revision != _playRevision) return;
      _learning.activate(offline: widget.downloadedOnly);
      setState(() {
        _isPlaying = true;
        _playbackStatus = 'Playing $title';
      });
      final duration = await _audioPlayer.getDuration();
      if (!mounted || revision != _playRevision) return;
      if (duration != null) _learning.updateDuration(duration);

      if (!widget.downloadedOnly) unawaited(_logListen(audioId, revision));

      await _speakIfEnabled(
        learningPlayingAnnouncement(
          title,
          _learning.position,
          duration ?? _duration,
          _audioSpeed,
        ),
      );
    } catch (e) {
      debugPrint('[CLASS AUDIO PLAY] Playback failed (${e.runtimeType})');
      if (!mounted || revision != _playRevision) return;
      _learning.abort();
      _showError(
        e is OfflineLessonException
            ? e.message
            : 'Could not play $title. Check your connection, then select it again.',
      );
      setState(() {
        _isPlaying = false;
        _playingAudioId = null;
        _playingAudioTitle = null;
        _playbackStatus = 'Stopped';
      });
    } finally {
      settled.complete();
      if (mounted && revision == _playRevision) {
        setState(() => _playPending = false);
      }
    }
  }

  Future<void> _logListen(int audioId, int revision) async {
    final result = await ApiService.postResult(
      '/audio/$audioId/play-log',
      {},
      requestTimeout: const Duration(seconds: 10),
      canSend: () => mounted && revision == _playRevision,
    );
    if (!result.isSuccess) {
      debugPrint('[LEARNING] Listen log was not confirmed.');
    }
  }

  Future<void> _stopAudio() async {
    final title = _playingAudioTitle;
    ++_playRevision;
    await _audioPlayer.pause();
    await _learning.flush();
    _learning.abort();
    await _audioPlayer.stop();
    if (!mounted) return;
    setState(() {
      _playPending = false;
      _isPlaying = false;
      _playingAudioId = null;
      _playingAudioTitle = null;
      _currentPosition = 0;
      _totalDuration = null;
      _playbackStatus = 'Stopped';
    });
    await _speakIfEnabled(
      title == null ? 'Nothing is playing.' : '$title stopped.',
    );
  }

  Future<void> _seekBy(int seconds) async {
    if (_playingAudioId == null) {
      await _speakIfEnabled(
        'No lesson is playing. Press $playerPlayPauseKey to play the first lesson.',
      );
      return;
    }
    final end = _totalDuration ?? _currentPosition + seconds.abs();
    await _seekTo((_currentPosition + seconds).clamp(0.0, end).toDouble());
    if (mounted) {
      await _speakIfEnabled(learningSpokenPosition(_position, _duration));
    }
  }

  Future<void> _seekTo(double position) async {
    try {
      await _learning.moveTo(Duration(milliseconds: (position * 1000).round()));
    } on Exception catch (error) {
      debugPrint('[LEARNING] Seek failed (${error.runtimeType})');
      _showError('Could not move to that lesson position. Try again.');
    } on ArgumentError catch (error) {
      _showError(error.message.toString());
    }
  }

  Future<void> _changeSpeed(double delta) async {
    if (_playingAudioId == null) {
      await _speakIfEnabled('No lesson is playing.');
      return;
    }
    final newSpeed = (_audioSpeed + delta).clamp(0.25, 3.0);
    if (newSpeed == _audioSpeed) {
      await _speakIfEnabled(
        delta < 0
            ? 'Already at the slowest speed.'
            : 'Already at the fastest speed.',
      );
      return;
    }
    try {
      await _learning.changeSpeed(newSpeed);
      if (mounted) {
        _speakIfEnabled('Speed ${learningSpeedNumber(newSpeed)} times');
      }
    } on Exception catch (error) {
      debugPrint('[LEARNING] Speed change failed (${error.runtimeType})');
      _showError('Could not change playback speed. Try again.');
    } on ArgumentError catch (error) {
      _showError(error.message.toString());
    }
  }

  String _formatDuration(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0
        ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _speakIfEnabled(String text) async {
    if (TtsService.isEnabled) {
      await TtsService.speak(text);
    }
  }

  Future<void> _setLibraryStatus(String message, {bool error = false}) async {
    if (!mounted) return;
    final firstLoad = _libraryStatus == null;
    setState(() {
      _libraryStatus = message;
      _libraryError = error;
    });
    await TtsService.speak(
      message,
      priority: error
          ? SpeechPriority.critical
          : firstLoad
          ? SpeechPriority.incidental
          : SpeechPriority.requested,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _libraryStatus = message;
      _libraryError = true;
    });
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  // ── Upload Audio (teacher only) ────────────────────────────────────────────
  Future<void> _uploadAudio() async {
    try {
      await TtsService.stop();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: true, // Required for flutter web
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;

      // On web, file.path is null but file.bytes is not.
      if (file.path == null && file.bytes == null) {
        _showError("Failed to read file data.");
        return;
      }

      // Show title input dialog
      final titleController = TextEditingController(
        text: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
      );
      final descController = TextEditingController();
      final titleNode = FocusNode(debugLabel: 'class-upload-title');
      final descriptionNode = FocusNode(debugLabel: 'class-upload-description');
      final cancelNode = FocusNode(debugLabel: 'class-upload-cancel');
      final uploadNode = FocusNode(debugLabel: 'class-upload-confirm');
      final keypadController = KeypadNavigationController();

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => KeypadInstructionWrapper(
          screenName: 'Upload audio',
          labels: const {
            1: 'Edit Title',
            2: 'Edit Description',
            3: 'Upload',
            0: 'Cancel',
          },
          actions: {
            1: () => keypadController.enterTextEditing(titleNode),
            2: () => keypadController.enterTextEditing(descriptionNode),
            3: () => Navigator.pop(dialogContext, true),
            0: () => Navigator.pop(dialogContext, false),
          },
          navigationController: keypadController,
          focusTargets: [
            KeypadFocusTarget(
              node: titleNode,
              label: 'Audio title',
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: descriptionNode,
              label: 'Audio description, optional',
              isTextField: true,
            ),
            KeypadFocusTarget(
              node: cancelNode,
              label: 'Cancel upload',
              onActivate: () => Navigator.pop(dialogContext, false),
            ),
            KeypadFocusTarget(
              node: uploadNode,
              label: 'Upload audio',
              onActivate: () => Navigator.pop(dialogContext, true),
            ),
          ],
          child: AlertDialog(
            title: const Text('Upload Audio'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  focusNode: titleNode,
                  onTap: () => keypadController.enterTextEditing(titleNode),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  focusNode: descriptionNode,
                  onTap: () =>
                      keypadController.enterTextEditing(descriptionNode),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    keypadController.exitTextEditing();
                    cancelNode.requestFocus();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                focusNode: cancelNode,
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel (0)'),
              ),
              ElevatedButton(
                focusNode: uploadNode,
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Upload (3)'),
              ),
            ],
          ),
        ),
      );
      titleNode.dispose();
      descriptionNode.dispose();
      cancelNode.dispose();
      uploadNode.dispose();

      if (confirmed != true) return;

      setState(() => _isUploadingAudio = true);

      final title = titleController.text.trim().isNotEmpty
          ? titleController.text.trim()
          : file.name;
      final desc = descController.text.trim();
      final selectedSessionIds = <int>{
        if (widget.sessionId != 0) widget.sessionId,
      };

      if (widget.sessionId != 0 &&
          widget.isTeacher &&
          _teacherSessions.isNotEmpty) {
        final sessionNodes = <int, FocusNode>{
          for (final session in _teacherSessions)
            session['session_id'] as int: FocusNode(
              debugLabel: 'class-upload-session-${session['session_id']}',
            ),
        };
        final cancelSessionsNode = FocusNode(
          debugLabel: 'class-upload-sessions-cancel',
        );
        final confirmSessionsNode = FocusNode(
          debugLabel: 'class-upload-sessions-confirm',
        );
        if (!mounted) return;
        final confirmedSessions = await showDialog<bool>(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (context, setLocalState) {
              void toggle(int id) => setLocalState(() {
                if (!selectedSessionIds.remove(id)) selectedSessionIds.add(id);
              });
              return KeypadInstructionWrapper(
                screenName: 'Choose sessions for this audio',
                labels: const {0: 'Cancel', 1: 'Confirm Selected Sessions'},
                actions: {
                  0: () => Navigator.pop(ctx, false),
                  1: () => Navigator.pop(ctx, true),
                },
                focusTargets: [
                  for (final session in _teacherSessions)
                    KeypadFocusTarget(
                      node: sessionNodes[session['session_id']]!,
                      label:
                          '${session['title'] ?? 'Session ${session['session_id']}'}, '
                          '${selectedSessionIds.contains(session['session_id']) ? 'selected' : 'not selected'}',
                      onActivate: () => toggle(session['session_id'] as int),
                    ),
                  KeypadFocusTarget(
                    node: cancelSessionsNode,
                    label: 'Cancel',
                    onActivate: () => Navigator.pop(ctx, false),
                  ),
                  KeypadFocusTarget(
                    node: confirmSessionsNode,
                    label:
                        'Confirm ${selectedSessionIds.length} selected sessions',
                    onActivate: () => Navigator.pop(ctx, true),
                  ),
                ],
                child: AlertDialog(
                  scrollable: true,
                  title: const Text('Add audio to sessions'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _teacherSessions.map((session) {
                      final id = session['session_id'] as int;
                      final title =
                          session['title']?.toString() ?? 'Session $id';
                      return CheckboxListTile(
                        focusNode: sessionNodes[id],
                        value: selectedSessionIds.contains(id),
                        title: Text(title),
                        subtitle: Text('Session number $id'),
                        onChanged: (_) => toggle(id),
                      );
                    }).toList(),
                  ),
                  actions: [
                    TextButton(
                      focusNode: cancelSessionsNode,
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('0: Cancel'),
                    ),
                    ElevatedButton(
                      focusNode: confirmSessionsNode,
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('1: Confirm'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        for (final node in [
          ...sessionNodes.values,
          cancelSessionsNode,
          confirmSessionsNode,
        ]) {
          node.dispose();
        }
        if (confirmedSessions != true || selectedSessionIds.isEmpty) {
          _showError(
            'Upload cancelled. Select at least one session, then press 3 to add audio again.',
          );
          return;
        }
      }
      await _setLibraryStatus(
        'Uploading $title. Please wait; you will hear when it finishes.',
      );

      Map<String, dynamic>? uploadResult;
      final currentSession = _teacherSessions
          .cast<Map<String, dynamic>?>()
          .firstWhere(
            (session) => session?['session_id'] == widget.sessionId,
            orElse: () => null,
          );
      final classId = currentSession?['class_id'] as int? ?? widget.classId;
      final subjectId =
          currentSession?['subject_id'] as int? ?? widget.subjectId;
      if (classId == null || subjectId == null) {
        _showError('The session class and subject could not be determined');
        return;
      }

      if (file.bytes != null) {
        uploadResult = await ApiService.uploadAudioBytes(
          fileBytes: file.bytes!,
          filename: file.name,
          title: title,
          description: desc,
          sessionIds: selectedSessionIds.toList(),
          classId: classId,
          subjectId: subjectId,
        );
      } else if (file.path != null) {
        uploadResult = await ApiService.uploadAudio(
          filePath: file.path!,
          title: title,
          description: desc,
          sessionIds: selectedSessionIds.toList(),
          classId: classId,
          subjectId: subjectId,
        );
      }

      if (uploadResult != null) {
        await _setLibraryStatus('$title uploaded.');
        _loadAudioFiles(); // Refresh the list
      } else {
        _showError(
          '$title could not be uploaded. Check your connection, then press 3 to try again.',
        );
      }
    } catch (e) {
      print('[UPLOAD] Error: $e');
      _showError(
        ApiService.mapFailure(error: e, context: 'audio upload').message,
      );
    } finally {
      if (mounted) setState(() => _isUploadingAudio = false);
    }
  }

  /// Keypad helper: toggle play/pause on the currently playing audio,
  /// or start playing the first file if nothing is playing.
  void _togglePlayPause() {
    if (_playingAudioId != null) {
      _playOrPauseAudio(_playingAudioId!, _playingAudioTitle ?? 'Audio');
    } else if (_audioFiles.isNotEmpty) {
      final first = _audioFiles.first;
      final id = first['audio_id'] ?? first['id'] ?? 0;
      final title = first['title'] ?? 'Untitled';
      _playOrPauseAudio(id, title);
    }
  }

  void _handleAddAudio() {
    if (widget.sessionId == 0) {
      _uploadAudio();
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: AddAudioOptionsScreen(
            sessionId: widget.sessionId,
            onUploadNew: () {
              Navigator.pop(context); // Close Dialog
              _uploadAudio(); // Start normal upload
            },
            onAddExisting: () {
              Navigator.pop(context); // Close Dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectExistingAudioScreen(
                    sessionId: widget.sessionId,
                    classId: widget.classId,
                    subjectId: widget.subjectId,
                    currentAudioIds: _audioFiles
                        .map((e) => (e['audio_id'] ?? e['id']) as int)
                        .toSet(),
                    onAudioAdded: () {
                      _loadAudioFiles();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TtsService.unregisterRecordedPlayback(_audioPlayer);
    _learning.removeListener(_learningChanged);
    _learning.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _subjectFilterFocusNode.dispose();
    for (final node in [..._controlNodes.values, ..._audioNodes.values]) {
      node.dispose();
    }
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    final bool compact = tiny || UIUtils.isShort(context);

    // Role-aware key mappings; must match the labels map exactly.
    final labels = widget.isTeacher
        ? classAudioTeacherKeyLabels
        : classAudioStudentKeyLabels;

    final actions = <int, VoidCallback>{
      1: _loadAudioFiles,
      2: _cycleSubjectFilter,
      if (widget.isTeacher) 3: _handleAddAudio,
      playerRewindKey: () => _seekBy(-10),
      playerPlayPauseKey: _togglePlayPause,
      playerForwardKey: () => _seekBy(10),
      playerSlowerKey: () => _changeSpeed(-0.25),
      8: _stopAudio,
      playerFasterKey: () => _changeSpeed(0.25),
      0: () {
        _stopAudio();
        Navigator.of(context).pop();
      },
    };
    final textStyle = TextStyle(
      color: UIUtils.textColor,
      fontSize: UIUtils.fontSize(context, 16),
    );

    return KeypadInstructionWrapper(
      screenName: 'Class Audio Library',
      navigationSections:
          'playback controls, bookmarks and learning progress, subject filter, downloads, recordings, and teacher upload tools when available',
      labels: labels,
      actions: actions,
      focusTargets: _focusTargets,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            focusNode: _controlNode('back'),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.sessionTitle,
                style: TextStyle(
                  fontSize: UIUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!tiny)
                Text(
                  'Audio Library, session ${widget.sessionId}',
                  style: TextStyle(
                    fontSize: UIUtils.fontSize(context, 14),
                    color: UIUtils.subtextColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          backgroundColor: UIUtils.cardColor,
          foregroundColor: UIUtils.textColor,
          elevation: 0,
          toolbarHeight: tiny ? 48 : 56,
          actions: [
            IconButton(
              focusNode: _controlNode('refresh'),
              icon: Icon(
                Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 24),
                color: UIUtils.accentColor,
              ),
              tooltip: 'Refresh audio files',
              onPressed: _loadAudioFiles,
            ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        // Upload button for teachers only
        floatingActionButton: widget.isTeacher
            ? compact
                  ? FloatingActionButton(
                      focusNode: _controlNode('upload'),
                      onPressed: _isUploadingAudio ? null : _handleAddAudio,
                      backgroundColor: UIUtils.accentColor,
                      foregroundColor: UIUtils.onAccentColor,
                      tooltip: _isUploadingAudio
                          ? 'Uploading audio'
                          : 'Add audio, key 3',
                      child: _isUploadingAudio
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: UIUtils.onAccentColor,
                              ),
                            )
                          : const Icon(Icons.upload_file_rounded),
                    )
                  : FloatingActionButton.extended(
                      focusNode: _controlNode('upload'),
                      onPressed: _isUploadingAudio ? null : _handleAddAudio,
                      icon: _isUploadingAudio
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: UIUtils.onAccentColor,
                              ),
                            )
                          : const Icon(Icons.upload_file_rounded),
                      label: Text(
                        _isUploadingAudio ? 'Uploading' : '3: Add audio',
                      ),
                      backgroundColor: UIUtils.accentColor,
                      foregroundColor: UIUtils.onAccentColor,
                    )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_libraryStatus != null)
                      Padding(
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _libraryStatus!,
                            style: textStyle.copyWith(
                              color: _libraryError
                                  ? UIUtils.errorColor
                                  : UIUtils.textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // ── Now-Playing bar ─────────────────────────────────
                    if (_playingAudioId != null) ...[
                      _buildNowPlayingBar(),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: _learningControls,
                      ),
                    ] else
                      Padding(
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 12,
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _playbackStatus == 'Stopped'
                                ? 'Nothing playing. Select a lesson or press 5.'
                                : _playbackStatus,
                            style: textStyle,
                          ),
                        ),
                      ),

                    // ── Upload progress ─────────────────────────────────
                    if (_isUploadingAudio)
                      LinearProgressIndicator(
                        color: UIUtils.accentColor,
                        backgroundColor: UIUtils.cardBorderColor,
                        minHeight: 4,
                      ),

                    if (widget.subjectId == null &&
                        _availableSubjects.isNotEmpty)
                      Padding(
                        padding: UIUtils.paddingSymmetric(
                          context,
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: DropdownButtonFormField<int?>(
                          key: ValueKey(_selectedSubjectId),
                          focusNode: _subjectFilterFocusNode,
                          initialValue: _selectedSubjectId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Subject filter (key 2)',
                            prefixIcon: Icon(Icons.menu_book_outlined),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All subjects'),
                            ),
                            ..._availableSubjects.map(
                              (subject) => DropdownMenuItem<int?>(
                                value: subject['subject_id'] as int,
                                child: Text('${subject['subject_name']}'),
                              ),
                            ),
                          ],
                          onChanged: _selectSubject,
                        ),
                      ),

                    // ── Header ──────────────────────────────────────────
                    Padding(
                      padding: UIUtils.paddingAll(context, compact ? 8 : 12),
                      child: Semantics(
                        header: true,
                        child: Text(
                          '${_audioFiles.length} recordings',
                          style: textStyle.copyWith(
                            fontSize: UIUtils.fontSize(context, 18),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    Wrap(
                      children: [
                        if (!widget.downloadedOnly)
                          TextButton(
                            focusNode: _controlNode('downloads'),
                            onPressed: _openDownloads,
                            child: const Text('Download lessons'),
                          ),
                        TextButton(
                          focusNode: _controlNode('stop-speech'),
                          onPressed: TtsService.stop,
                          child: const Text('Stop speech'),
                        ),
                        TextButton(
                          focusNode: _controlNode('repeat-help'),
                          onPressed: _repeatHelp,
                          child: const Text('Repeat help'),
                        ),
                      ],
                    ),
                    // ── Audio list ──────────────────────────────────────
                    if (_audioFiles.isEmpty)
                      Padding(
                        padding: UIUtils.paddingAll(context, compact ? 8 : 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isTeacher
                                  ? 'No recordings for this class yet.'
                                  : 'No recordings available yet. Ask your teacher to upload some.',
                              textAlign: TextAlign.center,
                              style: textStyle,
                            ),
                            if (widget.isTeacher) ...[
                              SizedBox(height: UIUtils.spacing(context, 10)),
                              ElevatedButton.icon(
                                focusNode: _controlNode('upload-empty'),
                                onPressed: _uploadAudio,
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('Upload first audio'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: UIUtils.accentColor,
                                  foregroundColor: UIUtils.onAccentColor,
                                ),
                              ),
                            ],
                            SizedBox(height: UIUtils.spacing(context, 6)),
                            TextButton.icon(
                              focusNode: _controlNode('empty-retry'),
                              onPressed: _loadAudioFiles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: UIUtils.paddingAll(context, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (
                              var index = 0;
                              index < _audioFiles.length;
                              index++
                            )
                              _audioTile(index, tiny),
                          ],
                        ),
                      ),
                    // Leave room so the floating upload button never covers
                    // the last recording.
                    if (widget.isTeacher) const SizedBox(height: 72),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _audioTile(int index, bool tiny) {
    final audio = _audioFiles[index];
    final audioId = _idOf(audio);
    final title = '${audio['title'] ?? 'Untitled'}';
    final description = '${audio['description'] ?? ''}';
    final duration = audio['duration'] is num
        ? (audio['duration'] as num).toDouble()
        : null;
    final status = _audioStatus(audioId);
    return AccessibleTile(
      focusNode: _audioNode(audioId),
      leadingIcon: status == 'Playing'
          ? Icons.pause_circle_filled
          : Icons.play_circle_fill,
      title: title,
      status: status,
      selected: status != null,
      semanticLabel: _audioLabel(index),
      subtitle: [
        '${audio['class_name'] ?? 'Class'}, ${audio['subject_name'] ?? 'Subject'}',
        if (duration != null) 'Length ${_formatDuration(duration)}',
        if (description.isNotEmpty && !tiny) description,
      ].join('. '),
      onActivate: () => _playOrPauseAudio(audioId, title),
    );
  }

  /// Now-playing panel: status, seek bar, then transport keys laid out like
  /// the keypad (4 5 6 above 7 8 9).
  Widget _buildNowPlayingBar() {
    final stacked = UIUtils.isTiny(context) || UIUtils.useStackedLayout(context);
    final title = _playingAudioTitle ?? 'Audio';
    final textStyle = TextStyle(
      color: UIUtils.textColor,
      fontSize: UIUtils.fontSize(context, 16),
    );

    Widget control({
      required String node,
      required int key,
      required IconData icon,
      required String text,
      required String semantics,
      required VoidCallback? onPressed,
      bool primary = false,
    }) {
      final style = primary
          ? FilledButton.styleFrom(
              backgroundColor: UIUtils.accentColor,
              foregroundColor: UIUtils.onAccentColor,
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            )
          : OutlinedButton.styleFrom(
              foregroundColor: UIUtils.textColor,
              side: BorderSide(color: UIUtils.cardBorderColor, width: 1.5),
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            );
      final label = Text(
        '$key $text',
        semanticsLabel: semantics,
        textAlign: TextAlign.center,
      );
      return primary
          ? FilledButton.icon(
              focusNode: _controlNode(node),
              style: style,
              onPressed: onPressed,
              icon: Icon(icon),
              label: label,
            )
          : OutlinedButton.icon(
              focusNode: _controlNode(node),
              style: style,
              onPressed: onPressed,
              icon: Icon(icon),
              label: label,
            );
    }

    final focus = _focusTargets;
    String labelOf(String node) => focus
        .firstWhere((target) => identical(target.node, _controlNode(node)))
        .label;
    final rows = <List<Widget>>[
      [
        control(
          node: 'rewind',
          key: playerRewindKey,
          icon: Icons.replay_10,
          text: 'Back 10 s',
          semantics: labelOf('rewind'),
          onPressed: () => _seekBy(-10),
        ),
        control(
          node: 'play',
          key: playerPlayPauseKey,
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          text: _isPlaying ? 'Pause' : 'Play',
          semantics: labelOf('play'),
          onPressed: _togglePlayPause,
          primary: true,
        ),
        control(
          node: 'forward',
          key: playerForwardKey,
          icon: Icons.forward_10,
          text: 'Forward 10 s',
          semantics: labelOf('forward'),
          onPressed: () => _seekBy(10),
        ),
      ],
      [
        control(
          node: 'slower',
          key: playerSlowerKey,
          icon: Icons.remove,
          text: 'Slower',
          semantics: labelOf('slower'),
          onPressed: _audioSpeed > 0.25 ? () => _changeSpeed(-0.25) : null,
        ),
        control(
          node: 'stop',
          key: 8,
          icon: Icons.stop,
          text: 'Stop',
          semantics: labelOf('stop'),
          onPressed: _stopAudio,
        ),
        control(
          node: 'faster',
          key: playerFasterKey,
          icon: Icons.add,
          text: 'Faster',
          semantics: labelOf('faster'),
          onPressed: _audioSpeed < 3.0 ? () => _changeSpeed(0.25) : null,
        ),
      ],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: UIUtils.cardColor,
        border: Border.all(color: UIUtils.accentColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              _playbackStatus,
              style: textStyle.copyWith(
                fontSize: UIUtils.fontSize(context, 18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ExcludeSemantics(
            child: Text(
              '${_formatDuration(_currentPosition)} of '
              '${_totalDuration != null ? _formatDuration(_totalDuration!) : '--:--'}. '
              'Speed ${learningSpeedNumber(_audioSpeed)}x',
              style: textStyle.copyWith(color: UIUtils.subtextColor),
            ),
          ),
          PlayerSeekBar(
            focusNode: _controlNode('seek'),
            position: _position,
            duration: _duration,
            onPreview: (value) => setState(
              () => _currentPosition = value.inMilliseconds / 1000,
            ),
            onSeek: (value) => _seekTo(value.inMilliseconds / 1000),
          ),
          if (stacked)
            for (final button in rows.expand((row) => row))
              Padding(padding: const EdgeInsets.only(top: 6), child: button)
          else
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    for (var i = 0; i < row.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(child: row[i]),
                    ],
                  ],
                ),
              ),
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Now playing: $title',
                style: textStyle.copyWith(color: UIUtils.subtextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddAudioOptionsScreen extends StatefulWidget {
  final int sessionId;
  final VoidCallback onUploadNew;
  final VoidCallback onAddExisting;

  const AddAudioOptionsScreen({
    super.key,
    required this.sessionId,
    required this.onUploadNew,
    required this.onAddExisting,
  });

  @override
  State<AddAudioOptionsScreen> createState() => _AddAudioOptionsScreenState();
}

class _AddAudioOptionsScreenState extends State<AddAudioOptionsScreen> {
  final _closeNode = FocusNode(debugLabel: 'add-audio-close');
  final _uploadNode = FocusNode(debugLabel: 'add-audio-upload');
  final _existingNode = FocusNode(debugLabel: 'add-audio-existing');

  @override
  void dispose() {
    _closeNode.dispose();
    _uploadNode.dispose();
    _existingNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: UIUtils.textColor,
      fontSize: UIUtils.fontSize(context, 16),
      fontWeight: FontWeight.w600,
    );
    return KeypadInstructionWrapper(
      screenName: 'Add Audio Options',
      labels: addAudioOptionsKeyLabels,
      actions: {
        1: widget.onUploadNew,
        2: widget.onAddExisting,
        0: () => Navigator.of(context).pop(),
      },
      focusTargets: [
        KeypadFocusTarget(
          node: _closeNode,
          label: 'Close add audio options',
          onActivate: () => Navigator.of(context).pop(),
        ),
        KeypadFocusTarget(
          node: _uploadNode,
          label: 'Upload new file, key 1',
          onActivate: widget.onUploadNew,
        ),
        KeypadFocusTarget(
          node: _existingNode,
          label: 'Select from existing library, key 2',
          onActivate: widget.onAddExisting,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: UIUtils.primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Add Audio',
                        style: TextStyle(
                          color: UIUtils.onPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    focusNode: _closeNode,
                    tooltip: 'Close add audio options',
                    icon: Icon(Icons.close, color: UIUtils.onPrimaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AccessibleTile(
                    focusNode: _uploadNode,
                    leadingIcon: Icons.upload_file,
                    title: '1: Upload New File',
                    semanticLabel: 'Upload new file, key 1',
                    onActivate: widget.onUploadNew,
                  ),
                  AccessibleTile(
                    focusNode: _existingNode,
                    leadingIcon: Icons.library_music,
                    title: '2: Select from Existing Library',
                    semanticLabel: 'Select from existing library, key 2',
                    onActivate: widget.onAddExisting,
                  ),
                  Text('0: Cancel', style: textStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectExistingAudioScreen extends StatefulWidget {
  final int sessionId;
  final int? classId;
  final int? subjectId;
  final Set<int> currentAudioIds;
  final VoidCallback onAudioAdded;

  const SelectExistingAudioScreen({
    super.key,
    required this.sessionId,
    this.classId,
    this.subjectId,
    required this.currentAudioIds,
    required this.onAudioAdded,
  });

  @override
  State<SelectExistingAudioScreen> createState() =>
      _SelectExistingAudioScreenState();
}

class _SelectExistingAudioScreenState extends State<SelectExistingAudioScreen> {
  final Map<int, FocusNode> _itemNodes = {};
  final _backNode = FocusNode(debugLabel: 'existing-audio-back');
  final _refreshNode = FocusNode(debugLabel: 'existing-audio-refresh');
  final _searchNode = FocusNode(debugLabel: 'existing-audio-search');
  final _searchController = TextEditingController();
  final _navigation = KeypadNavigationController();

  FocusNode _itemNode(int id) => _itemNodes.putIfAbsent(
    id,
    () => FocusNode(debugLabel: 'existing-audio-$id'),
  );
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableAudio = [];
  bool _linking = false;
  String? _status;
  bool _statusIsError = false;
  String _query = '';

  int _idOf(Map<String, dynamic> audio) =>
      (audio['audio_id'] ?? audio['id']) as int;

  List<Map<String, dynamic>> get _visibleAudio {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _availableAudio;
    return _availableAudio
        .where(
          (audio) =>
              '${audio['title'] ?? ''} ${audio['description'] ?? ''}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_queryChanged);
    _loadAvailableAudio();
  }

  void _queryChanged() {
    if (_searchController.text == _query) return;
    setState(() => _query = _searchController.text);
  }

  void _announce(String message, {bool error = false, SpeechPriority? priority}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = error;
    });
    TtsService.speak(
      message,
      priority:
          priority ??
          (error ? SpeechPriority.critical : SpeechPriority.requested),
    );
  }

  void _announceMatches() {
    final count = _visibleAudio.length;
    _announce(
      _query.trim().isEmpty
          ? '$count recordings available.'
          : count == 0
          ? 'No recordings match ${_query.trim()}.'
          : '$count recordings match ${_query.trim()}.',
    );
  }

  Future<void> _loadAvailableAudio() async {
    final firstLoad = _status == null;
    setState(() => _isLoading = true);
    final allAudio = await ApiService.getAudioList();
    if (allAudio != null && mounted) {
      int? classId = widget.classId;
      int? subjectId = widget.subjectId;
      if (classId == null || subjectId == null) {
        final state = await ApiService.get(
          '/sessions/${widget.sessionId}/state',
          useAuth: true,
        );
        if (state is Map) {
          classId = int.tryParse('${state['class_id']}');
          subjectId = int.tryParse('${state['subject_id']}');
        }
      }
      if (!mounted) return;
      final available = allAudio
          .where((audio) {
            final id = (audio['audio_id'] ?? audio['id']) as int;
            return !widget.currentAudioIds.contains(id) &&
                audio['class_id'] == classId &&
                audio['subject_id'] == subjectId;
          })
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      setState(() {
        _availableAudio = available;
        _isLoading = false;
      });
      _announce(
        available.isEmpty
            ? 'No unlinked recordings available for this class.'
            : '${available.length} recordings available. Use up and down to choose, or search by title.',
        priority: firstLoad ? SpeechPriority.incidental : null,
      );
    } else {
      if (mounted) setState(() => _isLoading = false);
      _announce(
        'Could not load recordings. Check your internet connection, then press 1 to retry.',
        error: true,
      );
    }
  }

  Future<void> _linkAudio(int audioId, String title) async {
    if (_linking) return;
    setState(() => _linking = true);
    final result = await ApiService.linkAudioToSession(
      widget.sessionId,
      audioId,
    );
    if (!mounted) return;
    setState(() => _linking = false);

    if (result != null) {
      widget.onAudioAdded();
      Navigator.of(context).pop();
      TtsService.speak('$title added to this session.');
    } else {
      _announce(
        'Could not add $title. Check your connection and try again.',
        error: true,
      );
    }
  }

  @override
  void dispose() {
    _backNode.dispose();
    _refreshNode.dispose();
    _searchNode.dispose();
    _searchController.dispose();
    for (final node in _itemNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleAudio;
    final textStyle = TextStyle(
      color: UIUtils.textColor,
      fontSize: UIUtils.fontSize(context, 16),
    );
    return KeypadInstructionWrapper(
      screenName: 'Select Existing Audio',
      navigationSections: 'search and every available recording',
      labels: selectExistingAudioKeyLabels,
      actions: {
        1: _loadAvailableAudio,
        0: () => Navigator.of(context).pop(),
      },
      navigationController: _navigation,
      focusTargets: [
        KeypadFocusTarget(
          node: _backNode,
          label: 'Back',
          onActivate: () => Navigator.of(context).maybePop(),
        ),
        KeypadFocusTarget(
          node: _refreshNode,
          label: 'Refresh available audio, key 1',
          onActivate: _loadAvailableAudio,
          isEnabled: () => !_linking,
        ),
        KeypadFocusTarget(
          node: _searchNode,
          label: _query.isEmpty
              ? 'Search recordings by title. Press OK to type'
              : 'Search recordings, $_query. ${visible.length} matches',
          isTextField: true,
        ),
        for (final audio in visible)
          KeypadFocusTarget(
            node: _itemNode(_idOf(audio)),
            label: 'Add ${audio['title'] ?? 'Untitled'} to this session',
            onActivate: () =>
                _linkAudio(_idOf(audio), '${audio['title'] ?? 'Untitled'}'),
            isEnabled: () => !_linking,
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Audio'),
          leading: IconButton(
            focusNode: _backNode,
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            IconButton(
              focusNode: _refreshNode,
              tooltip: 'Refresh available audio',
              icon: const Icon(Icons.refresh),
              onPressed: _linking ? null : _loadAvailableAudio,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: UIUtils.paddingAll(context, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_status != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _status!,
                          style: textStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _statusIsError
                                ? UIUtils.errorColor
                                : UIUtils.textColor,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchNode,
                        onTap: () => _navigation.enterTextEditing(_searchNode),
                        onSubmitted: (_) {
                          _navigation.exitTextEditing();
                          _announceMatches();
                        },
                        style: textStyle,
                        decoration: InputDecoration(
                          labelText: 'Search by title',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: UIUtils.cardBorderColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _query.trim().isEmpty
                          ? '${visible.length} recordings'
                          : '${visible.length} of ${_availableAudio.length} recordings match',
                      style: textStyle,
                    ),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _availableAudio.isEmpty
                              ? 'No unlinked audio available.'
                              : 'No recordings match your search.',
                          style: textStyle,
                        ),
                      ),
                    for (final audio in visible)
                      AccessibleTile(
                        focusNode: _itemNode(_idOf(audio)),
                        leadingIcon: Icons.library_add,
                        title: '${audio['title'] ?? 'Untitled'}',
                        semanticLabel:
                            'Add ${audio['title'] ?? 'Untitled'} to this session',
                        subtitle: '${audio['description'] ?? ''}',
                        onActivate: _linking
                            ? null
                            : () => _linkAudio(
                                _idOf(audio),
                                '${audio['title'] ?? 'Untitled'}',
                              ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
