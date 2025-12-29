import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/advanced_options_section.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FileManagementBloc, FileManagementState>(
      listener: _handleStateChange,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Flexible(child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuickActionsSection(onActionSelected: _handleQuickAction),
                    const Divider(height: 32),
                    AdvancedOptionsSection(
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
                    )
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
        Text(
          widget.isMultiple
              ? l10n.manageMultipleFiles(widget.fileIds.length)
              : l10n.manageSingleFile,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold
          ),
        ),
        if (widget.isMultiple) ...[
          const SizedBox(height: 4),
          Text(
            l10n.sameActionWarning,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600]
            ),
          )
        ]
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, FileManagementState state) {

    final isLoading = state is FileManagementLoading;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            if (!isLoading) {
              _handleApply(l10n);
            }
          },
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.isMultiple ? l10n.applyMultiple(widget.fileIds.length) : l10n.applySingle)
        )
      ],
    );
  }

  void _handleQuickAction(ManageAction action) {
    setState(() {
      _selectedAction = action.serverAction;
      _keepOnDevice = action.keepOnDevice;
    });

    if (action.serverAction == ServerAction.folder || action.serverAction == ServerAction.newFolder) {
      return;
    }

    _dispatchManageEvent(action);
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
      Navigator.pop(context);
      _showSuccessSnackBar(state.message);
    } else if (state is FileManagementPartialSuccess) {
      Navigator.pop(context);
      _showPartialSuccessDialog(state, l10n);
    } else if (state is FileManagementError) {
      _showError(state.failure.messageKey);
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

  void _showPartialSuccessDialog(FileManagementPartialSuccess state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.partialManageTitle),
        content: Text('${l10n.correctManage(state.successCount)} ${l10n.failedManage(state.failedFiles.length)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
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