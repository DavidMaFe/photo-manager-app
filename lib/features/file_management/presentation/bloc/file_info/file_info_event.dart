import 'package:equatable/equatable.dart';


abstract class FileInfoEvent extends Equatable {
  const FileInfoEvent();

  @override
  List<Object?> get props => [];
}


/// Loads (or reloads, after an error) the properties of a file.
class LoadFileInfo extends FileInfoEvent {

  final String fileId;
  const LoadFileInfo(this.fileId);

  @override
  List<Object?> get props => [fileId];
}
