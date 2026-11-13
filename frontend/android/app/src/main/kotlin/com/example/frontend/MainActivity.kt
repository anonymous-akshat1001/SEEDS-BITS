package com.example.frontend

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.media.MediaRecorder
import android.os.SystemClock
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.inputmethod.InputMethodManager
import java.io.File
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private var notesChannel: MethodChannel? = null
    private var noteRecorder: MediaRecorder? = null
    private var noteId: String? = null
    private var recordingStarted = 0L
    private var noteCaptureForeground = false

    override fun onResume() {
        super.onResume()
        noteCaptureForeground = true
    }

    private fun finishNote(reason: String): Map<String, Any?> {
        val recorder = noteRecorder
        val id = noteId
        noteRecorder = null
        noteId = null
        var failure: String? = null
        if (recorder != null) {
            try {
                recorder.stop()
            } catch (error: RuntimeException) {
                failure = "The recording was too short or interrupted. Review or remove the retained file."
                android.util.Log.e("SEEDS Notes", "Recording could not be finalized", error)
            } finally {
                recorder.release()
            }
        }
        return mapOf("id" to id, "reason" to reason,
            "duration_ms" to (SystemClock.elapsedRealtime() - recordingStarted).coerceIn(0L, 300000L),
            "error" to failure)
    }

    private fun vibratePattern(onOff: List<Long>) {
        // Android waveforms start with an "off" delay; ours start with "on".
        val timings = (listOf(0L) + onOff).toLongArray()
        try {
            val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= 31) {
                (getSystemService(VIBRATOR_MANAGER_SERVICE) as? VibratorManager)?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(VIBRATOR_SERVICE) as? Vibrator
            }
            if (vibrator == null || !vibrator.hasVibrator()) return
            if (Build.VERSION.SDK_INT >= 26) {
                vibrator.vibrate(VibrationEffect.createWaveform(timings, -1))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(timings, -1)
            }
        } catch (error: RuntimeException) {
            android.util.Log.w("SEEDS Feedback", "Vibration unavailable", error)
        }
    }

    override fun onPause() {
        noteCaptureForeground = false
        if (noteRecorder != null) notesChannel?.invokeMethod("stopped", finishNote("interrupted"))
        super.onPause()
    }

    override fun onDestroy() {
        if (noteRecorder != null) finishNote("interrupted")
        notesChannel?.setMethodCallHandler(null)
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "seeds/keypad")
            .setMethodCallHandler { call, result ->
                if (call.method != "finishTextEditing") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val view = currentFocus as? FlutterView
                if (view == null) {
                    result.error("no_flutter_view", "The app no longer has keypad focus.", null)
                    return@setMethodCallHandler
                }
                // T9 IMEs can keep consuming physical keys after Flutter clears its client.
                val inputMethod = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                inputMethod.restartInput(view)
                result.success(null)
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "seeds/feedback")
            .setMethodCallHandler { call, result ->
                if (call.method != "vibrate") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val pattern = call.argument<List<Number>>("pattern")
                    ?.map { it.toLong().coerceIn(0L, 1000L) }
                    ?.take(12)
                if (pattern.isNullOrEmpty()) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                vibratePattern(pattern)
                result.success(null)
            }
        notesChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "seeds/private_notes")
        notesChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (!noteCaptureForeground) {
                        result.error("background", "Return to the app and explicitly start recording again.", null)
                    } else if (noteRecorder != null) {
                        result.error("busy", "A recording is already active.", null)
                    } else {
                        val path = call.argument<String>("path")
                        val id = call.argument<String>("id")
                        val allowance = call.argument<Number>("max_bytes")?.toLong()
                        val output = path?.let { File(it).canonicalFile }
                        if (output == null || id == null || allowance == null ||
                            allowance < 1024 || allowance > 10000000 ||
                            !output.path.startsWith(filesDir.canonicalPath + File.separator) ||
                            output.extension != "m4a") {
                            result.error("invalid", "Invalid private recording destination or allowance.", null)
                        } else {
                            @Suppress("DEPRECATION")
                            val recorder = if (Build.VERSION.SDK_INT >= 31) MediaRecorder(this) else MediaRecorder()
                            try {
                                recorder.setAudioSource(MediaRecorder.AudioSource.MIC)
                                recorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                                recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                                recorder.setAudioEncodingBitRate(32000)
                                recorder.setAudioSamplingRate(16000)
                                recorder.setOutputFile(output.path)
                                recorder.setMaxDuration(300000)
                                recorder.setMaxFileSize(allowance)
                                recorder.setOnInfoListener { _, what, _ ->
                                    if (noteRecorder === recorder &&
                                        (what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_DURATION_REACHED ||
                                         what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_FILESIZE_REACHED)) {
                                        notesChannel?.invokeMethod("stopped", finishNote("limit"))
                                    }
                                }
                                recorder.setOnErrorListener { _, _, _ ->
                                    if (noteRecorder === recorder) {
                                        notesChannel?.invokeMethod("stopped", finishNote("recorder_error"))
                                    }
                                }
                                recorder.prepare()
                                recorder.start()
                                noteRecorder = recorder
                                noteId = id
                                recordingStarted = SystemClock.elapsedRealtime()
                                result.success(true)
                            } catch (error: Exception) {
                                recorder.release()
                                android.util.Log.e("SEEDS Notes", "Recording could not start", error)
                                result.error("recording_failed", "Recording could not start. Check microphone permission and storage.", null)
                            }
                        }
                    }
                }
                "stop" -> result.success(finishNote("stopped"))
                else -> result.notImplemented()
            }
        }
        
        // Create notification channel for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "session_channel"
            val channelName = "Session Notifications"
            val channelDescription = "Notifications for session invitations and updates"
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableVibration(true)
                setShowBadge(true)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }
}