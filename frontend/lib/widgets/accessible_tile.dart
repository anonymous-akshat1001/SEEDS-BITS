import 'package:flutter/material.dart';

import '../utils/ui_utils.dart';

/// Standard list tile for SEEDS: large high-contrast text, a visible border,
/// at least 64 px tall, one concise spoken label, and keypad focusable.
///
/// Use it for anything a user browses: sessions, recordings, people, notes.
/// Put secondary actions in [trailing]; each must have its own label that
/// names the item it acts on (for example "Remove Lesson 3").
class AccessibleTile extends StatelessWidget {
  const AccessibleTile({
    super.key,
    required this.title,
    this.subtitle,
    this.semanticLabel,
    this.leadingIcon,
    this.trailing,
    this.onActivate,
    this.focusNode,
    this.selected = false,
    this.status,
    this.statusColor,
  });

  final String title;
  final String? subtitle;

  /// Spoken label; defaults to title, status and subtitle.
  final String? semanticLabel;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onActivate;
  final FocusNode? focusNode;
  final bool selected;

  /// Short visible state such as "Live", "Playing" or "Downloaded".
  final String? status;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final label =
        semanticLabel ??
        [
          title,
          if (status != null) status!,
          if (subtitle != null) subtitle!,
        ].where((part) => part.isNotEmpty).join('. ');
    final borderColor = selected
        ? UIUtils.accentColor
        : UIUtils.cardBorderColor;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 28, color: UIUtils.accentColor),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: UIUtils.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (status != null && status!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        status!,
                        style: TextStyle(
                          color: statusColor ?? UIUtils.accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: UIUtils.subtextColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? UIUtils.accentColor.withValues(alpha: 0.18)
            : UIUtils.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: selected ? 3 : 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: onActivate != null,
              selected: selected,
              label: label,
              excludeSemantics: true,
              child: InkWell(
                focusNode: focusNode,
                onTap: onActivate,
                child: content,
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
