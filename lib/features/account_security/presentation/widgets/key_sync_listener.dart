import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/key_sync_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/password_prompt_dialog.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Keeps the keys of this device in step with the account. Each device only refreshes its keys when it logs in, so
/// after a password reset or a new key version on another device it would keep the old ones. It checks once per app
/// session and again when an upload is rejected for that reason:
/// - a current key this device does not hold: asks for the current password and opens it
/// - an account without a usable key: the locked account flow
class KeySyncListener extends StatefulWidget {
  final Widget child;
  final CheckKeysUpToDateUseCase? checkKeys;
  final RefreshKeysWithPasswordUseCase? refreshKeys;
  final AppEventBus? eventBus;

  const KeySyncListener({super.key, required this.child, this.checkKeys, this.refreshKeys, this.eventBus});

  /// Only one check per app session, however many times the shell is rebuilt.
  static bool checkedThisSession = false;

  @override
  State<KeySyncListener> createState() => _KeySyncListenerState();
}

class _KeySyncListenerState extends State<KeySyncListener> {
  StreamSubscription<KeysOutdatedEvent>? _subscription;
  bool _checking = false;

  CheckKeysUpToDateUseCase get _checkKeys => widget.checkKeys ?? sl<CheckKeysUpToDateUseCase>();

  RefreshKeysWithPasswordUseCase get _refreshKeys => widget.refreshKeys ?? sl<RefreshKeysWithPasswordUseCase>();

  @override
  void initState() {
    super.initState();
    _subscription = (widget.eventBus ?? sl<AppEventBus>()).on<KeysOutdatedEvent>().listen((_) => _check());
    if (!KeySyncListener.checkedThisSession) {
      KeySyncListener.checkedThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking || !mounted) return;
    _checking = true;
    try {
      final status = await _checkKeys();
      if (!mounted) return;
      switch (status) {
        case KeySyncStatus.upToDate:
          break;
        case KeySyncStatus.accountLocked:
          context.read<AuthBloc>().add(AccountLockDetected());
        case KeySyncStatus.passwordRequired:
          await _askPassword();
      }
    } catch (_) {
      // Offline or the server failed: it is checked again on the next app session or rejected upload
    } finally {
      _checking = false;
    }
  }

  Future<void> _askPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final prompt = await PasswordPromptDialog.show(context,
        title: l10n.keySyncTitle, message: l10n.keySyncMessage, cancelLabel: l10n.reminderLater);
    if (prompt == null || !mounted) return;
    try {
      await _refreshKeys(password: prompt.password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.keySyncDone)));
    } catch (e) {
      if (!mounted) return;
      ErrorNotificationService.showError(context, e is KeyUnlockFailure ? e : const KeyUnlockFailure(),
          config: ErrorDisplayConfig.snackBar);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
