import 'package:equatable/equatable.dart';


abstract class ManageFolderEvent extends Equatable {
  const ManageFolderEvent();

  @override
  List<Object?> get props => [];
}


class LoadFolders extends ManageFolderEvent {
  const LoadFolders();
}