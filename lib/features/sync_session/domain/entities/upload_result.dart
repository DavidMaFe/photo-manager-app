import 'package:equatable/equatable.dart';


class UploadResult extends Equatable {

  final String? serverFileId;

  const UploadResult({this.serverFileId});

  @override
  List<Object?> get props => [serverFileId];
}