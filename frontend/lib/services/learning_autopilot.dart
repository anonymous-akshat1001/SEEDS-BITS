import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../screens/journeys/journey_player_screen.dart';
import 'journey_api.dart';
import 'journey_models.dart';
import 'offline_journey_store.dart';
import 'tts_service.dart';

/// Learning that runs itself (S26, S28, S29): continue where you stopped,
/// send saved progress, and prepare new journeys for offline use on Wi-Fi.
abstract final class LearningAutopilot {
  /// Settings key; on by default, and only ever uses Wi-Fi or ethernet.
  static const autoDownloadKey = 'auto_download_journeys';
  static const _lastPrepareKey = 'auto_download_last_run';

  /// At most this many new journeys are prepared per run, so a slow phone
  /// is never busy for long and storage fills gradually.
  static const maxPerRun = 2;
  static const _minimumGap = Duration(hours: 6);

  static bool _syncing = false;
  static bool _preparing = false;

  /// Sends progress saved while offline. Quiet: nothing to press or hear.
  static Future<void> syncQuietly({JourneyApi api = const JourneyApi()}) async {
    if (_syncing) return;
    _syncing = true;
    try {
      final store = await OfflineJourneyStore.forCurrentUser();
      await store.syncPending(api);
    } catch (error) {
      debugPrint('[AUTOPILOT] Progress sync deferred: ${error.runtimeType}');
    } finally {
      _syncing = false;
    }
  }

  /// Downloads new, unfinished journeys on Wi-Fi only, within the account's
  /// existing download allowance. Failures simply wait for the next run.
  static Future<void> prepareOffline({
    JourneyApi api = const JourneyApi(),
    Future<List<ConnectivityResult>> Function()? connectivity,
  }) async {
    if (_preparing || kIsWeb) return;
    _preparing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(autoDownloadKey) ?? true)) return;
      final last = prefs.getInt(_lastPrepareKey);
      final now = DateTime.now().millisecondsSinceEpoch;
      if (last != null &&
          now - last < _minimumGap.inMilliseconds) {
        return;
      }
      final links = await (connectivity ?? Connectivity().checkConnectivity)();
      final unmetered = links.contains(ConnectivityResult.wifi) ||
          links.contains(ConnectivityResult.ethernet);
      if (!unmetered) return;
      final store = await OfflineJourneyStore.forCurrentUser();
      final journeys = await api.studentJourneys();
      var prepared = 0;
      for (final journey in journeys) {
        if (prepared >= maxPerRun) break;
        if (journey.status == 'completed') continue;
        final saved = await store.savedSnapshot(journey.journeyId);
        if (saved != null && saved.revision == journey.revision) continue;
        final snapshot = await api.studentJourney(journey.journeyId);
        await store.download(snapshot);
        prepared++;
      }
      await prefs.setInt(_lastPrepareKey, now);
    } catch (error) {
      debugPrint('[AUTOPILOT] Offline preparation stopped: ${error.runtimeType}');
    } finally {
      _preparing = false;
    }
  }

  /// Opens the journey in progress straight into the player, at the saved
  /// place. Returns false (after saying so) when nothing is in progress.
  static Future<bool> continueLearning(
    BuildContext context, {
    JourneyApi api = const JourneyApi(),
  }) async {
    OfflineJourneyStore store;
    try {
      store = await OfflineJourneyStore.forCurrentUser();
    } on OfflineJourneyException catch (error) {
      unawaited(TtsService.speak(error.message));
      return false;
    }
    JourneySnapshot? snapshot;
    var offline = false;
    try {
      final journeys = await api.studentJourneys();
      final current = journeys
          .where((journey) => journey.status == 'in_progress')
          .firstOrNull;
      if (current != null) {
        snapshot = await api.studentJourney(current.journeyId);
      }
    } on JourneyApiException catch (error) {
      if (!error.network) {
        unawaited(TtsService.speak(error.message));
        return false;
      }
      offline = true;
    }
    if (snapshot == null) {
      for (final saved in await store.savedSnapshots()) {
        if (await store.loadProgress(saved.journeyId) != null) {
          // Unsent progress on this phone: play the saved copy.
          snapshot = saved;
          offline = true;
          break;
        }
      }
    }
    if (snapshot == null) {
      unawaited(TtsService.speak(Speech.t.homeNothingToContinue));
      return false;
    }
    if (!context.mounted) return false;
    unawaited(
      TtsService.speak(Speech.t.homeContinuing(snapshot.title)),
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => JourneyPlayerScreen(
          snapshot: snapshot!,
          store: store,
          api: api,
          offline: offline,
        ),
      ),
    );
    return true;
  }
}
