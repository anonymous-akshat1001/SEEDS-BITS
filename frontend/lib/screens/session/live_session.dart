import 'package:flutter/foundation.dart';

/// What the live class sub-screens (chat, class list, recordings) can
/// read and do. The class screen implements it and stays alive underneath,
/// so WebRTC, the class connection and the microphone keep running while a
/// sub-screen is open. [changes] fires whenever any of the values change.
abstract interface class LiveSession {
  Listenable get changes;
  bool get isTeacher;

  // Spoken state.
  String classStatus();

  // Participants.
  int? get ownParticipantId;
  List<Map<String, dynamic>> get participants;
  int get raisedHandCount;
  String participantSummary(Map<String, dynamic> participant);
  Future<void> removeParticipant(int participantId);

  /// Teacher key 2: mutes every student once; they may unmute themselves.
  Future<void> muteAllStudents();

  /// Who is connected, who joined and left, who never joined (teacher only).
  /// Null when it could not be read; the reason is spoken.
  Future<Map<String, dynamic>?> loadRoster();

  /// Rings, once, every student who has not joined yet.
  Future<void> remindNotJoined();

  // Chat. Messages are oldest first.
  List<Map<String, dynamic>> get messages;
  bool get chatPending;

  /// Sends [text]; true only when the server confirmed it.
  Future<bool> sendChat(String text);

  // Class recording.
  int? get recordingId;
  String? get recordingTitle;
  bool get recordingPlaying;
  double get recordingPosition;
  double? get recordingDuration;
  double get recordingSpeed;
  void toggleRecording();
  Future<void> seekRecordingBy(double seconds);
  Future<void> changeRecordingSpeed(double delta);

  // Audio library (teacher).
  List<Map<String, dynamic>> get audioFiles;
  bool get audioLibraryLoaded;
  int? get previewingAudioId;
  bool get uploadingAudio;
  Future<void> reloadAudioLibrary();
  Future<void> uploadAudio();
  Future<void> previewAudio(int audioId, String title);
  Future<void> selectAudio(int audioId, String title, {required bool play});

  /// Stops the class recording for everyone and closes it; returns whether
  /// the server confirmed it.
  Future<bool> closeRecording();

  // Teacher tools.
  Future<void> confirmEndSession();

  /// The class ends automatically at [endsAt] ("10:10") unless ended
  /// earlier; [extendClass] adds up to 15 minutes when [canExtend].
  String? get endsAt;
  bool get canExtend;
  Future<void> extendClass();
}
