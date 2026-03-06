import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Dashboard screen for viewing session activity logs.
/// Matches the existing indigo design from teacher_dashboard.dart.
class SessionLogsScreen extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;

  const SessionLogsScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  State<SessionLogsScreen> createState() => _SessionLogsScreenState();
}

class _SessionLogsScreenState extends State<SessionLogsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? summary;
  List<dynamic> logs = [];
  String? selectedEventType;

  // Map event types to icons and colors
  static final Map<String, IconData> _eventIcons = {
    'session_created': Icons.add_circle,
    'session_ended': Icons.stop_circle,
    'participant_joined': Icons.person_add,
    'participant_left': Icons.person_remove,
    'participant_kicked': Icons.person_off,
    'participant_invited': Icons.mail,
    'participant_muted': Icons.mic_off,
    'participant_unmuted': Icons.mic,
    'hand_raised': Icons.pan_tool,
    'hand_lowered': Icons.pan_tool_alt,
    'chat_message': Icons.chat_bubble,
    'audio_uploaded': Icons.upload_file,
    'audio_selected': Icons.audiotrack,
    'audio_play': Icons.play_arrow,
    'audio_pause': Icons.pause,
    'audio_seek': Icons.fast_forward,
  };

  static final Map<String, Color> _eventColors = {
    'session_created': Colors.green,
    'session_ended': Colors.red,
    'participant_joined': Colors.blue,
    'participant_left': Colors.orange,
    'participant_kicked': Colors.red.shade700,
    'participant_invited': Colors.teal,
    'participant_muted': Colors.grey.shade700,
    'participant_unmuted': Colors.green.shade600,
    'hand_raised': Colors.amber.shade700,
    'hand_lowered': Colors.amber.shade400,
    'chat_message': Colors.indigo,
    'audio_uploaded': Colors.purple,
    'audio_selected': Colors.deepPurple,
    'audio_play': Colors.green.shade700,
    'audio_pause': Colors.orange.shade700,
    'audio_seek': Colors.cyan.shade700,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // Fetch summary and logs in parallel
    final results = await Future.wait([
      ApiService.getSessionLogsSummary(widget.sessionId),
      ApiService.getSessionLogs(
        widget.sessionId,
        eventType: selectedEventType,
        limit: 500,
      ),
    ]);

    if (mounted) {
      setState(() {
        summary = results[0];
        final logsResult = results[1];
        logs = logsResult?['logs'] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _filterByEventType(String? eventType) async {
    setState(() {
      selectedEventType = eventType;
      isLoading = true;
    });

    final result = await ApiService.getSessionLogs(
      widget.sessionId,
      eventType: eventType,
      limit: 500,
    );

    if (mounted) {
      setState(() {
        logs = (result?['logs'] ?? []) as List;
        isLoading = false;
      });
    }
  }

  String _formatTimestamp(String? ts) {
    if (ts == null || ts.isEmpty) return '';
    try {
      final dt = DateTime.parse(ts);
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final sec = dt.second.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month/${dt.year}  $hour:$min:$sec';
    } catch (_) {
      return ts;
    }
  }

  String _formatEventType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  String _formatEventDetails(Map<String, dynamic>? details) {
    if (details == null || details.isEmpty) return '';
    final parts = <String>[];
    details.forEach((key, value) {
      if (value != null) {
        final label = key.replaceAll('_', ' ');
        parts.add('$label: $value');
      }
    });
    return parts.join('  •  ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sessionTitle,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Logs",
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary card
                        _buildSummaryCard(),
                        const SizedBox(height: 16),

                        // Filter chips
                        _buildFilterChips(),
                        const SizedBox(height: 16),

                        // Logs header
                        Row(
                          children: [
                            const Text(
                              "Activity Log",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${logs.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (selectedEventType != null) ...[
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => _filterByEventType(null),
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text("Clear Filter"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.indigo,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Log entries
                        if (logs.isEmpty)
                          _buildEmptyState()
                        else
                          ...logs.map((log) => _buildLogEntry(log)),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    if (summary == null) {
      return Card(
        elevation: 4,
        color: Colors.indigo.shade50,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Unable to load summary"),
        ),
      );
    }

    final totalEvents = summary!['total_events'] ?? 0;
    final uniqueJoined = summary!['unique_participants_joined'] ?? 0;
    final participantsLeft = summary!['participants_left'] ?? 0;
    final eventCounts = summary!['event_counts'] as Map<String, dynamic>? ?? {};
    final firstEvent = _formatTimestamp(summary!['first_event']);
    final lastEvent = _formatTimestamp(summary!['last_event']);

    return Card(
      elevation: 4,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.indigo.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "Session Summary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _buildStatChip(
                  Icons.event_note,
                  '$totalEvents',
                  'Events',
                  Colors.indigo,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Icons.person_add,
                  '$uniqueJoined',
                  'Joined',
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Icons.person_remove,
                  '$participantsLeft',
                  'Left',
                  Colors.orange,
                ),
              ],
            ),

            if (firstEvent.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'First event: $firstEvent',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (lastEvent.isNotEmpty)
              Text(
                'Last event: $lastEvent',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

            // Event type breakdown
            if (eventCounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                "Event Breakdown",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: eventCounts.entries.map((e) {
                  return Chip(
                    avatar: Icon(
                      _eventIcons[e.key] ?? Icons.circle,
                      size: 16,
                      color: _eventColors[e.key] ?? Colors.grey,
                    ),
                    label: Text(
                      '${_formatEventType(e.key)}: ${e.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final eventCounts =
        summary?['event_counts'] as Map<String, dynamic>? ?? {};
    if (eventCounts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: eventCounts.keys.map((type) {
          final isSelected = selectedEventType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _formatEventType(type),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              selected: isSelected,
              selectedColor: _eventColors[type] ?? Colors.indigo,
              backgroundColor: Colors.grey.shade100,
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                _filterByEventType(selected ? type : null);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogEntry(dynamic log) {
    final eventType = log['event_type'] ?? 'unknown';
    final userId = log['user_id'];
    final details = log['event_details'] as Map<String, dynamic>?;
    final timestamp = _formatTimestamp(log['created_at']);
    final icon = _eventIcons[eventType] ?? Icons.circle;
    final color = _eventColors[eventType] ?? Colors.grey;
    final detailsText = _formatEventDetails(details);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),

            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatEventType(eventType),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (userId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'User $userId',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (detailsText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        detailsText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              selectedEventType != null
                  ? "No ${_formatEventType(selectedEventType!)} events"
                  : "No activity logs yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedEventType != null
                  ? "Try clearing the filter"
                  : "Logs will appear once session activity begins",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
