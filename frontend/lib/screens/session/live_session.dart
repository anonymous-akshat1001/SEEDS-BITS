import 'package:flutter/foundation.dart';

/// What the live class sub-screens (chat, class console, recordings) can
/// read and do. The class screen implements it and stays alive underneath,
/// so WebRTC, the class connection and the microphone keep running while a
/// sub-screen is open. [changes] fires whenever any of the values change.
abstract interface class LiveSession {
  Listenable get changes;
  bool get isTeacher;

  // Spoken state.
  String classStatus();
  String classroomSummary();

  // Participants.
  int? get ownParticipantId;
  List<Map<String, dynamic>> get participants;
  int get raisedHandCount;
  String participantSummary(Map<String, dynamic> participant);
  Future<void> openHandQueue();
  Future<void> muteParticipant(int participantId);
  Future<void> removeParticipant(int participantId);

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

  // Teacher tools.
  void openInvite();
  Future<void> openClassroomCheck();
  Future<void> confirmEndSession();
}
