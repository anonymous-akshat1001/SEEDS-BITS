import 'package:flutter/material.dart';

import '../utils/ui_utils.dart';

/// Draws one unmistakable focus ring around whichever control has keypad
/// focus, on every screen and dialog, regardless of how that control is
/// styled. Low-vision users follow this ring; blind users are unaffected.
class FocusHighlight extends StatefulWidget {
  const FocusHighlight({super.key, required this.child});

  final Widget child;

  @override
  State<FocusHighlight> createState() => _FocusHighlightState();
}

class _FocusHighlightState extends State<FocusHighlight>
    with WidgetsBindingObserver {
  final _stackKey = GlobalKey();
  Rect? _rect;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_schedule);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() => _schedule();

  void _schedule() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final rect = _focusedRect();
      if (rect != _rect) setState(() => _rect = rect);
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Rect? _focusedRect() {
    final node = FocusManager.instance.primaryFocus;
    final box = _stackKey.currentContext?.findRenderObject();
    if (node == null ||
        node is FocusScopeNode ||
        node.context == null ||
        box is! RenderBox ||
        !box.hasSize) {
      return null;
    }
    final Rect rect;
    try {
      rect = node.rect;
    } on Object {
      return null;
    }
    if (rect.isEmpty) return null;
    final screen = box.size;
    // Whole-screen keypad scopes hold focus between targets; ringing the
    // entire screen would tell the user nothing.
    if (rect.width * rect.height > screen.width * screen.height * 0.6) {
      return null;
    }
    final topLeft = box.globalToLocal(rect.topLeft);
    return (topLeft & rect.size).inflate(UIUtils.focusRingWidth);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_schedule);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rect = _rect;
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _schedule();
        return false;
      },
      child: Stack(
        key: _stackKey,
        textDirection: TextDirection.ltr,
        children: [
          widget.child,
          if (rect != null)
            Positioned.fromRect(
              rect: rect,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: UIUtils.focusRingColor,
                          width: UIUtils.focusRingWidth,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
