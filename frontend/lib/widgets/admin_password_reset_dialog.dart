import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/speech.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/ui_utils.dart';
import 'key_instruction_wrapper.dart';
import 'keypad_confirmation_dialog.dart';

class AdminPasswordResetDialog extends StatefulWidget {
  const AdminPasswordResetDialog({
    super.key,
    required this.accountId,
    required this.authVersion,
    required this.accountName,
    required this.phoneNumber,
  });
  final int accountId;
  final int authVersion;
  final String accountName;
  final String phoneNumber;

  @override
  State<AdminPasswordResetDialog> createState() =>
      _AdminPasswordResetDialogState();
}

class _AdminPasswordResetDialogState extends State<AdminPasswordResetDialog> {
  final _identity = FocusNode(debugLabel: 'admin-reset-identity');
  final _attestation = FocusNode(debugLabel: 'admin-reset-attestation');
  final _reset = FocusNode(debugLabel: 'admin-reset-submit');
  final _read = FocusNode(debugLabel: 'admin-reset-read');
  final _close = FocusNode(debugLabel: 'admin-reset-close');
  bool _verified = false;
  bool _busy = false;
  bool _closing = false;
  bool _attempted = false;
  bool _revealed = false;
  String? _credential;
  String? _expires;
  String? _error;

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    TtsService.speak(message, priority: SpeechPriority.critical);
  }

  /// Moves keypad focus once the frame that re-enables controls is built,
  /// falling back to Close so focus is never stranded on a hidden control.
  void _focusAfter(FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (node.context != null && node.canRequestFocus) {
        node.requestFocus();
      } else if (_close.context != null) {
        _close.requestFocus();
      }
    });
  }

  void _verify() {
    if (_busy || _attempted) return;
    setState(() => _verified = !_verified);
    TtsService.speak(
      _verified ? Speech.t.adminResetAttested : Speech.t.adminResetNotAttested,
    );
  }

  Future<void> _issue() async {
    if (_busy || _attempted || !_verified) return;
    setState(() => _busy = true);
    var next = _reset;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => KeypadConfirmationDialog(
          title: Speech.t.adminResetConfirmTitle,
          message: Speech.t.adminResetConfirmMessage(
            widget.accountName,
            widget.phoneNumber.split('').join(' '),
          ),
          cancelLabel: Speech.t.adminResetKeepPassword,
          confirmLabel: Speech.t.adminResetResetPassword,
        ),
      );
      if (!mounted || confirmed != true) return;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (prefs.getString('role') != 'admin' || token == null) {
        _fail(Speech.t.adminResetSignInChanged);
        return;
      }
      setState(() => _attempted = true);
      next = _close;
      TtsService.speak(
        Speech.t.adminResetSending,
        priority: SpeechPriority.navigation,
      );
      final result = await ApiService.postAcknowledged(
        '/admin/users/${widget.accountId}/reset-password',
        {
          'identity_verified': true,
          'expected_auth_version': widget.authVersion,
        },
        context: 'account recovery',
        canSend: () =>
            mounted &&
            prefs.getString('token') == token &&
            prefs.getString('role') == 'admin',
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        _fail(Speech.t.adminResetNotConfirmed(result.failure!.message));
        return;
      }
      final data = result.data!;
      final credential = data['temporary_credential'];
      final expires = data['expires_at'];
      if (credential is! String ||
          !RegExp(r'^\d{12}$').hasMatch(credential) ||
          expires is! String ||
          DateTime.tryParse(expires)?.isUtc != true ||
          data['auth_version'] != widget.authVersion + 1) {
        _fail(Speech.t.adminResetResponseNotVerified);
        return;
      }
      setState(() {
        _credential = credential;
        _expires = expires;
      });
      next = _read;
      TtsService.speak(Speech.t.adminResetConfirmedSpoken);
    } on PlatformException {
      _fail(Speech.t.adminResetPhoneNotConfirmed);
    } on MissingPluginException {
      _fail(Speech.t.adminResetStorageUnavailable);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _focusAfter(next);
      }
    }
  }

  void _readCredential() {
    final credential = _credential;
    if (credential == null) return;
    setState(() => _revealed = true);
    TtsService.speak(
      Speech.t.adminResetCredentialSpoken(
        credential.split('').join(' '),
        '$_expires',
      ),
    );
  }

  Future<void> _closeDialog() async {
    if (_busy || _closing) return;
    _closing = true;
    try {
      if (_credential != null) {
        final close = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => KeypadConfirmationDialog(
            title: Speech.t.adminResetDiscardTitle,
            message: Speech.t.adminResetDiscardMessage,
            cancelLabel: Speech.t.adminResetKeepReviewing,
            confirmLabel: Speech.t.adminResetCloseDiscard,
          ),
        );
        if (!mounted) return;
        if (close != true) {
          _focusAfter(_close);
          return;
        }
      }
      if (mounted) Navigator.pop(context);
    } finally {
      _closing = false;
    }
  }

  @override
  void dispose() {
    for (final node in [_identity, _attestation, _reset, _read, _close]) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _closeDialog();
    },
    child: KeypadInstructionWrapper(
      screenName: Speech.t.adminResetScreenName,
      labels: {0: Speech.t.adminResetCloseRecovery},
      actions: {0: _closeDialog},
      focusTargets: [
        KeypadFocusTarget(
          node: _identity,
          label: Speech.t.adminResetReadAccount,
          onActivate: () => TtsService.speak(
            Speech.t.adminResetAccountDetails(
              widget.accountName,
              widget.phoneNumber.split('').join(' '),
            ),
          ),
        ),
        if (!_attempted) ...[
          KeypadFocusTarget(
            node: _attestation,
            label: _verified
                ? Speech.t.adminResetIdentityChecked
                : Speech.t.adminResetIdentityNotChecked,
            onActivate: _verify,
            isEnabled: () => !_busy,
          ),
          KeypadFocusTarget(
            node: _reset,
            label: Speech.t.adminResetResetAndEnd,
            onActivate: _issue,
            isEnabled: () => _verified && !_busy,
          ),
        ],
        if (_credential != null)
          KeypadFocusTarget(
            node: _read,
            label: Speech.t.adminResetReadCredentialLabel,
            onActivate: _readCredential,
          ),
        KeypadFocusTarget(
          node: _close,
          label: Speech.t.adminResetCloseRefresh,
          onActivate: _closeDialog,
          isEnabled: () => !_busy,
        ),
      ],
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(8),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Speech.t.adminResetTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${widget.accountName}\n${widget.phoneNumber}',
                style: const TextStyle(fontSize: 18),
              ),
              TextButton(
                focusNode: _identity,
                onPressed: () => TtsService.speak(
                  Speech.t.adminResetAccountDetails(
                    widget.accountName,
                    widget.phoneNumber.split('').join(' '),
                  ),
                ),
                child: Text(Speech.t.adminResetReadAccount),
              ),
              if (!_attempted) ...[
                Text(Speech.t.adminResetVerifyInfo),
                CheckboxListTile(
                  focusNode: _attestation,
                  value: _verified,
                  title: Text(Speech.t.adminResetVerifiedCheckbox),
                  onChanged: _busy ? null : (_) => _verify(),
                ),
                ElevatedButton(
                  focusNode: _reset,
                  onPressed: _verified && !_busy ? _issue : null,
                  child: Text(Speech.t.adminResetResetAndEnd),
                ),
              ],
              if (_busy)
                Semantics(
                  liveRegion: true,
                  child: Text(Speech.t.adminResetWaiting),
                ),
              if (_error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: UIUtils.errorColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (_credential != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    Speech.t.adminResetConfirmedInfo,
                    style: TextStyle(
                      color: UIUtils.successColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  focusNode: _read,
                  onPressed: _readCredential,
                  child: Text(Speech.t.adminResetRevealButton),
                ),
                if (_revealed)
                  Text(
                    Speech.t.adminResetCredentialShown(
                      _credential!.split('').join(' '),
                      '$_expires',
                    ),
                  ),
              ],
              TextButton(
                focusNode: _close,
                onPressed: _busy ? null : _closeDialog,
                child: Text(Speech.t.adminResetCloseRefreshKey0),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
