import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/dialogs/rename_device_dialog.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/dialogs/unlink_device_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final bool isPerformingAction;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isPerformingAction,
  });

  IconData _getDeviceIcon() {
    if (device.isAndroid) {
      return Icons.android;
    } else if (device.isIOS) {
      return Icons.phone_iphone;
    } else {
      return Icons.devices;
    }
  }

  Color _getDeviceIconColor(BuildContext context) {
    if (device.isAndroid) {
      return context.palette.safe;
    } else if (device.isIOS) {
      return context.palette.ink2;
    } else {
      return context.palette.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.palette.accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient accent strip on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.palette.accent,
                    context.palette.accent.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Device Icon, Name, and Actions
                Row(
                  children: [
                    // Device Icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getDeviceIconColor(context).withValues(alpha: 0.15),
                            _getDeviceIconColor(context).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _getDeviceIconColor(context).withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getDeviceIcon(),
                        color: _getDeviceIconColor(context),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Device Name and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: context.palette.ink,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.palette.surface2,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: context.palette.line,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  '${device.osType} ${device.osVersion}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.palette.ink2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Actions: Rename and Delete
                    if (isPerformingAction)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: context.palette.accent,
                          ),
                        ),
                      )
                    else ...[
                      // Rename Button
                      Container(
                        decoration: BoxDecoration(
                          color: context.palette.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: context.palette.accent,
                          ),
                          iconSize: 20,
                          onPressed: () => _handleRename(context),
                          tooltip: l10n.renameDevice,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      Container(
                        decoration: BoxDecoration(
                          color: context.palette.dangerSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: context.palette.danger,
                          ),
                          iconSize: 20,
                          onPressed: () => _handleUnlink(context),
                          tooltip: l10n.unlinkDevice,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                // Auto Sync Section with gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.palette.accent.withValues(alpha: 0.06),
                        context.palette.accent.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.palette.accent.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Auto Sync Icon Badge
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.palette.accent.withValues(alpha: 0.15),
                              context.palette.accent.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.sync_rounded,
                          size: 20,
                          color: context.palette.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Auto Sync Label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.autoSync,
                              style: TextStyle(
                                fontSize: 15,
                                color: context.palette.ink,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              device.autoSync ? 'On' : 'Off',
                              style: TextStyle(
                                fontSize: 12,
                                color: device.autoSync
                                    ? context.palette.accentInk
                                    : context.palette.ink2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Modern Toggle Switch
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: device.autoSync,
                          onChanged: isPerformingAction
                              ? null
                              : (value) => _handleToggleAutoSync(context, value),
                          activeThumbColor: context.palette.accent,
                          activeTrackColor:
                              context.palette.accent.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleRename(BuildContext context) {
    RenameDeviceDialog.show(
      context: context,
      currentName: device.name,
      onConfirm: (newName) {
        context.read<DeviceBloc>().add(RenameDevice(
              deviceId: device.id,
              newName: newName,
            ));
      },
    );
  }

  void _handleToggleAutoSync(BuildContext context, bool value) {
    context.read<DeviceBloc>().add(ToggleAutoSync(
          deviceId: device.id,
          enabled: value,
        ));
  }

  void _handleUnlink(BuildContext context) {
    UnlinkDeviceDialog.show(
      context: context,
      deviceName: device.name,
      onConfirm: () {
        context.read<DeviceBloc>().add(UnlinkDevice(deviceId: device.id));
      },
    );
  }
}
