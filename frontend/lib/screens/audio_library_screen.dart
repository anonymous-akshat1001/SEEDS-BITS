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
      label: 'Refresh audio files',
      onActivate: _loadAudioFiles,
    ),
    KeypadFocusTarget(
      node: _focusNode('tts'),
      label: _ttsEnabled ? 'Turn speech off' : 'Turn speech on',
      onActivate: _toggleTts,
    ),
    if (widget.sessionId != null)
      KeypadFocusTarget(
        node: _focusNode('pause-session'),
        label: 'Pause audio for the session',
        onActivate: _pauseSessionAudio,
      ),
    KeypadFocusTarget(
      node: _focusNode('upload'),
      label: 'Upload audio',
      onActivate: _uploadAudioFile,
      isEnabled: () => !_isUploading,
    ),
    for (var index = 0; index < _audioFiles.length; index++) ...[
      KeypadFocusTarget(
        node: _focusNode(
          'preview-${_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']}',
        ),
        label:
            'Preview ${_audioFiles[index]['title']} privately. '
            'Only you can hear this. Item ${index + 1} of ${_audioFiles.length}. '
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
  // global TTS toggle for this screen
  bool _ttsEnabled = true;

  // Controllers for upload dialog input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _toggleTts() {
    setState(() => _ttsEnabled = !TtsService.isEnabled);
    TtsService.configure(enabled: _ttsEnabled);
    if (_ttsEnabled) {
      _speakIfEnabled('Text to speech enabled');
    } else {
      TtsService.stop();
    }
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

      _speakIfEnabled("Playback finished");
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

        await _speakIfEnabled("Loaded ${_audioFiles.length} audio files");
      }
    } catch (e) {
      print('[AUDIO LIBRARY] Error loading files: $e');
      _showError("Failed to load audio files");
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
                  foregroundColor: Colors.white,
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
    await _speakIfEnabled("Uploading audio file");

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

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _speakIfEnabled("Upload successful");
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

  // Local Audio Preview
  Future<void> _playAudioLocally(int audioId, String title) async {
    try {
      if (_playingAudioId == audioId) {
        await _audioPlayer.stop();
        setState(() => _playingAudioId = null);
        await _speakIfEnabled("Stopped playback");
        return;
      }

      await _audioPlayer.stop();
      // Backend streaming endpoint
      final url = await ApiService.mediaUrl('/audio/$audioId/stream');
      // Streams audio directly from backend
      await _audioPlayer.play(UrlSource(url));
      // updates UI state
      setState(() => _playingAudioId = audioId);
      await _speakIfEnabled("Playing $title");
    } catch (e) {
      print('[PLAY] Error: $e');
      _showError("Failed to play audio");
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

  // Shows error which has occured visually
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    _speakIfEnabled(message);
  }

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
      onSpeechRescued: () => setState(() => _ttsEnabled = TtsService.isEnabled),
      labels: {
        0: 'Back',
        1: 'Refresh Audio Files',
        2: 'Upload Audio',
        3: 'Toggle Text to Speech',
        if (widget.sessionId != null) 4: 'Pause Session Audio',
      },
      actions: {
        0: () => Navigator.pop(context),
        1: _loadAudioFiles,
        2: _uploadAudioFile,
        3: _toggleTts,
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
            IconButton(
              focusNode: _focusNode('tts'),
              icon: Icon(
                _ttsEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor,
              ),
              tooltip: _ttsEnabled
                  ? 'Turn text-to-speech off'
                  : 'Turn text-to-speech on',
              onPressed: _toggleTts,
            ),
            if (widget.sessionId != null)
              IconButton(
                focusNode: _focusNode('pause-session'),
                icon: Icon(
                  Icons.pause_rounded,
                  size: UIUtils.iconSize(context, 20),
                  color: Colors.orange,
                ),
                tooltip: 'Pause Session Audio',
                onPressed: _pauseSessionAudio,
              ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_isUploading) const LinearProgressIndicator(),

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
                        foregroundColor: Colors.white,
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
                      '${_audioFiles.length} Audio Files',
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
                              'No audio files yet.\nUpload some!',
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
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                color: isSelected
                                    ? UIUtils.accentColor.withOpacity(0.12)
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
                                                ? Colors.green
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
                                                          'SELECTED',
                                                          style: TextStyle(
                                                            color: Colors.white,
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
                                                style: TextStyle(
                                                  fontSize: UIUtils.fontSize(
                                                    context,
                                                    compact ? 11 : 12,
                                                  ),
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isPlaying
                                                    ? Colors.orange
                                                    : Colors.indigo,
                                                foregroundColor: Colors.white,
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
                                                  style: TextStyle(
                                                    fontSize: UIUtils.fontSize(
                                                      context,
                                                      compact ? 11 : 12,
                                                    ),
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isSelected
                                                      ? UIUtils.primaryColor
                                                      : Colors.green,
                                                  foregroundColor: Colors.white,
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

  FocusNode _focusNode(String name) => _focusNodes.putIfAbsent(
    name,
    () => FocusNode(debugLabel: 'recorded-library-$name'),
  );

  List<KeypadFocusTarget> get _focusTargets => [
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
      ).showSnackBar(SnackBar(content: Text(message)));
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
      final result = await ApiService.getActiveSessions();
      if (result != null && mounted) {
        setState(() {
          _sessions = result
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      }
    } catch (e) {
      print('[OFFLINE LIB] Error loading sessions: $e');
    } finally {
      if (mounted)
        setState(() {
          _sessionsLoaded = true;
          _isLoading =
              !_userInfoLoaded; // hide spinner only if user info is also done
        });
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
        const SnackBar(content: Text('No class found with this session name')),
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
                        color: UIUtils.accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: UIUtils.accentColor.withOpacity(0.2),
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
                              : Colors.grey.withOpacity(0.15),
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
                                        color: Colors.grey.shade300,
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
                                  foregroundColor: Colors.white,
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
                      color: UIUtils.accentColor.withOpacity(0.08),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: UIUtils.accentColor.withOpacity(0.3),
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
                                  color: UIUtils.accentColor.withOpacity(0.15),
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
                                  : Colors.grey.withOpacity(0.12),
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
                                      color: UIUtils.accentColor.withOpacity(
                                        0.1,
                                      ),
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
  bool _ttsEnabled = true;
  int? _resolvedTeacherId;
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

  String _audioLabel(int index) {
    final audio = _audioFiles[index];
    return '${audio['title'] ?? 'Untitled'}. '
        '${audio['subject_name'] ?? 'Subject'}. '
        'Lesson ${index + 1} of ${_audioFiles.length}. '
        '${audio['description'] ?? ''}';
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

  List<KeypadFocusTarget> get _focusTargets => [
    if (!widget.downloadedOnly)
      KeypadFocusTarget(
        node: _controlNode('downloads'),
        label: 'Download lessons or manage saved recordings',
        onActivate: _openDownloads,
      ),
    KeypadFocusTarget(
      node: _controlNode('back'),
      label: 'Back',
      onActivate: () => Navigator.of(context).maybePop(),
    ),
    KeypadFocusTarget(
      node: _controlNode('tts'),
      label: _ttsEnabled ? 'Turn speech off' : 'Turn speech on',
      onActivate: _toggleTts,
    ),
    KeypadFocusTarget(
      node: _controlNode('refresh'),
      label: 'Refresh audio files',
      onActivate: _loadAudioFiles,
    ),
    if (widget.isTeacher)
      KeypadFocusTarget(
        node: _controlNode('upload'),
        label: 'Add audio',
        onActivate: _handleAddAudio,
        isEnabled: () => !_isUploadingAudio,
      ),
    if (widget.subjectId == null && _availableSubjects.isNotEmpty)
      KeypadFocusTarget(
        node: _subjectFilterFocusNode,
        label:
            'Subject filter. Use left or right to change the selected subject',
        onActivate: _cycleSubjectFilter,
        onDecrease: () => _cycleSubjectFilter(-1),
        onIncrease: _cycleSubjectFilter,
      ),
    if (_playingAudioId != null) ...[
      KeypadFocusTarget(
        node: _controlNode('seek'),
        label:
            'Audio position ${_formatDuration(_currentPosition)}. '
            'Use left or right to seek ten seconds.',
        onDecrease: () =>
            _seekTo((_currentPosition - 10).clamp(0.0, _totalDuration ?? 0.0)),
        onIncrease: () =>
            _seekTo((_currentPosition + 10).clamp(0.0, _totalDuration ?? 0.0)),
        isEnabled: () => _totalDuration != null,
      ),
      KeypadFocusTarget(
        node: _controlNode('slower'),
        label: 'Slower playback',
        onActivate: () => _changeSpeed(-0.25),
        isEnabled: () => _audioSpeed > 0.25,
      ),
      KeypadFocusTarget(
        node: _controlNode('rewind'),
        label: 'Back ten seconds',
        onActivate: () =>
            _seekTo((_currentPosition - 10).clamp(0.0, _totalDuration ?? 0.0)),
      ),
      KeypadFocusTarget(
        node: _controlNode('play'),
        label: _isPlaying ? 'Pause lesson' : 'Resume lesson',
        onActivate: _togglePlayPause,
      ),
      KeypadFocusTarget(
        node: _controlNode('forward'),
        label: 'Forward ten seconds',
        onActivate: () =>
            _seekTo((_currentPosition + 10).clamp(0.0, _totalDuration ?? 0.0)),
      ),
      KeypadFocusTarget(
        node: _controlNode('faster'),
        label: 'Faster playback',
        onActivate: () => _changeSpeed(0.25),
        isEnabled: () => _audioSpeed < 3.0,
      ),
      ..._learningControls.focusTargets(context),
    ],
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
        node: _audioNode(
          (_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']) as int,
        ),
        label: _audioLabel(index),
        onActivate: () => _playOrPauseAudio(
          (_audioFiles[index]['audio_id'] ?? _audioFiles[index]['id']) as int,
          '${_audioFiles[index]['title'] ?? 'Untitled'}',
        ),
      ),
    if (_playingAudioId != null)
      KeypadFocusTarget(
        node: _controlNode('stop'),
        label: 'Stop lesson',
        onActivate: _stopAudio,
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
  ];

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
        setState(() {
          _isPlaying = false;
          _currentPosition = 0;
          _playingAudioId = null;
          _playingAudioTitle = null;
        });
        _speakIfEnabled("Playback finished");
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not load audio files. Check network & login.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
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
        await _speakIfEnabled(
          "Found ${_audioFiles.length} audio files for ${widget.sessionTitle}",
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
      _showError(
        ApiService.mapFailure(error: e, context: 'audio list').message,
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
          setState(() => _isPlaying = false);
          await _learning.flush();
          await _speakIfEnabled("Paused");
        } else {
          await _audioPlayer.resume();
          if (!mounted || revision != _playRevision) return;
          setState(() => _isPlaying = true);
          await _speakIfEnabled("Resumed");
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
      _learning.activate();
      setState(() => _isPlaying = true);
      final duration = await _audioPlayer.getDuration();
      if (!mounted || revision != _playRevision) return;
      if (duration != null) _learning.updateDuration(duration);

      if (!widget.downloadedOnly) unawaited(_logListen(audioId, revision));

      await _speakIfEnabled("Playing $title");
    } catch (e) {
      debugPrint('[CLASS AUDIO PLAY] Playback failed (${e.runtimeType})');
      if (!mounted || revision != _playRevision) return;
      _learning.abort();
      _showError(
        e is OfflineLessonException ? e.message : "Failed to play audio",
      );
      setState(() {
        _isPlaying = false;
        _playingAudioId = null;
        _playingAudioTitle = null;
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
    });
    await _speakIfEnabled("Stopped");
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
    final newSpeed = (_audioSpeed + delta).clamp(0.25, 3.0);
    try {
      await _learning.changeSpeed(newSpeed);
      if (mounted) _speakIfEnabled("Speed ${newSpeed.toStringAsFixed(2)}x");
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

  void _toggleTts() {
    setState(() => _ttsEnabled = !TtsService.isEnabled);
    TtsService.configure(enabled: _ttsEnabled);
    if (_ttsEnabled) {
      _speakIfEnabled('Text to speech enabled');
    } else {
      TtsService.stop();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    _speakIfEnabled(message);
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
      await _speakIfEnabled("Uploading audio");

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
        final confirmedSessions = await showDialog<bool>(
          context: context,
          builder: (ctx) => KeypadInstructionWrapper(
            screenName: 'Choose sessions for this audio',
            labels: const {0: 'Cancel', 1: 'Confirm Selected Sessions'},
            actions: {
              0: () => Navigator.pop(ctx, false),
              1: () => Navigator.pop(ctx, true),
            },
            child: AlertDialog(
              title: const Text('Add audio to sessions'),
              content: StatefulBuilder(
                builder: (context, setLocalState) => SizedBox(
                  width: 360,
                  child: ListView(
                    shrinkWrap: true,
                    children: _teacherSessions.map((session) {
                      final id = session['session_id'] as int;
                      final title =
                          session['title']?.toString() ?? 'Session $id';
                      return CheckboxListTile(
                        value: selectedSessionIds.contains(id),
                        title: Text(title),
                        subtitle: Text('Session #$id'),
                        onChanged: (checked) {
                          setLocalState(() {
                            if (checked == true) {
                              selectedSessionIds.add(id);
                            } else {
                              selectedSessionIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        );
        if (confirmedSessions != true || selectedSessionIds.isEmpty) {
          _showError('Please select at least one session');
          return;
        }
      }

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
        await _speakIfEnabled("Upload complete");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAudioFiles(); // Refresh the list
      } else {
        _showError("Upload failed");
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

    // Role-aware key mappings
    final labels = widget.isTeacher
        ? classAudioTeacherKeyLabels
        : classAudioStudentKeyLabels;

    final actions = widget.isTeacher
        ? <int, VoidCallback>{
            1: _loadAudioFiles,
            2: _handleAddAudio,
            3: _togglePlayPause,
            4: _stopAudio,
            5: _toggleTts,
            6: _cycleSubjectFilter,
            7: () => _changeSpeed(-0.25),
            9: () => _changeSpeed(0.25),
            0: () {
              _stopAudio();
              Navigator.of(context).pop();
            },
          }
        : <int, VoidCallback>{
            1: _loadAudioFiles,
            2: _togglePlayPause,
            3: _stopAudio,
            4: _toggleTts,
            6: _cycleSubjectFilter,
            7: () => _changeSpeed(-0.25),
            9: () => _changeSpeed(0.25),
            0: () {
              _stopAudio();
              Navigator.of(context).pop();
            },
          };

    return KeypadInstructionWrapper(
      screenName: 'Class Audio Library',
      onSpeechRescued: () => setState(() => _ttsEnabled = TtsService.isEnabled),
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
              Text(
                'Audio Library • Session #${widget.sessionId}',
                style: TextStyle(
                  fontSize: UIUtils.fontSize(context, 11),
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
              focusNode: _controlNode('tts'),
              icon: Icon(
                _ttsEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor,
              ),
              tooltip: _ttsEnabled
                  ? 'Turn text-to-speech off'
                  : 'Turn text-to-speech on',
              onPressed: _toggleTts,
            ),
            IconButton(
              focusNode: _controlNode('refresh'),
              icon: Icon(
                Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor,
              ),
              tooltip: 'Refresh',
              onPressed: _loadAudioFiles,
            ),
          ],
        ),
        backgroundColor: UIUtils.backgroundColor,
        // Upload FAB for teachers only
        floatingActionButton: widget.isTeacher
            ? compact
                  ? FloatingActionButton(
                      focusNode: _controlNode('upload'),
                      onPressed: _isUploadingAudio ? null : _handleAddAudio,
                      backgroundColor: UIUtils.accentColor,
                      foregroundColor: Colors.white,
                      tooltip: _isUploadingAudio
                          ? 'Uploading audio'
                          : 'Upload Audio',
                      child: _isUploadingAudio
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_file_rounded),
                    )
                  : FloatingActionButton.extended(
                      focusNode: _controlNode('upload'),
                      onPressed: _isUploadingAudio ? null : _handleAddAudio,
                      icon: _isUploadingAudio
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_file_rounded),
                      label: Text(
                        _isUploadingAudio ? 'Uploading…' : 'Upload Audio',
                      ),
                      backgroundColor: UIUtils.accentColor,
                      foregroundColor: Colors.white,
                    )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Now-Playing bar ─────────────────────────────────
                    if (_playingAudioId != null)
                      Column(
                        children: [
                          _buildNowPlayingBar(),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: _learningControls,
                          ),
                        ],
                      ),

                    // ── Upload progress ─────────────────────────────────
                    if (_isUploadingAudio)
                      const LinearProgressIndicator(
                        color: Colors.teal,
                        minHeight: 3,
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
                            labelText: 'Subject filter (key 6)',
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
                      child: Row(
                        children: [
                          Icon(
                            Icons.audiotrack_rounded,
                            size: UIUtils.iconSize(context, 20),
                            color: UIUtils.accentColor,
                          ),
                          SizedBox(width: UIUtils.spacing(context, 6)),
                          Expanded(
                            child: Text(
                              '${_audioFiles.length} Audio Files',
                              style: TextStyle(
                                fontSize: UIUtils.fontSize(
                                  context,
                                  compact ? 13 : 15,
                                ),
                                fontWeight: FontWeight.w700,
                                color: UIUtils.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                    Padding(
                      padding: EdgeInsets.zero,
                      child: _audioFiles.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                padding: UIUtils.paddingAll(
                                  context,
                                  compact ? 8 : 16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.audiotrack_rounded,
                                      size: UIUtils.iconSize(
                                        context,
                                        compact ? 36 : 52,
                                      ),
                                      color: UIUtils.subtextColor,
                                    ),
                                    SizedBox(
                                      height: UIUtils.spacing(
                                        context,
                                        compact ? 6 : 10,
                                      ),
                                    ),
                                    Text(
                                      widget.isTeacher
                                          ? 'No audio files for this class yet.'
                                          : 'No audio files available yet.\nAsk your teacher to upload some!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: UIUtils.fontSize(
                                          context,
                                          compact ? 13 : 15,
                                        ),
                                        color: UIUtils.subtextColor,
                                      ),
                                    ),
                                    if (widget.isTeacher && !compact) ...[
                                      SizedBox(
                                        height: UIUtils.spacing(context, 10),
                                      ),
                                      ElevatedButton.icon(
                                        focusNode: _controlNode('upload-empty'),
                                        onPressed: _uploadAudio,
                                        icon: const Icon(
                                          Icons.upload_file_rounded,
                                        ),
                                        label: const Text('Upload first audio'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: UIUtils.accentColor,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                    SizedBox(
                                      height: UIUtils.spacing(context, 6),
                                    ),
                                    TextButton.icon(
                                      focusNode: _controlNode('empty-retry'),
                                      onPressed: _loadAudioFiles,
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text("Refresh"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: UIUtils.paddingAll(context, 8),
                              itemCount: _audioFiles.length,
                              itemBuilder: (context, index) {
                                final audio = _audioFiles[index];
                                final audioId =
                                    audio['audio_id'] ?? audio['id'] ?? 0;
                                final title = audio['title'] ?? 'Untitled';
                                final description = audio['description'] ?? '';
                                final subjectName =
                                    audio['subject_name'] ?? 'Subject';
                                final className =
                                    audio['class_name'] ?? 'Class';
                                final duration = audio['duration'] as double?;
                                final isCurrentlyPlaying =
                                    _playingAudioId == audioId;

                                return Card(
                                  margin: EdgeInsets.only(
                                    bottom: UIUtils.spacing(context, 8),
                                    left: 4,
                                    right: 4,
                                  ),
                                  elevation: isCurrentlyPlaying ? 3 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isCurrentlyPlaying
                                        ? BorderSide(
                                            color: UIUtils.accentColor,
                                            width: 2,
                                          )
                                        : BorderSide(
                                            color: Colors.grey.withOpacity(0.1),
                                          ),
                                  ),
                                  color: isCurrentlyPlaying
                                      ? UIUtils.accentColor.withOpacity(0.12)
                                      : UIUtils.cardColor,
                                  child: InkWell(
                                    focusNode: _audioNode(audioId),
                                    onTap: () =>
                                        _playOrPauseAudio(audioId, title),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: UIUtils.paddingAll(context, 12),
                                      child: Row(
                                        children: [
                                          // Play/Pause icon
                                          Container(
                                            width: 46 * UIUtils.scale(context),
                                            height: 46 * UIUtils.scale(context),
                                            decoration: BoxDecoration(
                                              color: isCurrentlyPlaying
                                                  ? (_isPlaying
                                                        ? Colors.orange
                                                        : Colors.green)
                                                  : UIUtils.accentColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isCurrentlyPlaying && _isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: UIUtils.iconSize(
                                                context,
                                                24,
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                            width: UIUtils.spacing(context, 10),
                                          ),

                                          // Title + description
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontSize: UIUtils.fontSize(
                                                      context,
                                                      14,
                                                    ),
                                                    fontWeight: FontWeight.w700,
                                                    color: UIUtils.textColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '$className • $subjectName',
                                                  style: TextStyle(
                                                    fontSize: UIUtils.fontSize(
                                                      context,
                                                      11,
                                                    ),
                                                    color: UIUtils.subtextColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (description.isNotEmpty &&
                                                    !tiny) ...[
                                                  SizedBox(
                                                    height: UIUtils.spacing(
                                                      context,
                                                      2,
                                                    ),
                                                  ),
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
                                                if (duration != null &&
                                                    !tiny) ...[
                                                  SizedBox(
                                                    height: UIUtils.spacing(
                                                      context,
                                                      2,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Duration: ${_formatDuration(duration)}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          UIUtils.fontSize(
                                                            context,
                                                            10,
                                                          ),
                                                      color:
                                                          UIUtils.subtextColor,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          // Stop button
                                          if (isCurrentlyPlaying)
                                            IconButton(
                                              focusNode: _controlNode('stop'),
                                              icon: Icon(
                                                Icons.stop_rounded,
                                                color: Colors.red,
                                                size: UIUtils.iconSize(
                                                  context,
                                                  24,
                                                ),
                                              ),
                                              tooltip: 'Stop',
                                              onPressed: _stopAudio,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Now-playing bar with seek, speed, and transport controls.
  Widget _buildNowPlayingBar() {
    final bool compact = UIUtils.isTiny(context) || UIUtils.isShort(context);
    final barColor = _isPlaying
        ? Colors.deepPurple.shade700
        : Colors.grey.shade800;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 16,
        compact ? 6 : 10,
        compact ? 10 : 16,
        compact ? 4 : 6,
      ),
      color: barColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + speed + time
          Row(
            children: [
              Icon(
                _isPlaying ? Icons.music_note : Icons.audiotrack,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: compact ? 4 : 6),
              Expanded(
                child: Text(
                  _playingAudioTitle ?? 'Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_audioSpeed.toStringAsFixed(1)}×',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text(
                  '${_formatDuration(_currentPosition)} / '
                  '${_totalDuration != null ? _formatDuration(_totalDuration!) : "--:--"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ],
          ),

          // Seek bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: compact ? 2.0 : 3.0,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: compact ? 5.0 : 6.0,
              ),
              activeTrackColor: Colors.tealAccent,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.tealAccent,
              overlayColor: Colors.tealAccent.withOpacity(0.2),
            ),
            child: Slider(
              focusNode: _controlNode('seek'),
              value: (_totalDuration != null && _totalDuration! > 0)
                  ? (_currentPosition / _totalDuration!).clamp(0.0, 1.0)
                  : 0.0,
              onChanged: _totalDuration != null
                  ? (v) =>
                        setState(() => _currentPosition = v * _totalDuration!)
                  : null,
              onChangeEnd: _totalDuration != null
                  ? (v) => _seekTo(v * _totalDuration!)
                  : null,
            ),
          ),

          // Transport controls
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.fast_rewind,
                    color: Colors.white70,
                    size: compact ? 20 : 22,
                  ),
                  tooltip: 'Slower',
                  focusNode: _controlNode('slower'),
                  onPressed: _audioSpeed > 0.25
                      ? () => _changeSpeed(-0.25)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 30 : 34,
                    height: compact ? 28 : 32,
                  ),
                ),
                SizedBox(width: compact ? 4 : 8),
                IconButton(
                  icon: Icon(
                    Icons.replay_10,
                    color: Colors.white70,
                    size: compact ? 20 : 22,
                  ),
                  tooltip: 'Back 10s',
                  focusNode: _controlNode('rewind'),
                  onPressed: () => _seekTo(
                    (_currentPosition - 10).clamp(0.0, _totalDuration ?? 0.0),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 30 : 34,
                    height: compact ? 28 : 32,
                  ),
                ),
                SizedBox(width: compact ? 4 : 8),
                ElevatedButton.icon(
                  focusNode: _controlNode('play'),
                  onPressed: _playingAudioId != null
                      ? () => _playOrPauseAudio(
                          _playingAudioId!,
                          _playingAudioTitle ?? 'Audio',
                        )
                      : null,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: compact ? 18 : 20,
                  ),
                  label: Text(
                    _isPlaying ? 'Pause' : 'Play',
                    style: TextStyle(fontSize: compact ? 12 : 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 16,
                      vertical: compact ? 5 : 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 4 : 8),
                IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    color: Colors.white70,
                    size: compact ? 20 : 22,
                  ),
                  tooltip: 'Forward 10s',
                  focusNode: _controlNode('forward'),
                  onPressed: () => _seekTo(
                    (_currentPosition + 10).clamp(0.0, _totalDuration ?? 0.0),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 30 : 34,
                    height: compact ? 28 : 32,
                  ),
                ),
                SizedBox(width: compact ? 4 : 8),
                IconButton(
                  icon: Icon(
                    Icons.fast_forward,
                    color: Colors.white70,
                    size: compact ? 20 : 22,
                  ),
                  tooltip: 'Faster',
                  focusNode: _controlNode('faster'),
                  onPressed: _audioSpeed < 3.0
                      ? () => _changeSpeed(0.25)
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 30 : 34,
                    height: compact ? 28 : 32,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 2 : 4),
        ],
      ),
    );
  }
}

class AddAudioOptionsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return KeypadInstructionWrapper(
      screenName: 'Add Audio Options',
      labels: addAudioOptionsKeyLabels,
      actions: {
        1: onUploadNew,
        2: onAddExisting,
        0: () => Navigator.of(context).pop(),
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 220),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Audio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('1. Upload New File'),
                    onTap: onUploadNew,
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_music),
                    title: const Text('2. Select from Existing Library'),
                    onTap: onAddExisting,
                  ),
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

  FocusNode _itemNode(int id) => _itemNodes.putIfAbsent(
    id,
    () => FocusNode(debugLabel: 'existing-audio-$id'),
  );
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableAudio = [];
  bool _linking = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableAudio();
  }

  Future<void> _loadAvailableAudio() async {
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
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkAudio(int audioId) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio linked successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to link audio')));
    }
  }

  @override
  void dispose() {
    _backNode.dispose();
    _refreshNode.dispose();
    for (final node in _itemNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate dynamic actions where keys 1-9 map to the first available items
    final actions = <int, VoidCallback>{
      1: _loadAvailableAudio,
      0: () => Navigator.of(context).pop(),
    };

    for (int i = 0; i < _availableAudio.length && i < 8; i++) {
      actions[i + 2] = () {
        if (!_linking) {
          _linkAudio(
            _availableAudio[i]['audio_id'] ?? _availableAudio[i]['id'] as int,
          );
        }
      };
    }

    return KeypadInstructionWrapper(
      screenName: 'Select Existing Audio',
      labels: {
        ...selectExistingAudioKeyLabels,
        for (
          var index = 0;
          index < _availableAudio.length && index < 8;
          index++
        )
          index + 2: 'Add ${_availableAudio[index]['title']}',
      },
      actions: actions,
      focusTargets: [
        KeypadFocusTarget(
          node: _backNode,
          label: 'Back',
          onActivate: () => Navigator.of(context).maybePop(),
        ),
        KeypadFocusTarget(
          node: _refreshNode,
          label: 'Refresh available audio',
          onActivate: _loadAvailableAudio,
          isEnabled: () => !_linking,
        ),
        for (var index = 0; index < _availableAudio.length; index++)
          KeypadFocusTarget(
            node: _itemNode(
              (_availableAudio[index]['audio_id'] ??
                      _availableAudio[index]['id'])
                  as int,
            ),
            label:
                'Add ${_availableAudio[index]['title']}. '
                'Item ${index + 1} of ${_availableAudio.length}',
            onActivate: () => _linkAudio(
              (_availableAudio[index]['audio_id'] ??
                      _availableAudio[index]['id'])
                  as int,
            ),
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
            : _availableAudio.isEmpty
            ? const Center(
                child: Text(
                  'No unlinked audio available.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: _availableAudio.length,
                itemBuilder: (context, index) {
                  final item = _availableAudio[index];
                  final title = item['title'] ?? 'Untitled';
                  final keyNum = index < 8 ? index + 2 : null;

                  return ListTile(
                    focusNode: _itemNode(
                      (item['audio_id'] ?? item['id']) as int,
                    ),
                    enabled: !_linking,
                    leading: CircleAvatar(
                      child: Text(keyNum != null ? '$keyNum' : '-'),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      if (!_linking) {
                        _linkAudio(item['audio_id'] ?? item['id'] as int);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
