import 'package:equatable/equatable.dart';


/// Every file still to review, without pagination.
class PendingFiles extends Equatable {

  final List<String> fileIds;
  final int totalSizeBytes;

  const PendingFiles({required this.fileIds, required this.totalSizeBytes});

  bool get isEmpty => fileIds.isEmpty;

  @override
  List<Object?> get props => [fileIds, totalSizeBytes];
}
