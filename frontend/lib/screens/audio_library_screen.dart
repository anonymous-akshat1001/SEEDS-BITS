import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/ui_utils.dart';
// Allows user to pick audio files
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
// Audio playback library
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Used for multipart file upload
import 'package:http/http.dart' as http;
// Helps define MIME types and tells backend which type(mp3, etc) audio file it is
import 'package:http_parser/http_parser.dart';
// JSON encode/decode
import 'dart:convert';
import '../services/api_service.dart';
// Allows reading environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Backend and websocket URL
final baseUrl = dotenv.env['API_BASE_URL'];
final wsBaseUrl = dotenv.env['WS_BASE_URL'];


// Widget definition which allows the screen to change with time
class AudioLibraryScreen extends StatefulWidget {
  final int? sessionId; // Optional - if provided, allows selecting audio for session

  // Constructor
  const AudioLibraryScreen({
    super.key,
    this.sessionId,
  });

  @override
  State<AudioLibraryScreen> createState() => _AudioLibraryScreenState();
}


// State Class where the logic lives
class _AudioLibraryScreenState extends State<AudioLibraryScreen> {
  // Flutter TTS Engine
  final FlutterTts _tts = FlutterTts();

  // Handles audio playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  
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

  // Called once when the screen is created
  @override
  void initState() {
    super.initState();
    // fetch audio files from backend
    _loadAudioFiles();
    // attach listerners to audio player
    _setupAudioPlayer();
  }

