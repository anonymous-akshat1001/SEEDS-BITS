import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/speech.dart';
import '../services/feedback_cues.dart';
import '../services/tts_service.dart';
import 'key_instruction_wrapper.dart';
import 'keypad_text_step.dart';
import 'numbered_menu.dart';

class KeypadListQuery {
  const KeypadListQuery({this.search = '', this.cursor});

  static const pageSize = 5;
  final String search;
  final String? cursor;
}

class KeypadListPage<T> {
  KeypadListPage({required List<T> items, this.nextCursor})
    : items = List.unmodifiable(items) {
    if (items.length > KeypadListQuery.pageSize ||
        (nextCursor != null && (items.isEmpty || nextCursor!.isEmpty))) {
      throw const FormatException('Invalid numbered list page.');
    }
  }

  final List<T> items;
  final String? nextCursor;
}

class KeypadListException implements Exception {
  const KeypadListException(this.message);
  final String message;
}

class KeypadPagedList<T> extends StatefulWidget {
  const KeypadPagedList({
    super.key,
    required this.title,
    required this.scope,
    required this.loadPage,
    required this.labelOf,
    required this.onSelected,
    this.onBack,
    this.onFilters,
  });

  final String title;
  final Object scope;
  final Future<KeypadListPage<T>> Function(KeypadListQuery) loadPage;
  final String Function(T) labelOf;
  final void Function(T) onSelected;
  final VoidCallback? onBack;
  final VoidCallback? onFilters;

  @override
  State<KeypadPagedList<T>> createState() => _KeypadPagedListState<T>();
}

