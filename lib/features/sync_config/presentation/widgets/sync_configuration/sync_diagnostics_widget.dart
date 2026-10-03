import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/core/widgets/permission/background_task_permission_helper.dart';
import 'package:workmanager/workmanager.dart';

/// Diagnostics card for the sync configuration page.
///
/// Shows:
/// - Battery optimization status (Android only) with a fix button.
/// - Last sync result and elapsed time.
/// - Scrollable event log (last 10 entries).
/// - "Force sync now" button to schedule an immediate one-off WorkManager task.
class SyncDiagnosticsWidget extends StatefulWidget {
  const SyncDiagnosticsWidget({super.key});

  @override
  State<SyncDiagnosticsWidget> createState() => _SyncDiagnosticsWidgetState();
}

class _SyncDiagnosticsWidgetState extends State<SyncDiagnosticsWidget> {
  bool? _isExempt;
  List<SyncLogEntry> _logEntries = [];
  String? _lastResult;
  DateTime? _lastResultTime;
  bool _isLoading = false;
  bool _isForcingSyncing = false;

  static const int _maxDisplayedEntries = 10;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  // ─── Data loading ────────────────────────────────────────────────────────

  Future<void> _loadDiagnostics() async {
    setState(() => _isLoading = true);
    try {
      final log = sl<SyncLogService>();
      final entries = log.readAll().take(_maxDisplayedEntries).toList();
      final lastResult = log.lastResult;

      bool? isExempt;
      if (Platform.isAndroid) {
        isExempt = await BackgroundTaskPermissionHelper.isBackgroundTaskEnabled();
      }

      if (mounted) {
        setState(() {
          _logEntries = entries;
          _lastResult = lastResult.result;
          _lastResultTime = lastResult.time;
          _isExempt = isExempt;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _requestBatteryExemption() async {
    // Capture messenger before async gap to avoid use_build_context_synchronously.
    final messenger = ScaffoldMessenger.of(context);
    final palette = context.palette;

    final granted =
        await BackgroundTaskPermissionHelper.requestBatteryOptimizationExemption();
    if (!mounted) return;

    await _loadDiagnostics();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Optimización de batería desactivada — sync puede ejecutarse'
              : 'Permiso no concedido — sync puede ser bloqueado por el SO',
        ),
        backgroundColor: granted ? palette.safe : palette.review,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _forceSyncNow() async {
    setState(() => _isForcingSyncing = true);
    try {
      sl<SyncLogService>().write('▶ Sync manual solicitado desde diagnósticos');

      await Workmanager().registerOneOffTask(
        '${SyncSchedulerService.syncTaskName}_force',
        SyncSchedulerService.syncTaskName,
        initialDelay: Duration.zero,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: '${SyncSchedulerService.syncTaskTag}_force',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Sincronización programada — puede tardar unos minutos en ejecutarse',
            ),
            backgroundColor: context.palette.accent,
            duration: const Duration(seconds: 3),
          ),
        );
        await _loadDiagnostics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al programar sync: $e'),
            backgroundColor: context.palette.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isForcingSyncing = false);
    }
  }

  Future<void> _clearLog() async {
    sl<SyncLogService>().clear();
    await _loadDiagnostics();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatRelativeTime(DateTime? time) {
    if (time == null) return 'Nunca';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Hace menos de 1 min';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} día(s)';
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 24),

            if (Platform.isAndroid) ...[
              _buildBatteryStatusRow(context),
              const SizedBox(height: 12),
            ],

            _buildLastSyncRow(context),
            const SizedBox(height: 16),

            _buildForceSyncButton(),
            const SizedBox(height: 16),

            _buildLogSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bug_report_outlined, size: 20),
        const SizedBox(width: 8),
        Text(
          'Diagnóstico de sincronización',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (_isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadDiagnostics,
            tooltip: 'Refrescar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildBatteryStatusRow(BuildContext context) {
    final isExempt = _isExempt;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isExempt == true ? Icons.battery_full : Icons.battery_alert,
          size: 18,
          color: isExempt == true ? context.palette.safe : context.palette.reviewIcon,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optimización de batería',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                isExempt == true
                    ? 'Exenta ✓ — WorkManager puede ejecutarse en segundo plano'
                    : isExempt == false
                        ? 'Activa ⚠ — Puede impedir el sync automático'
                        : 'Comprobando...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isExempt == true
                          ? context.palette.safeInk
                          : context.palette.reviewInk,
                    ),
              ),
            ],
          ),
        ),
        if (isExempt == false)
          TextButton(
            onPressed: _requestBatteryExemption,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Habilitar'),
          ),
      ],
    );
  }

  Widget _buildLastSyncRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.history, size: 18, color: context.palette.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última sincronización',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                _lastResultTime != null
                    ? '${_formatRelativeTime(_lastResultTime)} — ${_lastResult ?? 'Desconocido'}'
                    : 'Nunca',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.palette.ink2,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForceSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isForcingSyncing ? null : _forceSyncNow,
        icon: _isForcingSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: const Text('Probar sincronización ahora'),
      ),
    );
  }

  Widget _buildLogSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Registro de actividad (últimas ${_logEntries.length})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink2,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _clearLog,
              icon: const Icon(Icons.delete_outline, size: 14),
              label: const Text('Limpiar', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: context.palette.danger,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_logEntries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Sin registros — pulsa "Probar sincronización ahora" para generar actividad',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.palette.ink2,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: context.palette.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _logEntries.length,
              itemBuilder: (context, index) {
                final entry = _logEntries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: context.palette.ink,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '[${entry.timeLabel}] ',
                          style: TextStyle(color: context.palette.ink2),
                        ),
                        TextSpan(text: entry.message),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
