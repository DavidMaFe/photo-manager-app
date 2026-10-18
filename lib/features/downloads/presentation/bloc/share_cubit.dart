import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/share_files_use_case.dart';

abstract class ShareState extends Equatable {
  const ShareState();

  @override
  List<Object?> get props => [];
}

class ShareIdle extends ShareState {
  const ShareIdle();
}

/// The originals are being decrypted before the share sheet opens.
class SharePreparing extends ShareState {
  final int prepared;
  final int total;

  const SharePreparing({required this.prepared, required this.total});

  @override
  List<Object?> get props => [prepared, total];
}

class ShareError extends ShareState {
  final Failure failure;

  const ShareError(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Sharing originals with other apps. Ends in [ShareIdle] once the share sheet opened.
class ShareCubit extends Cubit<ShareState> {
  final ShareFilesUseCase _shareFiles;

  ShareCubit(this._shareFiles) : super(const ShareIdle());

  Future<void> share(List<RemoteMediaFile> files) async {
    if (state is SharePreparing || files.isEmpty) return;
    emit(SharePreparing(prepared: 0, total: files.length));
    try {
      await _shareFiles(files, onPrepared: (prepared, total) => emit(SharePreparing(prepared: prepared, total: total)));
      emit(const ShareIdle());
    } catch (e) {
      emit(ShareError(ErrorHandler.handleError(e)));
      emit(const ShareIdle());
    }
  }
}