class _KeypadPagedListState<T> extends State<KeypadPagedList<T>> {
  final _nodes = List.generate(
    10,
    (index) => FocusNode(debugLabel: 'list-key-$index'),
  );
  final _cursors = <String?>[null];
  KeypadListPage<T>? _page;
  KeypadListQuery? _failedQuery;
  int _index = 0;
  int _generation = 0;
  bool _loading = false;
  String _search = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load(const KeypadListQuery(), 0));
  }

  @override
  void didUpdateWidget(covariant KeypadPagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scope != oldWidget.scope) {
      _generation++;
      _page = null;
      _search = '';
      _index = 0;
      _cursors
        ..clear()
        ..add(null);
      unawaited(_load(const KeypadListQuery(), 0));
    }
  }

  void _announce(String text) {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    unawaited(TtsService.speak(text));
  }

  Future<void> _load(KeypadListQuery query, int index) async {
    if (!mounted) return;
    final generation = ++_generation;
    final loader = widget.loadPage;
    setState(() {
      _loading = true;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation && _loading) {
        unawaited(FeedbackCues.play(Cue.loading));
        _announce(Speech.t.uiListLoading(widget.title));
      }
    });
    try {
      final page = await loader(query);
      if (!mounted || generation != _generation) return;
      if (page.nextCursor != null &&
          _cursors.take(index + 1).contains(page.nextCursor)) {
        throw const FormatException('List cursor did not advance.');
      }
      setState(() {
        if (index == 0) {
          _cursors
            ..clear()
            ..add(null);
        }
        _page = page;
        _index = index;
        _search = query.search;
        _failedQuery = null;
        _loading = false;
      });
      final t = Speech.t;
      _announce(
        [
          t.uiListPage(widget.title, '${index + 1}'),
          page.items.isEmpty
              ? t.uiListNoMatches
              : [
                  for (var i = 0; i < page.items.length; i++)
                    t.uiPressFor('${i + 1}', widget.labelOf(page.items[i])),
                ].join(' '),
          t.uiListHelp,
        ].join(' '),
      );
    } on Exception catch (error) {
      if (!mounted || generation != _generation) return;
      debugPrint('[PAGED LIST] Load failed (${error.runtimeType}).');
      final message = error is KeypadListException
          ? error.message
          : Speech.t.uiListLoadFailed;
      setState(() {
        _failedQuery = query;
        _error = message;
        _loading = false;
      });
      _announce(message);
    }
  }

  void _select(int index) {
    if (_loading) {
      _announce(Speech.t.uiListLoadingWait);
      return;
    }
    final page = _page;
    if (page != null && index < page.items.length) {
      widget.onSelected(page.items[index]);
    } else {
      _announce(Speech.t.uiListNoItem('${index + 1}'));
    }
  }

  void _move(bool next) {
    if (_loading) return;
    if (!next && _index == 0) {
      unawaited(FeedbackCues.play(Cue.endOfList));
      _announce(Speech.t.uiListFirstPage);
      return;
    }
    final cursor = next ? _page?.nextCursor : _cursors[_index - 1];
    if (next && cursor == null) {
      unawaited(FeedbackCues.play(Cue.endOfList));
      _announce(Speech.t.uiListLastPage);
      return;
    }
    final index = _index + (next ? 1 : -1);
    if (next) {
      if (_cursors.length > index) {
        _cursors.removeRange(index, _cursors.length);
      }
      _cursors.add(cursor);
    }
    unawaited(_load(KeypadListQuery(search: _search, cursor: cursor), index));
  }

  void _back() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }

  Future<void> _openSearch() async {
    if (_loading) return;
    final scope = widget.scope;
    final input = TextEditingController(text: _search);
    final route = MaterialPageRoute<String>(
      builder: (context) => KeypadTextStep(
        title: Speech.t.uiListSearchTitle(widget.title),
        label: Speech.t.uiListSearchLabel,
        controller: input,
        validate: (value) => value.trim().length > 200
            ? Speech.t.uiListSearchTooLong
            : null,
        onContinue: (value) async => Navigator.pop(context, value.trim()),
      ),
    );
    final query = await Navigator.of(context).push(route);
    await route.completed;
    input.dispose();
    if (!mounted || scope != widget.scope || query == null) return;
    await _load(KeypadListQuery(search: query), 0);
  }

  void _retry() {
    final query =
        _failedQuery ??
        KeypadListQuery(search: _search, cursor: _cursors[_index]);
    final index = query.search != _search ? 0 : _cursors.indexOf(query.cursor);
    unawaited(_load(query, index < 0 ? 0 : index));
  }

  void _options() {
    if (_loading) return;
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (context) {
            void run(VoidCallback action) {
              Navigator.pop(context);
              action();
            }

            final t = Speech.t;
            return NumberedMenu(
              title: t.uiListOptions,
              choices: [
                NumberedChoice(
                  label: t.uiListSearch,
                  onSelected: () => run(() => unawaited(_openSearch())),
                ),
                NumberedChoice(
                  label: t.uiListClearSearch,
                  onSelected: () =>
                      run(() => unawaited(_load(const KeypadListQuery(), 0))),
                ),
                NumberedChoice(
                  label: _failedQuery == null
                      ? t.uiListRefreshPage
                      : t.uiListRetry,
                  onSelected: () => run(_retry),
                ),
                if (widget.onFilters != null)
                  NumberedChoice(
                    label: t.uiListFilters,
                    onSelected: () => run(widget.onFilters!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Speech.t;
    final items = _page?.items ?? <T>[];
    final controls = <int, (String, VoidCallback)>{
      0: (t.uiBack, _back),
      6: (t.uiListOptions, _options),
      7: (t.uiListPreviousPage, () => _move(false)),
      8: (t.uiListSearchAll, () => unawaited(_openSearch())),
      9: (t.uiListNextPage, () => _move(true)),
    };
    return KeypadInstructionWrapper(
      interactionPolicy: KeypadInteractionPolicy.numbered,
      screenName: t.uiListScreenName(widget.title, '${_index + 1}'),
      introduction: _error,
      navigationSections: t.uiListSections,
      autoPlay: false,
      labels: {
        for (var index = 0; index < items.length; index++)
          index + 1: widget.labelOf(items[index]),
        for (final entry in controls.entries) entry.key: entry.value.$1,
      },
      actions: {
        for (var index = 0; index < 5; index++) index + 1: () => _select(index),
        for (final entry in controls.entries) entry.key: entry.value.$2,
      },
      focusTargets: [
        for (var index = 0; index < items.length; index++)
          KeypadFocusTarget(
            node: _nodes[index + 1],
            label: widget.labelOf(items[index]),
            onActivate: () => _select(index),
            isEnabled: () => !_loading,
          ),
        for (final entry in controls.entries)
          KeypadFocusTarget(
            node: _nodes[entry.key],
            label: entry.value.$1,
            onActivate: entry.value.$2,
            isEnabled: () => !_loading || entry.key == 0,
          ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    t.uiListScreenName(widget.title, '${_index + 1}'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (_search.isNotEmpty) Text(t.uiListSearchValue(_search)),
                if (_loading) Text(t.uiListLoadingShort),
                if (_error != null)
                  Semantics(liveRegion: true, child: Text(_error!)),
                if (!_loading && _page != null && items.isEmpty)
                  Text(t.uiListNoMatches),
                for (var index = 0; index < items.length; index++)
                  ElevatedButton(
                    focusNode: _nodes[index + 1],
                    onPressed: _loading ? null : () => _select(index),
                    child: Text(
                      t.uiKeyedLabel('${index + 1}', widget.labelOf(items[index])),
                    ),
                  ),
                for (final entry in controls.entries)
                  TextButton(
                    focusNode: _nodes[entry.key],
                    onPressed: !_loading || entry.key == 0
                        ? entry.value.$2
                        : null,
                    child: Text(t.uiKeyedLabel('${entry.key}', entry.value.$1)),
                  ),
                Text(t.uiKeypadFooter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
