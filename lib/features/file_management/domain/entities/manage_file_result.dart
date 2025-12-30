import 'package:equatable/equatable.dart';


class ManageFileResult extends Equatable {

  final List<String> successfulIds;
  final List<String> failedIds;

  const ManageFileResult({required this.successfulIds, required this.failedIds});

  bool get hasFailures => failedIds.isNotEmpty;
  bool get allSuccessful => failedIds.isEmpty && successfulIds.isNotEmpty;
  bool get allFailures => successfulIds.isEmpty && failedIds.isNotEmpty;

  @override
  List<Object?> get props => [successfulIds, failedIds];
}