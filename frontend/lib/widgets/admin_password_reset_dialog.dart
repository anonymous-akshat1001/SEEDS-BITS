import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
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
    TtsService.speak(message);
  }

  void _verify() {
    if (_busy || _attempted) return;
    setState(() => _verified = !_verified);
    TtsService.speak(
      _verified
          ? 'Identity verification attested.'
          : 'Identity verification not attested.',
    );
  }

  Future<void> _issue() async {
    if (_busy || _attempted || !_verified) return;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => KeypadConfirmationDialog(
          title: 'Reset this password?',
          message:
              'Reset ${widget.accountName}, phone ${widget.phoneNumber.split('').join(' ')}? This replaces the old password and ends online sessions. Disconnected downloaded lessons cannot be instantly revoked. Existing lessons, notes and learning records are retained. A 12-digit temporary credential lasts 24 hours and requires password change. After 10 wrong attempts, temporary-credential sign-in pauses for 15 minutes.',
          cancelLabel: 'Keep password',
          confirmLabel: 'Reset password',
        ),
      );
      if (!mounted || confirmed != true) return;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (prefs.getString('role') != 'admin' || token == null) {
        _fail('Administrator sign-in changed. No reset was sent.');
        return;
      }
      setState(() => _attempted = true);
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
        _fail(
          'Reset not confirmed. ${result.failure!.message} It may already have taken effect. Close and refresh this account before considering another reset.',
        );
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
        _fail(
          'The reset response could not be verified. The password may already have changed. Close and refresh before considering another reset.',
        );
        return;
      }
      setState(() {
        _credential = credential;
        _expires = expires;
      });
      TtsService.speak(
        'Password reset confirmed. The credential is hidden. Use Read credential only when it is private. Closing discards this copy.',
      );
    } on PlatformException {
      _fail(
        'Reset could not be confirmed on this phone. Close and refresh the account before considering another reset.',
      );
    } on MissingPluginException {
      _fail(
        'Account storage is unavailable. Close recovery and restart SEEDS before considering a reset.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _readCredential() {
    final credential = _credential;
    if (credential == null) return;
    setState(() => _revealed = true);
    TtsService.speak(
      'Temporary credential: ${credential.split('').join(' ')}. Expires at $_expires, UTC. Deliver privately to the verified person. It must be replaced at sign-in.',
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
          builder: (_) => const KeypadConfirmationDialog(
            title: 'Discard this credential copy?',
            message:
                'Confirm that you delivered the temporary credential privately, or accept that another verified administrator reset will be needed. SEEDS will not show this copy again. This does not cancel the completed reset.',
            cancelLabel: 'Keep reviewing',
            confirmLabel: 'Close and discard',
          ),
        );
        if (close != true || !mounted) return;
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
      screenName:
          'Administrator password recovery. Verify identity outside SEEDS before resetting. Credentials are hidden until explicitly requested.',
      labels: const {0: 'Close recovery'},
      actions: {0: _closeDialog},
      onHashKey: _closeDialog,
      focusTargets: [
        KeypadFocusTarget(
          node: _identity,
          label: 'Read selected account details',
          onActivate: () => TtsService.speak(
            '${widget.accountName}. Phone ${widget.phoneNumber.split('').join(' ')}.',
          ),
        ),
        if (!_attempted) ...[
          KeypadFocusTarget(
            node: _attestation,
            label:
                'Identity verified outside SEEDS. ${_verified ? 'Checked' : 'Not checked'}. Press OK to change.',
            onActivate: _verify,
            isEnabled: () => !_busy,
          ),
          KeypadFocusTarget(
            node: _reset,
            label: 'Reset password and end online sessions',
            onActivate: _issue,
            isEnabled: () => _verified && !_busy,
          ),
        ],
        if (_credential != null)
          KeypadFocusTarget(
            node: _read,
            label: 'Read and reveal temporary credential. Only use privately.',
            onActivate: _readCredential,
          ),
        KeypadFocusTarget(
          node: _close,
          label: 'Close and refresh account',
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
                'Password recovery',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('${widget.accountName}\n${widget.phoneNumber}'),
              TextButton(
                focusNode: _identity,
                onPressed: () => TtsService.speak(
                  '${widget.accountName}. Phone ${widget.phoneNumber.split('').join(' ')}.',
                ),
                child: const Text('Read selected account details'),
              ),
              if (!_attempted) ...[
                const Text(
                  'Verify the person outside SEEDS. A phone number or SIM suggestion is not identity verification. Never reset based only on a message or a claimed name.',
                ),
                CheckboxListTile(
                  focusNode: _attestation,
                  value: _verified,
                  title: const Text('I verified this person outside SEEDS'),
                  onChanged: _busy ? null : (_) => _verify(),
                ),
                ElevatedButton(
                  focusNode: _reset,
                  onPressed: _verified && !_busy ? _issue : null,
                  child: const Text('Reset password and end online sessions'),
                ),
              ],
              if (_busy) const Text('Waiting for reset confirmation.'),
              if (_error != null)
                Semantics(liveRegion: true, child: Text(_error!)),
              if (_credential != null) ...[
                const Text(
                  'Reset confirmed. Credential hidden until requested. It is valid for 24 hours. Closing discards this copy. Deliver privately; never post it in a class.',
                ),
                TextButton(
                  focusNode: _read,
                  onPressed: _readCredential,
                  child: const Text('Read and reveal credential privately'),
                ),
                if (_revealed)
                  Text(
                    'Temporary credential: ${_credential!.split('').join(' ')}\nExpires: $_expires UTC',
                  ),
              ],
              TextButton(
                focusNode: _close,
                onPressed: _busy ? null : _closeDialog,
                child: const Text('0: Close and refresh account'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
