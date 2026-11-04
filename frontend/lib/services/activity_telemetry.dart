import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// Only semantic actions and numeric metadata belong in this queue.
class ActivityTelemetry {
  static const enabled = bool.fromEnvironment('TELEMETRY_ENABLED');
  static final syncIssue = ValueNotifier<String?>(null);
  static Future<void> _tail = Future<void>.value();
  static int _generation = 0;
  static DateTime _nextAttempt = DateTime.fromMillisecondsSinceEpoch(0);

  static void accountChanged() {
    _generation++;
    _nextAttempt = DateTime.fromMillisecondsSinceEpoch(0);
    syncIssue.value = null;
    if (enabled) {
      _tail = _tail.then((_) => _purgeExpired()).catchError((Object error) {
        syncIssue.value =
            'Expired activity could not be cleaned. Check device storage.';
        debugPrint('[ACTIVITY] Cleanup failed (${error.runtimeType}).');
      });
    }
  }

  @visibleForTesting
  static Future<void> waitForPending() => _tail;

  static Future<void> _purgeExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    for (final key in prefs.getKeys().where(
      (key) => RegExp(r'^seeds_activity_\d+$').hasMatch(key),
    )) {
      final rows = jsonDecode(prefs.getString(key) ?? '[]');
      if (rows is! List) {
        throw const FormatException('Unreadable activity queue');
      }
      final retained = rows
          .where(
            (row) =>
                row is Map &&
                row['occurred_at'] is String &&
                DateTime.parse(row['occurred_at'] as String).isAfter(cutoff),
          )
          .toList();
      if (!await prefs.setString(key, jsonEncode(retained))) {
        throw StateError('Expired activity cleanup failed');
      }
    }
  }

  static void record(
    String type, {
    int? audioId,
    Map<String, Object> details = const {},
  }) {
    if (!enabled) return;
    final generation = _generation;
    final operation = _tail.then(
      (_) => _record(type, audioId, details, generation),
    );
    _tail = operation.catchError((Object error) {
      _nextAttempt = DateTime.now().add(const Duration(seconds: 30));
      syncIssue.value =
          'Activity sync is unavailable. Learning is still available.';
      debugPrint('[ACTIVITY] Sync failed (${error.runtimeType}).');
    });
  }

  static String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static Future<void> _record(
    String type,
    int? audioId,
    Map<String, Object> details,
    int generation,
  ) async {
    if (generation != _generation) return;
    if (details.keys.any(
      (key) => !{
        'position',
        'speed',
        'offline',
        'count',
        'reason_code',
      }.contains(key),
    )) {
      throw ArgumentError('Unapproved activity metadata');
    }
    if (details.entries.any(
      (entry) => entry.key == 'reason_code'
          ? !{
              'network',
              'storage',
              'cancelled',
              'permission',
              'invalid',
              'unknown',
            }.contains(entry.value)
          : entry.key == 'offline'
          ? entry.value is! bool
          : entry.value is! num,
    )) {
      throw ArgumentError('Unapproved activity metadata value');
    }
    final prefs = await SharedPreferences.getInstance();
    if (generation != _generation) return;
    final account = prefs.getInt('user_id');
    final token = prefs.getString('token');
    if (account == null || token == null) {
      syncIssue.value = 'Sign in to sync activity.';
      return;
    }
    final key = 'seeds_activity_$account';
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    final stored = jsonDecode(prefs.getString(key) ?? '[]');
    if (stored is! List) {
      throw const FormatException('Unreadable activity queue');
    }
    final queue = <Map<String, dynamic>>[];
    for (final row in stored) {
      if (row is! Map<String, dynamic> || row['occurred_at'] is! String) {
        throw const FormatException('Unreadable activity event');
      }
      if (DateTime.parse(row['occurred_at'] as String).isAfter(cutoff)) {
        queue.add(row);
      }
    }
    if (queue.length >= 300) {
      syncIssue.value =
          'Activity queue is full. Some older actions cannot be reported.';
      queue.removeAt(0);
    }
    queue.add({
      'event_id': _uuid(),
      'event_type': type,
      'resource_type': audioId == null ? 'global' : 'audio',
      if (audioId != null) 'resource_id': audioId,
      'occurred_at': DateTime.now().toUtc().toIso8601String(),
      'details': details,
    });
    bool current() =>
        generation == _generation &&
        prefs.getInt('user_id') == account &&
        prefs.getString('token') == token;
    if (!current()) return;
    if (!await prefs.setString(key, jsonEncode(queue))) {
      throw StateError('Queue write failed');
    }
    if (!current()) return;
    if (DateTime.now().isBefore(_nextAttempt)) return;
    final response = await http
        .post(
          Uri.parse('${ApiService.baseUrl}/activity/events'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'events': queue.take(100).toList()}),
        )
        .timeout(const Duration(seconds: 10));
    if (!current()) return;
    if (response.statusCode != 200) {
      throw StateError('Activity server unavailable');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> ||
        body['accepted'] is! List ||
        body['duplicates'] is! List ||
        body['rejected'] is! List) {
      throw const FormatException('Invalid activity acknowledgment');
    }
    final done = <String>{
      ...(body['accepted'] as List).whereType<String>(),
      ...(body['duplicates'] as List).whereType<String>(),
      for (final row in body['rejected'] as List)
        if (row is Map && row['event_id'] is String) row['event_id'] as String,
    };
    queue.removeWhere((row) => done.contains(row['event_id']));
    if (!await prefs.setString(key, jsonEncode(queue))) {
      throw StateError('Acknowledgment save failed');
    }
    syncIssue.value = (body['rejected'] as List).isEmpty
        ? (queue.isEmpty ? null : 'Some activity is waiting to sync.')
        : 'Some activity was expired or no longer permitted and was not synced.';
  }
}