  // Tells who are the listeners to the audio playing currently
  void _setupAudioPlayer() {
    // Triggered when audio finishes playing
    _audioPlayer.onPlayerComplete.listen((_) {
      
      if (!mounted){
        return;
      }
      
      // Clear playing state
      setState(() => _playingAudioId = null);
      
      _speakIfEnabled("Playback finished");
    });

    // Triggered when player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      
      if (!mounted){
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
    if (!mounted){
      return;
    } 

    // show loading spinner
    setState(() => _isLoading = true);
    
    try {
      // fetch audio list from backend
      final result = await ApiService.get('/audio/list', useAuth: true);
      
      if (result != null) {
        
        if (!mounted){
          return;
        }
        
        setState(() {
          // backend may return a direct list or list wrapped { files: [...] }
          if (result is List) {
            _audioFiles = result.cast<Map<String, dynamic>>();
          } 
          else if (result is Map && result.containsKey('files')) {
            _audioFiles = (result['files'] as List).cast<Map<String, dynamic>>();
          }
        });
        
        await _speakIfEnabled("Loaded ${_audioFiles.length} audio files");
      
      }
    } 
    catch (e) {
      print('[AUDIO LIBRARY] Error loading files: $e');
      _showError("Failed to load audio files");
    } 
    finally {  
      if (!mounted) {
        return;
      }
      // Hide loading indicator
      setState(() => _isLoading = false);
    }
  }

  // Function to upload audio files - only by teacher
  Future<void> _uploadAudioFile() async {
    try {
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

      // Show upload dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                  style: TextStyle(fontSize: UIUtils.fontSize(context, 14), color: UIUtils.textColor),
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    labelStyle: TextStyle(color: UIUtils.subtextColor),
                    filled: true,
                    fillColor: UIUtils.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: UIUtils.paddingSymmetric(context, horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(fontSize: UIUtils.fontSize(context, 14), color: UIUtils.textColor),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: UIUtils.subtextColor),
                    filled: true,
                    fillColor: UIUtils.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: UIUtils.paddingSymmetric(context, horizontal: 16, vertical: 12),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: UIUtils.subtextColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performUpload(file, _titleController.text, _descriptionController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: UIUtils.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

    } catch (e) {
      print('[UPLOAD] Error: $e');
      _showError("Failed to pick file");
    }
  }

  // Actual upload happens separately
  Future<void> _performUpload(PlatformFile file, String title, String description) async {
    if (title.trim().isEmpty) {
      _showError("Title is required");
      return;
    }

    setState(() => _isUploading = true);
    await _speakIfEnabled("Uploading audio file");

    try {
      final headers = await ApiService.getHeaders();
      final uri = Uri.parse('$baseUrl/audio/upload?user_id=${await _getUserId()}');
      
      // Multipart request support files and form fields
      var request = http.MultipartRequest('POST', uri);
      // Adds metadata fields
      request.headers.addAll(headers);
      request.fields['title'] = title;
      request.fields['description'] = description;

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
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
            // Determine correct file type for backend
            contentType: MediaType.parse(contentType),
          ));
        }
      } 
      else {
        // Mobile uses filesystem path
        if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: file.name,
            contentType: MediaType.parse(contentType),
          ));
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
      } 
      else {
        print('[UPLOAD] Error: ${response.statusCode} $responseBody');
        _showError("Upload failed: ${jsonDecode(responseBody)['detail'] ?? 'Unknown error'}");
      }
    } 
    catch (e) {
      print('[UPLOAD] Error: $e');
      _showError("Upload failed: $e");
    } 
    finally {
      setState(() => _isUploading = false);
    }
  }

  Future<int?> _getUserId() async {
    // Get from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
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
      final url = '$baseUrl/audio/$audioId/stream';
      // Streams audio directly from backend
      await _audioPlayer.play(UrlSource(url));
      // updates UI state
      setState(
        () => _playingAudioId = audioId
        );
      await _speakIfEnabled("Playing $title");
    } 
    catch (e) {
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
      final result = await ApiService.selectAudio(widget.sessionId!, audioId);

      if (result != null && result['ok'] == true) {
        // update UI
        setState(() => _selectedAudioId = audioId);
        await _speakIfEnabled("Selected $title for session");
        
        // Ask if they want to play immediately
        final play = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Audio Selected'),
            content: Text('Do you want to start playing "$title" for all participants now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Yet'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Play Now'),
              ),
            ],
          ),
        );

        if (play == true) {
          await _playForSession(audioId);
        }
      } 
      else {
        _showError("Failed to select audio");
      }
    } 
    catch (e) {
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
      );

      if (result != null && result['ok'] == true) {
        await _speakIfEnabled("Started playback for all participants");
      } else {
        _showError("Failed to start playback");
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
      final result = await ApiService.pauseAudio(widget.sessionId!);

      if (result != null && result['ok'] == true) {
        await _speakIfEnabled("Paused session audio");
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    _speakIfEnabled(message);
  }

  Future<void> _speakIfEnabled(String text) async {
    if (_ttsEnabled) {
      try {
        await _tts.speak(text);
      } catch (e) {
        print('[TTS] Error: $e');
      }
    }
  }

  // Frees memory and text controllers
  @override
  void dispose() {
    // Cancel any pending operations
    _titleController.dispose();
    _descriptionController.dispose();
    
    // Stop and dispose audio player BEFORE disposing
    _audioPlayer.stop();
    _audioPlayer.dispose();
    
    // Stop TTS
    _tts.stop();
    
    // Call super.dispose last
    super.dispose();
  }

  // Build Final UI for Audio Screen
  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sessionId != null 
            ? 'Audio - Session ${widget.sessionId}'
            : 'Audio Library',
          style: TextStyle(fontSize: UIUtils.fontSize(context, 16), fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: UIUtils.iconSize(context, 20), color: UIUtils.accentColor),
            tooltip: 'Toggle TTS',
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              _speakIfEnabled(_ttsEnabled ? "TTS enabled" : "TTS disabled");
            },
          ),
          if (widget.sessionId != null)
            IconButton(
              icon: Icon(Icons.pause_rounded, size: UIUtils.iconSize(context, 20), color: Colors.orange),
              tooltip: 'Pause Session Audio',
              onPressed: _pauseSessionAudio,
            ),
        ],
      ),
      backgroundColor: UIUtils.backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                if (_isUploading)
                  const LinearProgressIndicator(),
                
                Padding(
                  padding: UIUtils.paddingAll(context, 10),
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadAudioFile,
                    icon: Icon(Icons.upload_file_rounded, size: UIUtils.iconSize(context, 18)),
                    label: Text('Upload New Audio', style: TextStyle(fontSize: UIUtils.fontSize(context, 14), fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIUtils.primaryColor,
                      foregroundColor: Colors.white,
                      padding: UIUtils.paddingSymmetric(context, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                
                SizedBox(height: UIUtils.spacing(context, 4)),
                
                Expanded(
                  child: _audioFiles.isEmpty
                      ? Center(
                          child: Text(
                            'No audio files yet.\nUpload some!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: UIUtils.fontSize(context, 13),
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: UIUtils.paddingAll(context, 8),
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
                              margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 10), left: 10, right: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                              ),
                              color: isSelected ? UIUtils.accentColor.withOpacity(0.05) : Colors.white,
                              child: Padding(
                                padding: UIUtils.paddingAll(context, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isPlaying ? Icons.music_note_rounded : Icons.audiotrack_rounded,
                                          color: isPlaying ? Colors.green : UIUtils.accentColor,
                                          size: UIUtils.iconSize(context, 24),
                                        ),
                                        SizedBox(width: UIUtils.spacing(context, 6)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      title,
                                                      style: TextStyle(
                                                        fontSize: UIUtils.fontSize(context, 15),
                                                        fontWeight: FontWeight.w700,
                                                        color: UIUtils.textColor,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Container(
                                                      padding: UIUtils.paddingSymmetric(context, horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: UIUtils.primaryColor,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        'SELECTED',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: UIUtils.fontSize(context, 9),
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (description.isNotEmpty && !tiny)
                                                Text(
                                                  description,
                                                  style: TextStyle(
                                                    fontSize: UIUtils.fontSize(context, 11),
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    if (uploadedAt.isNotEmpty && !tiny)
                                      Padding(
                                        padding: EdgeInsets.only(top: UIUtils.spacing(context, 4), left: 30 * UIUtils.scale(context)),
                                        child: Text(
                                          'Uploaded: $uploadedAt',
                                          style: TextStyle(
                                            fontSize: UIUtils.fontSize(context, 10),
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    
                                    SizedBox(height: UIUtils.spacing(context, 6)),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _playAudioLocally(audioId, title),
                                          icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, size: UIUtils.iconSize(context, 18)),
                                          label: Text(isPlaying ? 'Stop' : 'Preview', style: TextStyle(fontSize: UIUtils.fontSize(context, 12))),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isPlaying ? Colors.orange : UIUtils.accentColor,
                                            foregroundColor: Colors.white,
                                            padding: UIUtils.paddingSymmetric(context, horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            elevation: 0,
                                          ),
                                        ),
                                        
                                        if (widget.sessionId != null) ...[
                                          SizedBox(width: UIUtils.spacing(context, 4)),
                                          ElevatedButton.icon(
                                            onPressed: () => _selectForSession(audioId, title),
                                            icon: Icon(Icons.check_circle_outline_rounded, size: UIUtils.iconSize(context, 18)),
                                            label: Text('Select', style: TextStyle(fontSize: UIUtils.fontSize(context, 12))),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSelected ? UIUtils.primaryColor : Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: UIUtils.paddingSymmetric(context, horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                          ),
                                        ],
                                      ],
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
  const OfflineAudioLibraryScreen({super.key});

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
  bool _isTeacher = false;
  int? _currentUserId;

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
      _isLoading = !_sessionsLoaded; // hide spinner only if sessions are also done
    });
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;

    try {
      final result = await ApiService.getActiveSessions();
      if (result != null && mounted) {
        setState(() {
          _sessions = result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      print('[OFFLINE LIB] Error loading sessions: $e');
    } finally {
      if (mounted) setState(() {
        _sessionsLoaded = true;
        _isLoading = !_userInfoLoaded; // hide spinner only if user info is also done
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
        ),
      ),
    );
  }

  void _searchById() {
    final idText = _searchController.text.trim();
    if (idText.isEmpty) return;

    final sessionId = int.tryParse(idText);
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid session number')),
      );
      return;
    }

    // Search in loaded sessions first
    final found = _sessions.firstWhere(
      (s) => s['session_id'] == sessionId,
      orElse: () => <String, dynamic>{},
    );

    if (found.isNotEmpty) {
      _openClassAudio(found);
    } else {
      // Open directly even if not in the list (session might be inactive 
      // but teacher's audio is still accessible)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassAudioScreen(
            sessionId: sessionId,
            sessionTitle: 'Session $sessionId',
            teacherId: null, // will be fetched
            isTeacher: _isTeacher,
          ),
        ),
      );
    }
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Audio Library',
          style: TextStyle(
            fontSize: UIUtils.fontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 40 : null,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor),
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
                  // ── Instruction ──────────────────────────────────────
                  Container(
                    padding: UIUtils.paddingAll(context, 12),
                    decoration: BoxDecoration(
                      color: UIUtils.accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: UIUtils.accentColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: UIUtils.accentColor,
                            size: UIUtils.iconSize(context, 20)),
                        SizedBox(width: UIUtils.spacing(context, 8)),
                        Expanded(
                          child: Text(
                            'Select a class to view and play its audio files.',
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

                  // ── Search by Session ID ─────────────────────────────
                  Container(
                    padding: UIUtils.paddingAll(context, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Class by ID',
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
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter Session/Class ID',
                                  hintStyle: TextStyle(
                                      fontSize:
                                          UIUtils.fontSize(context, 13)),
                                  prefixIcon: const Icon(Icons.search,
                                      size: 18),
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: UIUtils.accentColor,
                                        width: 1.5),
                                  ),
                                ),
                                onSubmitted: (_) => _searchById(),
                              ),
                            ),
                            SizedBox(width: UIUtils.spacing(context, 8)),
                            ElevatedButton.icon(
                              onPressed: _searchById,
                              icon: Icon(Icons.arrow_forward_rounded,
                                  size: UIUtils.iconSize(context, 16)),
                              label: Text("Go",
                                  style: TextStyle(
                                      fontSize:
                                          UIUtils.fontSize(context, 13))),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIUtils.primaryColor,
                                foregroundColor: Colors.white,
                                padding: UIUtils.paddingSymmetric(context,
                                    horizontal: 16, vertical: 12),
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
                    margin: EdgeInsets.only(bottom: UIUtils.spacing(context, 16)),
                    color: UIUtils.accentColor.withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: UIUtils.accentColor.withOpacity(0.3)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClassAudioScreen(
                              sessionId: 0, // 0 simply means 'Not a specific class'
                              sessionTitle: _isTeacher ? 'My Audio Library' : 'All Audio Files',
                              teacherId: _isTeacher ? _currentUserId : null,
                              isTeacher: _isTeacher,
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
                              child: Icon(Icons.library_music_rounded,
                                  color: UIUtils.accentColor,
                                  size: UIUtils.iconSize(context, 22)),
                            ),
                            SizedBox(width: UIUtils.spacing(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isTeacher ? 'My Audio Library' : 'All Audio Files',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: UIUtils.fontSize(context, 15),
                                      color: UIUtils.textColor,
                                    ),
                                  ),
                                  SizedBox(height: UIUtils.spacing(context, 3)),
                                  Text(
                                    _isTeacher ? 'Manage and upload your audio files' : 'Browse all uploaded audio files',
                                    style: TextStyle(
                                      fontSize: UIUtils.fontSize(context, 12),
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: UIUtils.accentColor,
                                size: UIUtils.iconSize(context, 16)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Classes / Sessions Header ────────────────────────
                  Row(
                    children: [
                      Icon(Icons.class_rounded,
                          size: UIUtils.iconSize(context, 20),
                          color: UIUtils.accentColor),
                      SizedBox(width: UIUtils.spacing(context, 6)),
                      Text(
                        'Active Classes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: UIUtils.fontSize(context, 16),
                          color: UIUtils.textColor,
                        ),
                      ),
                      const Spacer(),
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
                          Icon(Icons.school_outlined,
                              size: UIUtils.iconSize(context, 48),
                              color: Colors.grey.shade400),
                          SizedBox(
                              height: UIUtils.spacing(context, 8)),
                          Text(
                            'No active classes found.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: UIUtils.fontSize(context, 14),
                            ),
                          ),
                          SizedBox(
                              height: UIUtils.spacing(context, 6)),
                          Text(
                            'Use "Search by ID" above to access a class directly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
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
                          session['title'] ?? 'Session ${session['session_id']}';
                      final sessionId = session['session_id'] ?? 0;
                      final participantCount =
                          session['participant_count'] ?? 0;

                      return Card(
                        margin: EdgeInsets.only(
                            bottom: UIUtils.spacing(context, 8)),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.12)),
                        ),
                        color: Colors.white,
                        child: InkWell(
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
                                    color: UIUtils.accentColor
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.library_music_rounded,
                                    color: UIUtils.accentColor,
                                    size:
                                        UIUtils.iconSize(context, 22),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        UIUtils.spacing(context, 12)),
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
                                              context, 15),
                                          color: UIUtils.textColor,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: UIUtils.spacing(
                                              context, 3)),
                                      Text(
                                        'Session #$sessionId  •  $participantCount participants',
                                        style: TextStyle(
                                          fontSize: UIUtils.fontSize(
                                              context, 11),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
                                    size:
                                        UIUtils.iconSize(context, 22)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
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

  const ClassAudioScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
    this.teacherId,
    this.isTeacher = false,
  });

  @override
  State<ClassAudioScreen> createState() => _ClassAudioScreenState();
}

class _ClassAudioScreenState extends State<ClassAudioScreen> {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> _audioFiles = [];
  bool _isLoading = true;
  bool _isUploadingAudio = false;
  bool _ttsEnabled = true;
  int? _resolvedTeacherId;

  // Playback state
  int? _playingAudioId;
  String? _playingAudioTitle;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double? _totalDuration;
  double _audioSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _resolvedTeacherId = widget.teacherId;
    _loadAudioFiles();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() => _currentPosition = pos.inSeconds.toDouble());
      }
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() => _totalDuration = dur.inSeconds.toDouble());
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
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
      // If we don't have the teacherId yet, try to get session info
      if (_resolvedTeacherId == null && widget.sessionId != 0) {
        final sessionState =
            await ApiService.getSessionState(widget.sessionId);
        if (sessionState != null) {
          _resolvedTeacherId = sessionState['created_by'] as int?;
        }
      }

      // Get all audio files
      print('[CLASS AUDIO] Fetching audio list... teacherId=$_resolvedTeacherId sessionId=${widget.sessionId}');
      final result = await ApiService.getAudioList();
      print('[CLASS AUDIO] getAudioList result type=${result?.runtimeType} count=${result?.length}');
      
      if (result == null) {
        print('[CLASS AUDIO] API returned null - check backend connection and user_id param');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load audio files. Check network & login.'),
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

        // Filter audio files to only those uploaded by this session's teacher
        // If teacherId is null (e.g. student viewing "All Audio Files"), show everything
        if (_resolvedTeacherId != null) {
          allFiles = allFiles
              .where((f) => f['uploaded_by']?.toString() == _resolvedTeacherId.toString())
              .toList();
          print('[CLASS AUDIO] After filter by teacher=$_resolvedTeacherId: ${allFiles.length} files');
        } else {
          print('[CLASS AUDIO] No teacher filter - showing all ${allFiles.length} files');
        }

        setState(() {
          _audioFiles = allFiles;
        });
        await _speakIfEnabled(
            "Found ${_audioFiles.length} audio files for ${widget.sessionTitle}");
      }
    } catch (e) {
      print('[CLASS AUDIO] Error loading files: $e');
      _showError("Failed to load audio files: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _playOrPauseAudio(int audioId, String title) async {
    try {
      if (_playingAudioId == audioId) {
        if (_isPlaying) {
          await _audioPlayer.pause();
          setState(() => _isPlaying = false);
          await _speakIfEnabled("Paused");
        } else {
          await _audioPlayer.resume();
          setState(() => _isPlaying = true);
          await _speakIfEnabled("Resumed");
        }
        return;
      }

      await _audioPlayer.stop();
      setState(() {
        _playingAudioId = audioId;
        _playingAudioTitle = title;
        _isPlaying = true;
        _currentPosition = 0;
        _totalDuration = null;
      });

      await _audioPlayer.setPlaybackRate(_audioSpeed);
      await _audioPlayer.play(UrlSource('$baseUrl/audio/$audioId/stream'));

      // Log the self-listen event
      try {
        await ApiService.post('/audio/$audioId/play-log', {});
      } catch (_) {}

      await _speakIfEnabled("Playing $title");
    } catch (e) {
      print('[CLASS AUDIO PLAY] Error: $e');
      _showError("Failed to play audio");
      setState(() {
        _isPlaying = false;
        _playingAudioId = null;
        _playingAudioTitle = null;
      });
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _playingAudioId = null;
      _playingAudioTitle = null;
      _currentPosition = 0;
      _totalDuration = null;
    });
    await _speakIfEnabled("Stopped");
  }

  Future<void> _seekTo(double position) async {
    await _audioPlayer.seek(Duration(seconds: position.toInt()));
    setState(() => _currentPosition = position);
  }

  void _changeSpeed(double delta) {
    final newSpeed = (_audioSpeed + delta).clamp(0.25, 3.0);
    setState(() => _audioSpeed = newSpeed);
    _audioPlayer.setPlaybackRate(newSpeed);
    _speakIfEnabled("Speed ${newSpeed.toStringAsFixed(2)}x");
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
    if (_ttsEnabled) {
      try {
        await _tts.speak(text);
      } catch (_) {}
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ── Upload Audio (teacher only) ────────────────────────────────────────────
  Future<void> _uploadAudio() async {
    try {
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
          text: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''));
      final descController = TextEditingController();

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Upload Audio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
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
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isUploadingAudio = true);
      await _speakIfEnabled("Uploading audio");

      final title = titleController.text.trim().isNotEmpty
          ? titleController.text.trim()
          : file.name;
      final desc = descController.text.trim();

      Map<String, dynamic>? uploadResult;

      if (file.bytes != null) {
        uploadResult = await ApiService.uploadAudioBytes(
          fileBytes: file.bytes!,
          filename: file.name,
          title: title,
          description: desc,
        );
      } else if (file.path != null) {
        uploadResult = await ApiService.uploadAudio(
          filePath: file.path!,
          title: title,
          description: desc,
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
      _showError("Upload failed: $e");
    } finally {
      if (mounted) setState(() => _isUploadingAudio = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool tiny = UIUtils.isTiny(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.sessionTitle,
              style: TextStyle(
                fontSize: UIUtils.fontSize(context, 16),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Audio Library • Session #${widget.sessionId}',
              style: TextStyle(
                fontSize: UIUtils.fontSize(context, 11),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: UIUtils.textColor,
        elevation: 0,
        toolbarHeight: tiny ? 48 : 56,
        actions: [
          IconButton(
            icon: Icon(
              _ttsEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              size: UIUtils.iconSize(context, 20),
              color: UIUtils.accentColor,
            ),
            tooltip: 'Toggle TTS',
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              _speakIfEnabled(
                  _ttsEnabled ? "TTS enabled" : "TTS disabled");
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                size: UIUtils.iconSize(context, 20),
                color: UIUtils.accentColor),
            tooltip: 'Refresh',
            onPressed: _loadAudioFiles,
          ),
        ],
      ),
      backgroundColor: UIUtils.backgroundColor,
      // Upload FAB for teachers only
      floatingActionButton: widget.isTeacher
          ? FloatingActionButton.extended(
              onPressed: _isUploadingAudio ? null : _uploadAudio,
              icon: _isUploadingAudio
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload_file_rounded),
              label: Text(_isUploadingAudio ? 'Uploading…' : 'Upload Audio'),
              backgroundColor: UIUtils.accentColor,
              foregroundColor: Colors.white,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Now-Playing bar ─────────────────────────────────
                if (_playingAudioId != null) _buildNowPlayingBar(),

                // ── Upload progress ─────────────────────────────────
                if (_isUploadingAudio)
                  const LinearProgressIndicator(
                      color: Colors.teal, minHeight: 3),

                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: UIUtils.paddingAll(context, 12),
                  child: Row(
                    children: [
                      Icon(Icons.audiotrack_rounded,
                          size: UIUtils.iconSize(context, 20),
                          color: UIUtils.accentColor),
                      SizedBox(width: UIUtils.spacing(context, 6)),
                      Text(
                        '${_audioFiles.length} Audio Files',
                        style: TextStyle(
                          fontSize: UIUtils.fontSize(context, 15),
                          fontWeight: FontWeight.w700,
                          color: UIUtils.textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Audio list ──────────────────────────────────────
                Expanded(
                  child: _audioFiles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.audiotrack_rounded,
                                  size: UIUtils.iconSize(context, 52),
                                  color: Colors.grey.shade400),
                              SizedBox(
                                  height:
                                      UIUtils.spacing(context, 10)),
                              Text(
                                widget.isTeacher
                                    ? 'No audio files for this class yet.'
                                    : 'No audio files available yet.\nAsk your teacher to upload some!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      UIUtils.fontSize(context, 15),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (widget.isTeacher) ...[
                                SizedBox(
                                    height:
                                        UIUtils.spacing(context, 10)),
                                ElevatedButton.icon(
                                  onPressed: _uploadAudio,
                                  icon: const Icon(
                                      Icons.upload_file_rounded),
                                  label:
                                      const Text('Upload first audio'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        UIUtils.accentColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                              SizedBox(
                                  height:
                                      UIUtils.spacing(context, 6)),
                              TextButton.icon(
                                onPressed: _loadAudioFiles,
                                icon: const Icon(Icons.refresh,
                                    size: 16),
                                label: const Text("Refresh"),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: UIUtils.paddingAll(context, 8),
                          itemCount: _audioFiles.length,
                          itemBuilder: (context, index) {
                            final audio = _audioFiles[index];
                            final audioId = audio['audio_id'] ??
                                audio['id'] ??
                                0;
                            final title =
                                audio['title'] ?? 'Untitled';
                            final description =
                                audio['description'] ?? '';
                            final duration =
                                audio['duration'] as double?;
                            final isCurrentlyPlaying =
                                _playingAudioId == audioId;

                            return Card(
                              margin: EdgeInsets.only(
                                bottom:
                                    UIUtils.spacing(context, 8),
                                left: 4,
                                right: 4,
                              ),
                              elevation:
                                  isCurrentlyPlaying ? 3 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                side: isCurrentlyPlaying
                                    ? BorderSide(
                                        color:
                                            UIUtils.accentColor,
                                        width: 2)
                                    : BorderSide(
                                        color: Colors.grey
                                            .withOpacity(0.1)),
                              ),
                              color: isCurrentlyPlaying
                                  ? UIUtils.accentColor
                                      .withOpacity(0.05)
                                  : Colors.white,
                              child: InkWell(
                                onTap: () => _playOrPauseAudio(
                                    audioId, title),
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Padding(
                                  padding: UIUtils.paddingAll(
                                      context, 12),
                                  child: Row(
                                    children: [
                                      // Play/Pause icon
                                      Container(
                                        width: 46 *
                                            UIUtils.scale(
                                                context),
                                        height: 46 *
                                            UIUtils.scale(
                                                context),
                                        decoration: BoxDecoration(
                                          color:
                                              isCurrentlyPlaying
                                                  ? (_isPlaying
                                                      ? Colors
                                                          .orange
                                                      : Colors
                                                          .green)
                                                  : UIUtils
                                                      .accentColor,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isCurrentlyPlaying &&
                                                  _isPlaying
                                              ? Icons
                                                  .pause_rounded
                                              : Icons
                                                  .play_arrow_rounded,
                                          color: Colors.white,
                                          size:
                                              UIUtils.iconSize(
                                                  context, 24),
                                        ),
                                      ),

                                      SizedBox(
                                          width:
                                              UIUtils.spacing(
                                                  context,
                                                  10)),

                                      // Title + description
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: UIUtils
                                                    .fontSize(
                                                        context,
                                                        14),
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                                color: UIUtils
                                                    .textColor,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                            if (description
                                                    .isNotEmpty &&
                                                !tiny) ...[
                                              SizedBox(
                                                  height: UIUtils
                                                      .spacing(
                                                          context,
                                                          2)),
                                              Text(
                                                description,
                                                style:
                                                    TextStyle(
                                                  fontSize: UIUtils
                                                      .fontSize(
                                                          context,
                                                          11),
                                                  color: Colors
                                                          .grey[
                                                      600],
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                              ),
                                            ],
                                            if (duration !=
                                                    null &&
                                                !tiny) ...[
                                              SizedBox(
                                                  height: UIUtils
                                                      .spacing(
                                                          context,
                                                          2)),
                                              Text(
                                                'Duration: ${_formatDuration(duration)}',
                                                style:
                                                    TextStyle(
                                                  fontSize: UIUtils
                                                      .fontSize(
                                                          context,
                                                          10),
                                                  color: Colors
                                                          .grey[
                                                      500],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Stop button
                                      if (isCurrentlyPlaying)
                                        IconButton(
                                          icon: Icon(
                                              Icons
                                                  .stop_rounded,
                                              color:
                                                  Colors.red,
                                              size: UIUtils
                                                  .iconSize(
                                                      context,
                                                      24)),
                                          tooltip: 'Stop',
                                          onPressed:
                                              _stopAudio,
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
    );
  }

  /// Now-playing bar with seek, speed, and transport controls.
  Widget _buildNowPlayingBar() {
    final barColor =
        _isPlaying ? Colors.deepPurple.shade700 : Colors.grey.shade800;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      color: barColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + speed + time
          Row(children: [
            Icon(
              _isPlaying ? Icons.music_note : Icons.audiotrack,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _playingAudioTitle ?? 'Audio',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
            const SizedBox(width: 6),
            Text(
              '${_formatDuration(_currentPosition)} / '
              '${_totalDuration != null ? _formatDuration(_totalDuration!) : "--:--"}',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ]),

          // Seek bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: Colors.tealAccent,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.tealAccent,
              overlayColor: Colors.tealAccent.withOpacity(0.2),
            ),
            child: Slider(
              value: (_totalDuration != null && _totalDuration! > 0)
                  ? (_currentPosition / _totalDuration!)
                      .clamp(0.0, 1.0)
                  : 0.0,
              onChanged: _totalDuration != null
                  ? (v) => setState(
                      () => _currentPosition = v * _totalDuration!)
                  : null,
              onChangeEnd: _totalDuration != null
                  ? (v) => _seekTo(v * _totalDuration!)
                  : null,
            ),
          ),

          // Transport controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.fast_rewind,
                    color: Colors.white70, size: 22),
                tooltip: 'Slower',
                onPressed: _audioSpeed > 0.25
                    ? () => _changeSpeed(-0.25)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.replay_10,
                    color: Colors.white70, size: 22),
                tooltip: 'Back 10s',
                onPressed: () => _seekTo((_currentPosition - 10)
                    .clamp(0.0, _totalDuration ?? 0.0)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _playingAudioId != null
                    ? () => _playOrPauseAudio(
                        _playingAudioId!,
                        _playingAudioTitle ?? 'Audio')
                    : null,
                icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20),
                label: Text(_isPlaying ? 'Pause' : 'Play',
                    style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isPlaying ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.forward_10,
                    color: Colors.white70, size: 22),
                tooltip: 'Forward 10s',
                onPressed: () => _seekTo((_currentPosition + 10)
                    .clamp(0.0, _totalDuration ?? 0.0)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.fast_forward,
                    color: Colors.white70, size: 22),
                tooltip: 'Faster',
                onPressed: _audioSpeed < 3.0
                    ? () => _changeSpeed(0.25)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}


