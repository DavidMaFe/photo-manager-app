import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/app_context_menu.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/dialogs/rename_device_dialog.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/dialogs/unlink_device_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

enum _DeviceMenuAction { rename, unlink }

/// Linked device: icon, name ("This phone" tag), OS, menu and auto backup switch.
class DeviceCard extends StatelessWidget {
  final Device device;
  final bool isPerformingAction;

  /// The phone running the app (highlighted and tagged).
  final bool isCurrentDevice;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isPerformingAction,
    this.isCurrentDevice = false,
  });

  IconData get _icon {
    if (device.isIOS) return Symbols.phone_iphone_rounded;
    if (device.isAndroid) return Symbols.smartphone_rounded;
    return Symbols.devices_rounded;
  }

  /// "Android 14", "iOS 17.2".
  String get _osLabel {
    final os = device.isIOS ? 'iOS' : (device.isAndroid ? 'Android' : device.osType);
    return '$os ${device.osVersion}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrentDevice ? p.accentSoft : p.surface2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon, size: 24, color: isCurrentDevice ? p.accentInk : p.ink2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          device.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink),
                        ),
                        if (isCurrentDevice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.thisDevice,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: p.accentInk),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _osLabel,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (buttonContext) => IconButton(
                  tooltip: l10n.moreOptions,
                  onPressed: isPerformingAction ? null : () => _showMenu(buttonContext),
                  icon: Icon(Symbols.more_vert_rounded, color: p.ink2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
            decoration: BoxDecoration(color: p.background, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.autoSync,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink),
                  ),
                ),
                if (isPerformingAction)
                  const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  AppSwitch(
                    value: device.autoSync,
                    semanticLabel: l10n.autoSync,
                    onChanged: (enabled) => context.read<DeviceBloc>().add(
                      ToggleAutoSync(deviceId: device.id, enabled: enabled),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMenu(BuildContext buttonContext) async {
    final l10n = AppLocalizations.of(buttonContext)!;
    final box = buttonContext.findRenderObject() as RenderBox;
    final action = await showAppContextMenu<_DeviceMenuAction>(
      buttonContext,
      position: box.localToGlobal(box.size.bottomRight(Offset.zero)),
      items: [
        AppMenuItem(value: _DeviceMenuAction.rename, label: l10n.rename, icon: Symbols.edit_rounded),
        AppMenuItem(
          value: _DeviceMenuAction.unlink,
          label: l10n.unlinkDevice,
          icon: Symbols.link_off_rounded,
          destructive: true,
        ),
      ],
    );
    if (!buttonContext.mounted) return;

    final bloc = buttonContext.read<DeviceBloc>();
    switch (action) {
      case _DeviceMenuAction.rename:
        RenameDeviceDialog.show(
          context: buttonContext,
          currentName: device.name,
          onConfirm: (name) => bloc.add(RenameDevice(deviceId: device.id, newName: name)),
        );
      case _DeviceMenuAction.unlink:
        UnlinkDeviceDialog.show(
          context: buttonContext,
          deviceName: device.name,
          onConfirm: () => bloc.add(UnlinkDevice(deviceId: device.id)),
        );
      case null:
        break;
    }
  }
}
