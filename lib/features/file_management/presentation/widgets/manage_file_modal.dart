import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/advanced_options_section.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/local_deletion_warning_dialog.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/quick_actions_section.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class ManageFileModal extends StatefulWidget {

  final List<String> fileIds;
  final bool isMultiple;

  const ManageFileModal({
    super.key,
    required this.fileIds,
    this.isMultiple = false
  });

  @override
  State<ManageFileModal> createState() => _ManageFileModalState();
}


class _ManageFileModalState extends State<ManageFileModal> {

  ServerAction? _selectedAction;
  String? _selectedFolderId;
  String? _newFolderName;
  bool _keepOnDevice = true;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _advancedOptionsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileManagementBloc, FileManagementState>(
      listener: _handleStateChange,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Flexible(child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuickActionsSection(onActionSelected: _handleQuickAction),
                    const Divider(height: 32),
                    AdvancedOptionsSection(
                      key: _advancedOptionsKey,
                      selectedAction: _selectedAction,
                      onActionChanged: (action) {
                        setState(() => _selectedAction = action);
                      },
                      selectedFolderId: _selectedFolderId,
                      onFolderSelected: (id) {
                        setState(() => _selectedFolderId = id);
                      },
                      newFolderName: _newFolderName,
                      onNewFolderNameChanged: (name) {
                        setState(() => _newFolderName = name);
                      },
                      keepOnDevice: _keepOnDevice,
                      onKeepOnDeviceChanged: (value) {
                        setState(() => _keepOnDevice = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildKeepOnDeviceCard(context)
                  ],
                ),
              )),
              const SizedBox(height: 24),
              _buildActionButtons(context, state)
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)
            ),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PhotoManagerColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune,
                color: PhotoManagerColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.isMultiple
                      ? l10n.manageMultipleFiles(widget.fileIds.length)
                      : l10n.manageSingleFile,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                  if (widget.isMultiple) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.sameActionWarning,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600]
                      ),
                    )
                  ]
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildKeepOnDeviceCard(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PhotoManagerColors.primary.withValues(alpha: 0.05),
            PhotoManagerColors.primary.withValues(alpha: 0.02)
          ]
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PhotoManagerColors.primary.withValues(alpha: 0.2),
          width: 1.5
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _keepOnDevice = !_keepOnDevice;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _keepOnDevice ? PhotoManagerColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(
                    _keepOnDevice ? Icons.smartphone : Icons.cloud_upload,
                    color: _keepOnDevice ? Colors.white : Colors.grey.shade600,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.keepInDeviceTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.keepInDeviceSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                    height: 30,
                  decoration: BoxDecoration(
                    color: _keepOnDevice ? PhotoManagerColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        left: _keepOnDevice ? 24 : 2,
                        top: 2,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2)
                              )
                            ]
                          ),
                        ),
                      )
                    ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FileManagementState state) {

    final isLoading = state is FileManagementLoading;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1
          )
        )
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                side: BorderSide(
                  color:Colors.grey.shade300,
                  width: 1.5
                )
              ),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _handleApply(l10n),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: PhotoManagerColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey.shade300
              ),
              child: isLoading ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.isMultiple ? l10n.applyMultiple(widget.fileIds.length) : l10n.applySingle, style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ))
                ],
              )
            ),
          )
        ],
      ),
    );
  }

  void _handleQuickAction(ManageAction action) {
    setState(() {
      _selectedAction = action.serverAction;
      _keepOnDevice = action.keepOnDevice;
    });

    if (action.serverAction == ServerAction.folder || action.serverAction == ServerAction.newFolder) {
      // Scroll to the advanced options section to help user find the folder selector
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAdvancedOptions();
      });
      return;
    }

    _dispatchManageEvent(action);
  }

  void _scrollToAdvancedOptions() {
    if (_advancedOptionsKey.currentContext != null) {
      final RenderBox renderBox = _advancedOptionsKey.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());

      // Calculate the scroll offset needed to bring the advanced options into view
      // Subtract some offset to account for the header and provide padding
      final targetScrollOffset = _scrollController.offset + position.dy - 100;

      _scrollController.animateTo(
        targetScrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleApply(AppLocalizations l10n) {
    if (_selectedAction == null) {
      _showError(l10n.selectAction);
      return;
    }

    final action = ManageAction(
      serverAction: _selectedAction!,
      folderId: _selectedFolderId,
      folderName: _newFolderName,
      keepOnDevice: _keepOnDevice
    );

    if (!action.isValid()) {
      _showError(_getValidationError(action, l10n));
      return;
    }

    _dispatchManageEvent(action);
  }

  void _dispatchManageEvent(ManageAction action) {
    context.read<FileManagementBloc>().add(
      ManagedFilesRequested(fileIds: widget.fileIds, action: action)
    );
  }

  void _handleStateChange(BuildContext context, FileManagementState state) {

    final l10n = AppLocalizations.of(context)!;

    if (state is FileManagementSuccess) {
      // Close modal first
      Navigator.pop(context, true);

      // Show appropriate message based on whether local files may remain
      if (state.mayHaveLocalFiles) {
        // Files removed from server but may remain locally - show dialog after closing modal
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!context.mounted) return;
          _showSuccessWithWarningDialog(state.message, l10n);
        });
      } else {
        // Everything went perfectly - show success snackbar
        _showSuccessSnackBar(state.message);
      }
    } else if (state is FileManagementPartialSuccess) {
      Navigator.pop(context, true); // Return true to indicate success
      _showPartialSuccessDialog(state, l10n);
    } else if (state is FileManagementError) {
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
        onRetry: () => _dispatchManageEvent(ManageAction(
          serverAction: _selectedAction!,
          folderId: _selectedFolderId,
          folderName: _newFolderName,
          keepOnDevice: _keepOnDevice
        )),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      )
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message)
          ],
        ),
        backgroundColor: Colors.green,
      )
    );
  }

  Future<void> _showSuccessWithWarningDialog(String message, AppLocalizations l10n) async {
    // Show warning dialog about files potentially remaining on device
    // This dialog includes a "Don't show again" checkbox
    await LocalDeletionWarningDialog.show(
      context: context,
      message: '$message\n\n${l10n.filesRemovedFromServerLocalMayRemain}',
      preferencesService: sl<UiPreferencesService>(),
    );
  }

  void _showPartialSuccessDialog(FileManagementPartialSuccess state, AppLocalizations l10n) {
    ModernDialog.show(
      context: context,
      type: DialogType.warning,
      icon: Icons.warning_amber,
      title: l10n.partialManageTitle,
      message: '${l10n.correctManage(state.successCount)} ${l10n.failedManage(state.failedFiles.length)}',
      cancelText: '',
      confirmText: l10n.ok,
    );
  }

  String _getValidationError(ManageAction action, AppLocalizations l10n) {
    switch(action.serverAction) {
      case ServerAction.folder:
        return l10n.selectFolderError;
      case ServerAction.newFolder:
        return l10n.newFolderNameError;
      default:
        return l10n.invalidActionError;
    }
  }
}