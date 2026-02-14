import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';

abstract class SyncConfigState {}

/// Initial state before loading configuration
class SyncConfigInitial extends SyncConfigState {}

/// Loading configuration from storage
class SyncConfigLoading extends SyncConfigState {}

/// Configuration loaded successfully
class SyncConfigLoaded extends SyncConfigState {
  final SyncConfig config;

  SyncConfigLoaded(this.config);
}

/// Saving configuration to storage
class SyncConfigSaving extends SyncConfigState {
  final SyncConfig config;

  SyncConfigSaving(this.config);
}

/// Configuration saved successfully
class SyncConfigSaved extends SyncConfigState {
  final SyncConfig config;

  SyncConfigSaved(this.config);
}

/// Error occurred while loading or saving
class SyncConfigError extends SyncConfigState {
  final Failure failure;
  final SyncConfig? currentConfig;

  SyncConfigError(this.failure, {this.currentConfig});
}
