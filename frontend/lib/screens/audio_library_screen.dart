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
