import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/speech.dart';
import '../services/auth_session_service.dart';
import 'admin/accounts_section.dart';
import 'admin/authoring_section.dart';
import 'admin/catalog_section.dart';
import 'admin/class_records_section.dart';
import 'admin/holidays_section.dart';
import 'admin/issues_section.dart';
import 'admin/schedule_section.dart';
import 'admin/shared_phones_section.dart';
import 'admin/timetable_section.dart';

enum AdminSection {
  accounts,
  catalog,
  timetable,
  schedule,
  sharedPhones,
  holidays,
  issues,
  records,
  authoring,
}

/// School administration: people, classes and subjects, timetable, shared
/// phones, holidays, issues, class records, and quizzes and journeys made
/// for a teacher. A conventional Material
/// layout: a navigation rail on wide screens, a section menu on narrow ones.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    this.initialSection = AdminSection.accounts,
  });

  final AdminSection initialSection;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late AdminSection _section = widget.initialSection;
  int _reloads = 0;

  static const _wideLayout = 840.0;

  String _label(AdminSection section) {
    final t = Speech.t;
    return switch (section) {
      AdminSection.accounts => t.adminSetupSectionAccounts,
      AdminSection.catalog => t.adminSetupSectionCatalog,
      AdminSection.timetable => t.adminSetupSectionTimetable,
      AdminSection.schedule => t.adminSetupSectionSchedule,
      AdminSection.sharedPhones => t.adminSetupSectionSharedPhones,
      AdminSection.holidays => t.adminSetupSectionHolidays,
      AdminSection.issues => t.adminSetupSectionIssues,
      AdminSection.records => t.adminSetupSectionRecords,
      AdminSection.authoring => t.adminAuthorSection,
    };
  }

  IconData _icon(AdminSection section) => switch (section) {
    AdminSection.accounts => Icons.people_outline,
    AdminSection.catalog => Icons.class_outlined,
    AdminSection.timetable => Icons.calendar_view_week,
    AdminSection.schedule => Icons.today,
    AdminSection.sharedPhones => Icons.phone_android,
    AdminSection.holidays => Icons.event_busy,
    AdminSection.issues => Icons.report_problem_outlined,
    AdminSection.records => Icons.history,
    AdminSection.authoring => Icons.assignment_outlined,
  };

  Widget _content() => switch (_section) {
    AdminSection.accounts => const AccountsSection(),
    AdminSection.catalog => const CatalogSection(),
    AdminSection.timetable => const TimetableSection(),
    AdminSection.schedule => const ScheduleSection(),
    AdminSection.sharedPhones => const SharedPhonesSection(),
    AdminSection.holidays => const HolidaysSection(),
    AdminSection.issues => const IssuesSection(),
    AdminSection.records => const ClassRecordsSection(),
    AdminSection.authoring => const AuthoringSection(),
  };

  void _select(AdminSection section) => setState(() => _section = section);

  Widget _rail(BoxConstraints constraints) => SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      child: IntrinsicHeight(
        child: NavigationRail(
          selectedIndex: _section.index,
          labelType: NavigationRailLabelType.all,
          onDestinationSelected: (index) => _select(AdminSection.values[index]),
          destinations: [
            for (final section in AdminSection.values)
              NavigationRailDestination(
                icon: Icon(_icon(section)),
                label: Text(_label(section), textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _sectionMenu() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: DropdownButtonFormField<AdminSection>(
      key: ValueKey(_section),
      initialValue: _section,
      isExpanded: true,
      decoration: InputDecoration(labelText: Speech.t.adminSetupSectionPicker),
      items: [
        for (final section in AdminSection.values)
          DropdownMenuItem(
            value: section,
            child: Row(
              children: [
                ExcludeSemantics(child: Icon(_icon(section))),
                const SizedBox(width: 12),
                Flexible(child: Text(_label(section))),
              ],
            ),
          ),
      ],
      onChanged: (section) {
        if (section != null) _select(section);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final content = KeyedSubtree(
      key: ValueKey('${_section.name}-$_reloads'),
      child: _content(),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminAppBarTitle),
          actions: [
            IconButton(
              onPressed: () => setState(() => _reloads++),
              icon: const Icon(Icons.refresh),
              tooltip: t.adminSetupRefresh(_label(_section)),
            ),
            IconButton(
              onPressed: () => AuthSessionService.logoutFrom(context),
              icon: const Icon(Icons.logout),
              tooltip: t.adminSetupLogOut,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth >= _wideLayout
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _rail(constraints),
                      const VerticalDivider(width: 1),
                      Expanded(child: content),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionMenu(),
                      Expanded(child: content),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
