import 'package:flutter/material.dart';

import '../../l10n/speech.dart';
import '../../services/admin_setup_api.dart';
import 'admin_common.dart';

/// Problems the server noticed (for example a lesson that never started).
class IssuesSection extends StatefulWidget {
  const IssuesSection({super.key});

  @override
  State<IssuesSection> createState() => _IssuesSectionState();
}

class _IssuesSectionState extends State<IssuesSection> {
  List<JsonMap> _issues = const [];
  String _status = 'open';
  bool _loading = true;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AdminSetupApi.issues(_status);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _issues = result.data!;
      } else {
        _error = Speech.t.adminSetupLoadFailed(
          AdminSetupApi.errorText(result.failure),
        );
      }
    });
  }

  Future<void> _resolve(JsonMap issue) async {
    final result = await AdminSetupApi.resolveIssue(issue['issue_id'] as int);
    if (!mounted) return;
    if (adminReport(result, Speech.t.adminSetupIssueResolved)) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    return AdminSectionBody(
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyText: t.adminSetupNoIssues,
      header: [
        AdminChoiceChips<String>(
          heading: t.adminSetupShowFilter,
          options: [
            ('open', t.adminSetupIssuesOpen),
            ('resolved', t.adminSetupIssuesResolved),
            ('all', t.adminSetupFilterAll),
          ],
          selected: _status,
          onSelected: (value) {
            setState(() => _status = value);
            _load();
          },
        ),
      ],
      items: [
        for (final issue in _issues)
          AdminItemCard(
            title: '${issue['message']}',
            status: issue['status'] == 'resolved'
                ? t.adminSetupIssuesResolved
                : t.adminSetupIssuesOpen,
            lines: [
              t.adminSetupIssueSeen(
                (issue['occurrences'] as num?)?.toInt() ?? 1,
                adminTimestampText(issue['last_seen_at']),
              ),
            ],
            actions: [
              if (issue['status'] != 'resolved')
                AdminActionButton(
                  label: t.adminSetupMarkResolved,
                  semanticLabel: t.adminSetupMarkResolvedNamed(
                    '${issue['message']}',
                  ),
                  icon: Icons.check,
                  onPressed: () => _resolve(issue),
                ),
            ],
          ),
      ],
    );
  }
}
