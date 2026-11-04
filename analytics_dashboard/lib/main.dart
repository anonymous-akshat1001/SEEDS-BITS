import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

void main() => runApp(const AnalyticsApp());

class AnalyticsApp extends StatelessWidget {
  const AnalyticsApp({super.key, this.client});
  final http.Client? client;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SEEDS Analytics',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: AnalyticsHome(client: client),
  );
}

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: brightness,
  );
  final radius = BorderRadius.circular(12);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surfaceContainerLow,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: radius),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
  );
}

const _metrics = {
  'sessions_created': 'Sessions created',
  'session_openings': 'Session openings',
  'attendance': 'Attendance',
  'quiz_average': 'Quiz average',
  'quiz_attempts': 'Quiz attempts',
  'activity_counts': 'Activity counts',
};

String _labelFor(String key) {
  final words = key.replaceAll('_', ' ').trim();
  return words.isEmpty ? key : words[0].toUpperCase() + words.substring(1);
}

String _display(Object? value) => switch (value) {
  null => '—',
  true => 'Yes',
  false => 'No',
  Map() || List() => jsonEncode(value),
  _ => value.toString(),
};

String _day(DateTime value) => value.toIso8601String().substring(0, 10);

class AnalyticsHome extends StatefulWidget {
  const AnalyticsHome({super.key, this.client});
  final http.Client? client;
  @override
  State<AnalyticsHome> createState() => _AnalyticsHomeState();
}

class _AnalyticsHomeState extends State<AnalyticsHome>
    with WidgetsBindingObserver {
  static const base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
  late final _client = widget.client ?? http.Client();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _newPassword = TextEditingController();
  final _question = TextEditingController();
  final _teacher = TextEditingController();
  final _student = TextEditingController();
  final _className = TextEditingController();
  final _subject = TextEditingController();
  final _session = TextEditingController();
  final _event = TextEditingController();
  String? _token, _role;
  String _metric = 'sessions_created';
  String _message = '';
  Map<String, dynamic>? _answer, _healthData;
  bool _busy = false, _changePassword = false, _allTime = false;
  bool _showPassword = false;
  bool _recording = false, _startingRecording = false;
  bool _hasMore = false;
  DateTimeRange? _dates;
  int _page = 1;
  Map<String, dynamic>? _lastIntent;
  final Map<String, int> _selected = {};
  int _captureGeneration = 0;
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _audioStream;
  BytesBuilder? _pcm;
  Timer? _voiceLimit, _contextLimit;
  int _generation = 0;
  int _tab = 0;
  List<Map<String, dynamic>> _daily = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_cancelRecording());
    }
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> _decode(
    http.Response response,
    int generation,
  ) async {
    if (!mounted || generation != _generation) {
      throw StateError('Request context expired.');
    }
    if (response.statusCode == 401) {
      _logout();
      throw StateError('Sign-in expired. Sign in again.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Only explicit human-safe errors from the API, never raw bodies.
      final messages = {
        403: 'This account cannot access the requested data.',
        409:
            'The name is ambiguous or unavailable. Choose a unique permitted name.',
        413: 'Recording is too large.',
        422:
            'Use a supported metric and explicit filters, or clarify your question.',
        429: 'Service is busy. Please retry shortly.',
        503: 'Service is not enabled or unavailable. Try structured filters.',
      };
      throw StateError(
        messages[response.statusCode] ?? 'Request failed. Please retry.',
      );
    }
    final value = jsonDecode(response.body);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response.');
    }
    return value;
  }

  Future<void> _run(Future<void> Function(int) action) async {
    if (_busy) return;
    final generation = _generation;
    setState(() {
      _busy = true;
      _message = '';
    });
    try {
      await action(generation);
    } on StateError catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _message = error.message.toString());
      }
    } on Exception {
      if (mounted && generation == _generation) {
        setState(
          () => _message =
              'Request could not be completed. Check your connection and retry.',
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _login() => _run((generation) async {
    final response = await _client
        .post(
          Uri.parse('$base/auth/login'),
          body: {'username': _phone.text.trim(), 'password': _password.text},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 401) {
      throw StateError('Invalid credentials.');
    }
    final data = await _decode(response, generation);
    if (!{'admin', 'teacher'}.contains(data['role']) ||
        data['access_token'] is! String) {
      throw StateError('Use an administrator or teacher account.');
    }
    if (!mounted || generation != _generation) return;
    setState(() {
      _token = data['access_token'] as String;
      _role = data['role'] as String;
      _changePassword = data['must_change_password'] == true;
      _password.clear();
      _phone.clear();
    });
  });

  Future<void> _change() => _run((generation) async {
    final data = await _decode(
      await _client
          .post(
            Uri.parse('$base/auth/change-password'),
            headers: _headers,
            body: jsonEncode({
              'current_password': _password.text,
              'new_password': _newPassword.text,
            }),
          )
          .timeout(const Duration(seconds: 20)),
      generation,
    );
    if (!mounted || generation != _generation) return;
    setState(() {
      _token = data['access_token'] as String;
      _changePassword = false;
      _password.clear();
      _newPassword.clear();
    });
  });

  void _expireContext() {
    _contextLimit?.cancel();
    _contextLimit = Timer(const Duration(minutes: 5), () {
      if (!mounted) return;
      setState(() {
        _generation++;
        _busy = false;
        _question.clear();
        _answer = null;
        _healthData = null;
        _lastIntent = null;
        _selected.clear();
        _hasMore = false;
        _allTime = false;
        _dates = null;
        _daily = [];
        for (final field in [
          _teacher,
          _student,
          _className,
          _subject,
          _session,
          _event,
        ]) {
          field.clear();
        }
        _message = 'Conversation context cleared after five minutes.';
      });
    });
  }

  Map<String, dynamic> _intent() => {
    'metric': _metric,
    for (final entry in {
      'teacher': _teacher,
      'student': _student,
      'class_name': _className,
      'subject': _subject,
      'session': _session,
      'event_type': _event,
    }.entries)
      if (entry.value.text.trim().isNotEmpty)
        entry.key: entry.value.text.trim(),
    'all_time': _allTime,
    if (_dates != null) ..._dateFilters(),
    'page': _page,
    for (final entry in _selected.entries) '${entry.key}_id': entry.value,
  };

  Map<String, String> _dateFilters() {
    DateTime midnight(DateTime value, [int extraDays = 0]) => DateTime.utc(
      value.year,
      value.month,
      value.day + extraDays,
    ).subtract(const Duration(hours: 5, minutes: 30));
    final now = DateTime.now().toUtc();
    final end = midnight(_dates!.end, 1);
    return {
      'start': midnight(_dates!.start).toIso8601String(),
      'end': (end.isAfter(now) ? now : end).toIso8601String(),
    };
  }

  Future<void> _selectDates() async {
    final generation = _generation;
    final dates = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dates,
      helpText: 'Reporting dates (Asia/Kolkata)',
    );
    if (!mounted || generation != _generation || dates == null) return;
    setState(() {
      _dates = dates;
      _allTime = false;
    });
  }

  Future<void> _query({required bool natural, bool next = false}) =>
      _run((generation) async {
        if (natural && _question.text.trim().isEmpty) {
          throw StateError('Enter or record a question first.');
        }
        if (!next) _page = 1;
        final intent = next ? {...?_lastIntent, 'page': _page} : _intent();
        final data = await _decode(
          await _client
              .post(
                Uri.parse('$base/analytics/query'),
                headers: _headers,
                body: jsonEncode(
                  natural
                      ? {
                          'question': _question.text.trim(),
                          if (_lastIntent != null) 'context': _lastIntent,
                        }
                      : {'intent': intent},
                ),
              )
              .timeout(const Duration(seconds: 40)),
          generation,
        );
        if (!mounted || generation != _generation) return;
        setState(() {
          _lastIntent = data['intent'] is Map<String, dynamic>
              ? data['intent'] as Map<String, dynamic>
              : (natural ? null : intent);
          _hasMore = data['has_more'] == true;
          _answer = data;
        });
        _expireContext();
      });

  Future<void> _health() => _run((generation) async {
    final data = await _decode(
      await _client
          .get(Uri.parse('$base/analytics/health'), headers: _headers)
          .timeout(const Duration(seconds: 15)),
      generation,
    );
    if (!mounted || generation != _generation) return;
    setState(() {
      final daily = data['daily'];
      _daily = daily is List
          ? daily.whereType<Map<String, dynamic>>().take(30).toList()
          : [];
      _healthData = {...data}..remove('daily');
    });
    _expireContext();
  });

  Future<void> _startRecording() async {
    if (_busy || _recording || _startingRecording) return;
    setState(() => _startingRecording = true);
    final generation = _generation;
    final capture = ++_captureGeneration;
    final recorder = AudioRecorder();
    _recorder = recorder;
    try {
      if (!await recorder.hasPermission()) {
        throw StateError(
          'Microphone permission was denied. Type your question instead.',
        );
      }
      if (!mounted ||
          generation != _generation ||
          capture != _captureGeneration) {
        await recorder.dispose();
        return;
      }
      _pcm = BytesBuilder(copy: false);
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      if (!mounted ||
          generation != _generation ||
          capture != _captureGeneration) {
        await recorder.dispose();
        return;
      }
      _audioStream = stream.listen(
        (bytes) {
          if (capture != _captureGeneration || generation != _generation) {
            return;
          }
          if ((_pcm?.length ?? 0) + bytes.length <= 60 * 16000 * 2) {
            _pcm?.add(bytes);
          } else {
            unawaited(_stopRecording());
          }
        },
        onError: (Object error) {
          if (capture != _captureGeneration || generation != _generation) {
            return;
          }
          unawaited(_cancelRecording());
          if (mounted) {
            setState(
              () => _message = 'Microphone failed. Type your question instead.',
            );
          }
        },
      );
      setState(() {
        _recording = true;
        _message = 'Recording. Maximum 60 seconds.';
      });
      _voiceLimit = Timer(
        const Duration(seconds: 60),
        () => unawaited(_stopRecording()),
      );
    } on StateError catch (error) {
      if (capture != _captureGeneration || generation != _generation) return;
      await _cancelRecording();
      if (mounted) setState(() => _message = error.message.toString());
    } on Exception {
      if (capture != _captureGeneration || generation != _generation) return;
      await _cancelRecording();
      if (mounted) {
        setState(
          () =>
              _message = 'Microphone unavailable. Type your question instead.',
        );
      }
    } finally {
      if (mounted && capture == _captureGeneration) {
        setState(() => _startingRecording = false);
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) return;
    final generation = _generation;
    final capture = _captureGeneration;
    _voiceLimit?.cancel();
    setState(() => _recording = false);
    final recorder = _recorder;
    _recorder = null;
    final stream = _audioStream;
    _audioStream = null;
    final pcm = _pcm?.takeBytes() ?? Uint8List(0);
    _pcm = null;
    try {
      try {
        await recorder?.stop();
      } finally {
        try {
          await stream?.cancel();
        } finally {
          await recorder?.dispose();
        }
      }
      if (pcm.isEmpty ||
          !mounted ||
          generation != _generation ||
          capture != _captureGeneration) {
        return;
      }
      await _run((generation) async {
        final request =
            http.Request('POST', Uri.parse('$base/analytics/transcribe'))
              ..headers['Authorization'] = 'Bearer $_token'
              ..headers['Content-Type'] = 'audio/wav'
              ..bodyBytes = wav(pcm);
        final response = await http.Response.fromStream(
          await _client.send(request).timeout(const Duration(seconds: 95)),
        );
        final data = await _decode(response, generation);
        if (!mounted ||
            generation != _generation ||
            capture != _captureGeneration) {
          return;
        }
        setState(() {
          _question.text = data['text'] as String;
          _message =
              'Review and edit the transcript, then select Ask. Nothing was queried automatically.';
        });
        _expireContext();
      });
    } on Exception {
      if (mounted &&
          generation == _generation &&
          capture == _captureGeneration) {
        setState(
          () => _message = 'Recording failed. Type your question instead.',
        );
      }
    } finally {
      pcm.fillRange(0, pcm.length, 0);
    }
  }

  Future<void> _cancelRecording({bool notify = true}) async {
    final capture = ++_captureGeneration;
    _voiceLimit?.cancel();
    final stream = _audioStream;
    _audioStream = null;
    final recorder = _recorder;
    _recorder = null;
    final pcm = _pcm;
    _pcm = null;
    if (mounted && notify) {
      setState(() {
        _recording = false;
        _startingRecording = false;
      });
    }
    try {
      try {
        await stream?.cancel();
      } finally {
        if (recorder != null) {
          try {
            await recorder.cancel();
          } finally {
            await recorder.dispose();
          }
        }
      }
    } on Exception {
      if (mounted && notify && capture == _captureGeneration) {
        setState(
          () => _message =
              'Microphone cleanup failed. Check device microphone permissions.',
        );
      }
    } finally {
      pcm?.clear();
    }
  }

  void _logout() {
    _generation++;
    _contextLimit?.cancel();
    unawaited(_cancelRecording());
    setState(() {
      _token = null;
      _busy = false;
      _role = null;
      _changePassword = false;
      _question.clear();
      _password.clear();
      _newPassword.clear();
      _showPassword = false;
      _answer = null;
      _healthData = null;
      _lastIntent = null;
      _selected.clear();
      _hasMore = false;
      _allTime = false;
      _dates = null;
      _tab = 0;
      _daily = [];
      for (final field in [
        _teacher,
        _student,
        _className,
        _subject,
        _session,
        _event,
      ]) {
        field.clear();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _contextLimit?.cancel();
    unawaited(_cancelRecording(notify: false));
    _client.close();
    for (final field in [
      _phone,
      _password,
      _newPassword,
      _question,
      _teacher,
      _student,
      _className,
      _subject,
      _session,
      _event,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  bool get _isAdmin => _role == 'admin';

  Widget _field(
    String label,
    TextEditingController controller, {
    bool secret = false,
    IconData? icon,
    TextInputType? keyboard,
    Iterable<String>? autofill,
    TextInputAction? action,
    VoidCallback? onSubmitted,
    String? helper,
  }) => TextField(
    controller: controller,
    obscureText: secret && !_showPassword,
    keyboardType: keyboard,
    autofillHints: autofill,
    textInputAction: action,
    onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: secret
          ? IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            )
          : null,
    ),
  );

  Widget _entityField(
    String label,
    String key,
    String kind,
    TextEditingController field,
    IconData icon, {
    String? helper,
  }) => Autocomplete<Map<String, dynamic>>(
    key: ValueKey('$_generation/$key'),
    initialValue: TextEditingValue(text: field.text),
    displayStringForOption: (option) => option['label'] as String,
    optionsViewBuilder: (context, choose, choices) {
      final items = choices.toList(growable: false);
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final option = items[index];
                return ListTile(
                  title: Text('${index + 1}. ${option['label']}'),
                  subtitle:
                      option['context'] is String &&
                          (option['context'] as String).isNotEmpty
                      ? Text(option['context'] as String)
                      : null,
                  onTap: () => choose(option),
                );
              },
            ),
          ),
        ),
      );
    },
    optionsBuilder: (value) async {
      if (value.text.trim().length < 2 || _token == null) return const [];
      final generation = _generation;
      try {
        final response = await _client
            .get(
              Uri.parse('$base/analytics/catalog').replace(
                queryParameters: {'kind': kind, 'search': value.text.trim()},
              ),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));
        final data = await _decode(response, generation);
        if (!mounted || generation != _generation) return const [];
        final items = data['items'];
        if (items is! List) throw const FormatException('Invalid catalog');
        return items.whereType<Map<String, dynamic>>();
      } on StateError catch (error) {
        if (mounted && generation == _generation) {
          setState(() => _message = error.message.toString());
        }
        return const [];
      } on Exception {
        if (mounted && generation == _generation) {
          setState(
            () => _message =
                'Name lookup unavailable. Enter an exact permitted name.',
          );
        }
        return const [];
      }
    },
    onSelected: (option) {
      field.text = option['label'] as String;
      _selected[key] = option['id'] as int;
    },
    fieldViewBuilder: (context, controller, focus, submit) => TextField(
      controller: controller,
      focusNode: focus,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        prefixIcon: Icon(icon),
      ),
      onChanged: (value) {
        field.text = value;
        _selected.remove(key);
      },
      onSubmitted: (_) => submit(),
    ),
  );

  /// Scrollable page whose content is centred and capped at [maxWidth].
  Widget _scrollPage({
    required double maxWidth,
    required List<Widget> children,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = constraints.maxWidth < 600 ? 12.0 : 24.0;
      final side = constraints.maxWidth > maxWidth + 2 * gutter
          ? (constraints.maxWidth - maxWidth) / 2
          : gutter;
      return ListView(
        padding: EdgeInsets.fromLTRB(side, gutter, side, gutter + 8),
        children: children,
      );
    },
  );

  /// Lays children out in equal columns that collapse to one on phones.
  Widget _grid(
    List<Widget> children, {
    double minTileWidth = 260,
    int maxColumns = 2,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 12.0;
      final columns = ((constraints.maxWidth + gap) / (minTileWidth + gap))
          .floor()
          .clamp(1, maxColumns);
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );

  Widget _section({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _messageBanner() {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: scheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _message,
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  icon: const Icon(Icons.close),
                  color: scheme.onSecondaryContainer,
                  onPressed: () => setState(() => _message = ''),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {IconData? icon, Color? color}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(String text) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }

  List<Widget> _spaced(List<Widget> children, double gap) => [
    for (final (index, child) in children.indexed) ...[
      if (index > 0) SizedBox(height: gap),
      child,
    ],
  ];

  Widget _authCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return _scrollPage(
      maxWidth: 440,
      children: [
        const SizedBox(height: 16),
        if (_message.isNotEmpty) _messageBanner(),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        icon,
                        size: 28,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._spaced(children, 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signInView() => _authCard(
    icon: Icons.insights,
    title: 'Welcome',
    subtitle: 'Use your campus administrator or teacher account.',
    children: [
      _field(
        'Phone number',
        _phone,
        icon: Icons.phone_outlined,
        keyboard: TextInputType.phone,
        autofill: const [AutofillHints.telephoneNumber],
        action: TextInputAction.next,
      ),
      _field(
        'Password',
        _password,
        secret: true,
        icon: Icons.lock_outline,
        autofill: const [AutofillHints.password],
        action: TextInputAction.done,
        onSubmitted: _login,
      ),
      FilledButton(
        onPressed: _busy ? null : _login,
        child: const Text('Sign in'),
      ),
    ],
  );

  Widget _changePasswordView() => _authCard(
    icon: Icons.password,
    title: 'Set a new password',
    subtitle: 'Change your temporary password before continuing.',
    children: [
      _field(
        'Temporary password',
        _password,
        secret: true,
        icon: Icons.lock_outline,
        autofill: const [AutofillHints.password],
        action: TextInputAction.next,
      ),
      _field(
        'New password',
        _newPassword,
        secret: true,
        icon: Icons.lock_reset,
        autofill: const [AutofillHints.newPassword],
        action: TextInputAction.done,
        onSubmitted: _change,
      ),
      FilledButton(
        onPressed: _busy ? null : _change,
        child: const Text('Change password'),
      ),
    ],
  );

  Widget _askCard() => _section(
    icon: Icons.question_answer_outlined,
    title: 'Ask a question',
    subtitle:
        'Use names, e.g. "How many sessions were created by Teacher X for Science and Class 6?"',
    children: [
      TextField(
        controller: _question,
        onChanged: (_) => _expireContext(),
        maxLength: 2000,
        minLines: 2,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          labelText: 'English question / editable transcript',
          alignLabelWithHint: true,
        ),
      ),
      if (_recording)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.fiber_manual_record,
                size: 14,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              const Text('Recording… up to 60 seconds'),
            ],
          ),
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: _busy || _recording ? null : () => _query(natural: true),
            icon: const Icon(Icons.send),
            label: const Text('Ask'),
          ),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : _recording
                ? _stopRecording
                : _startRecording,
            icon: Icon(_recording ? Icons.stop : Icons.mic_none),
            label: Text(
              _recording ? 'Stop and transcribe' : 'Record English question',
            ),
          ),
          if (_recording)
            TextButton(
              onPressed: _cancelRecording,
              child: const Text('Cancel recording'),
            ),
        ],
      ),
    ],
  );

  Widget _filtersCard() => Card(
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
      title: const Text(
        'Structured filters',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Run an exact metric — works without a model'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _metric,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Metric',
            prefixIcon: Icon(Icons.bar_chart),
          ),
          items: [
            for (final entry in _metrics.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: (value) => setState(() => _metric = value!),
        ),
        const SizedBox(height: 12),
        _grid([
          _entityField(
            'Teacher name',
            'teacher',
            'teacher',
            _teacher,
            Icons.person_outline,
          ),
          _entityField(
            'Student name',
            'student',
            'student',
            _student,
            Icons.school_outlined,
            helper: 'Attendance, quiz or activity',
          ),
          _entityField(
            'Class name',
            'class_name',
            'class',
            _className,
            Icons.groups_outlined,
          ),
          _entityField(
            'Subject name',
            'subject',
            'subject',
            _subject,
            Icons.menu_book_outlined,
          ),
          _entityField(
            'Session title',
            'session',
            'session',
            _session,
            Icons.event_note_outlined,
            helper: 'Attendance or activity',
          ),
          _field(
            'Event type',
            _event,
            icon: Icons.label_outline,
            helper: 'Activity only',
          ),
        ]),
        const SizedBox(height: 16),
        Text('Reporting period', style: Theme.of(context).textTheme.titleSmall),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _allTime,
          title: const Text('All retained educational history'),
          subtitle: const Text('Otherwise the last 30 days'),
          onChanged: (value) => setState(() {
            _allTime = value;
            if (_allTime) _dates = null;
          }),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _busy ? null : _selectDates,
              icon: const Icon(Icons.date_range),
              label: Text(
                _dates == null
                    ? 'Choose dates (Asia/Kolkata)'
                    : '${_day(_dates!.start)} to ${_day(_dates!.end)}',
              ),
            ),
            if (_dates != null)
              TextButton(
                onPressed: () => setState(() => _dates = null),
                child: const Text('Use default last 30 days'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy || _recording ? null : () => _query(natural: false),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Run metric'),
        ),
      ],
    ),
  );

  Widget _resultsCard({required bool showPlaceholder}) {
    final data = _answer;
    final theme = Theme.of(context);
    if (data == null) {
      if (!showPlaceholder) return const SizedBox.shrink();
      return _section(
        icon: Icons.insights,
        title: 'Results',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(
                  Icons.query_stats,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'Ask a question or run a metric to see results here.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final filters = data['filters'];
    final rows = (data['rows'] as List? ?? []).whereType<Map>().toList();
    final metric = _lastIntent?['metric'];
    return _section(
      icon: Icons.insights,
      title: 'Results',
      subtitle: metric is String ? _metrics[metric] ?? _labelFor(metric) : null,
      children: [
        if (data['answer'] is String) ...[
          SelectableText(
            data['answer'] as String,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
        ],
        _grid([
          _stat('Sample / count', _display(data['count']), icon: Icons.numbers),
          _stat('As of', _display(data['as_of']), icon: Icons.schedule),
        ], minTileWidth: 140),
        if (filters is Map && filters.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Scope', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in filters.entries)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    '${_labelFor('${entry.key}')}: ${_display(entry.value)}',
                  ),
                ),
            ],
          ),
        ] else if (filters != null && filters is! Map) ...[
          const SizedBox(height: 16),
          Text('Scope: ${_display(filters)}'),
        ],
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Activity groups', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final row in rows)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(_display(row['event_type'])),
              subtitle: Text(_display(row['source'])),
              trailing: Text(
                _display(row['count']),
                style: theme.textTheme.titleSmall,
              ),
            ),
        ],
        if (_hasMore && metric == 'activity_counts') ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () {
                    _page++;
                    _query(natural: false, next: true);
                  },
            icon: const Icon(Icons.navigate_next),
            label: const Text('Next 100 activity groups'),
          ),
        ],
        if (data['coverage'] is String) ...[
          const SizedBox(height: 16),
          _note(data['coverage'] as String),
        ],
      ],
    );
  }

  Widget _queriesView() => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 960) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _askCard(),
                  const SizedBox(height: 16),
                  _filtersCard(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: _resultsCard(showPlaceholder: true)),
          ],
        );
      }
      // On phones the result sits right under the question so it is visible
      // without scrolling past the filters.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _spaced([
          _askCard(),
          if (_answer != null) _resultsCard(showPlaceholder: false),
          _filtersCard(),
        ], 16),
      );
    },
  );

  Widget _healthView() {
    final theme = Theme.of(context);
    final data = _healthData ?? const <String, dynamic>{};
    const statusKeys = {
      'database': 'Database',
      'collection_enabled': 'Activity collection',
      'model_enabled': 'Language model',
      'runtime': 'Model runtime',
      'speech_enabled': 'Speech transcription',
      'smtp_configured': 'Alert email (SMTP)',
    };
    const otherHandled = {
      'diagnostics',
      'maintenance',
      'chart_coverage',
      'deployment_gates',
    };
    bool healthy(Object? value) =>
        value == true || value == 'reachable' || value == 'ok';
    num count(Object? value) => value is num ? value : 0;
    final maxRequests = _daily.fold<num>(
      1,
      (maximum, row) => max(maximum, count(row['requests'])),
    );
    final diagnostics = data['diagnostics'];
    final maintenance = (data['maintenance'] as List? ?? [])
        .whereType<Map>()
        .toList();
    final gates = (data['deployment_gates'] as List? ?? [])
        .map(_display)
        .toList();
    final details = {
      if (diagnostics is Map) ...diagnostics,
      for (final entry in data.entries)
        if (!statusKeys.containsKey(entry.key) &&
            !otherHandled.contains(entry.key))
          entry.key: entry.value,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _spaced([
        _section(
          icon: Icons.monitor_heart_outlined,
          title: 'System status',
          subtitle: 'Loaded on selection or refresh only.',
          trailing: IconButton(
            tooltip: 'Refresh health',
            onPressed: _busy ? null : _health,
            icon: const Icon(Icons.refresh),
          ),
          children: [
            if (data.isEmpty)
              Text(_busy ? 'Loading…' : 'No health data loaded yet.')
            else
              _grid(
                [
                  for (final entry in statusKeys.entries)
                    if (data.containsKey(entry.key))
                      _stat(
                        entry.value,
                        _display(data[entry.key]),
                        icon: entry.key == 'runtime'
                            ? Icons.memory
                            : healthy(data[entry.key])
                            ? Icons.check_circle
                            : Icons.remove_circle_outline,
                        color:
                            entry.key == 'runtime' || healthy(data[entry.key])
                            ? null
                            : theme.colorScheme.outline,
                      ),
                ],
                minTileWidth: 140,
                maxColumns: 3,
              ),
          ],
        ),
        if (_daily.isNotEmpty)
          _section(
            icon: Icons.show_chart,
            title: 'Requests and backend errors by day',
            subtitle: 'Asia/Kolkata',
            children: [
              for (final point in _daily)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          _display(point['day']),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: count(point['requests']) / maxRequests,
                            semanticsLabel: 'Relative daily request volume',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${point['requests']} req · ${point['errors'] ?? 0} err',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: count(point['errors']) > 0
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              if (data['chart_coverage'] is String) ...[
                const SizedBox(height: 8),
                _note(data['chart_coverage'] as String),
              ],
            ],
          ),
        if (maintenance.isNotEmpty)
          _section(
            icon: Icons.build_outlined,
            title: 'Maintenance jobs',
            children: [
              for (final job in maintenance)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_display(job['name'])),
                  subtitle: Text(
                    'Last success: ${_display(job['succeeded_at'])} · '
                    'Count: ${_display(job['count'])}',
                  ),
                  trailing: Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(_display(job['status'])),
                  ),
                ),
            ],
          ),
        if (details.isNotEmpty)
          _section(
            icon: Icons.list_alt,
            title: 'Diagnostics',
            children: [
              for (final entry in details.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _labelFor('${entry.key}'),
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: SelectableText(_display(entry.value))),
                    ],
                  ),
                ),
            ],
          ),
        if (gates.isNotEmpty)
          _section(
            icon: Icons.checklist,
            title: 'Deployment gates',
            children: [
              for (final gate in gates)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.radio_button_unchecked, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(gate)),
                    ],
                  ),
                ),
            ],
          ),
      ], 16),
    );
  }

  Widget _dashboardView() => _scrollPage(
    maxWidth: 1200,
    children: [
      if (_message.isNotEmpty) _messageBanner(),
      if (_tab == 1 && _isAdmin) _healthView() else _queriesView(),
      const SizedBox(height: 24),
      _note(
        'Read-only. Logs cover 30 days; educational history expires after 18 months. '
        'Questions, answers and voice transcripts are not saved and clear after five minutes.',
      ),
    ],
  );

  void _selectTab(int index) {
    setState(() => _tab = index);
    if (index == 1) unawaited(_health());
  }

  PreferredSizeWidget _appBar(double width) {
    final theme = Theme.of(context);
    return AppBar(
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Flexible(
            child: Text('SEEDS Analytics', overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      actions: [
        if (_token != null && _role != null && width >= 480)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              visualDensity: VisualDensity.compact,
              avatar: Icon(
                _isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.school_outlined,
                size: 18,
              ),
              label: Text(_isAdmin ? 'Administrator' : 'Teacher'),
            ),
          ),
        if (_token != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: _busy
            ? const LinearProgressIndicator(minHeight: 3)
            : const SizedBox(height: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final navigation = _token != null && !_changePassword && _isAdmin;
      final wide = width >= 840;
      final body = SafeArea(
        child: _token == null
            ? _signInView()
            : _changePassword
            ? _changePasswordView()
            : _dashboardView(),
      );
      const destinations = [
        (Icons.query_stats_outlined, Icons.query_stats, 'Queries'),
        (Icons.monitor_heart_outlined, Icons.monitor_heart, 'Health'),
      ];
      return Scaffold(
        appBar: _appBar(width),
        body: navigation && wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _tab,
                    onDestinationSelected: _selectTab,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final (icon, selected, label) in destinations)
                        NavigationRailDestination(
                          icon: Icon(icon),
                          selectedIcon: Icon(selected),
                          label: Text(label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              )
            : body,
        bottomNavigationBar: navigation && !wide
            ? NavigationBar(
                selectedIndex: _tab,
                onDestinationSelected: _selectTab,
                destinations: [
                  for (final (icon, selected, label) in destinations)
                    NavigationDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selected),
                      label: label,
                    ),
                ],
              )
            : null,
      );
    },
  );
}

Uint8List wav(Uint8List pcm) {
  final result = Uint8List(44 + pcm.length);
  final header = ByteData.sublistView(result);
  void ascii(int at, String value) =>
      result.setRange(at, at + value.length, value.codeUnits);
  ascii(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, 16000, Endian.little);
  header.setUint32(28, 32000, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  result.setRange(44, result.length, pcm);
  return result;
}
