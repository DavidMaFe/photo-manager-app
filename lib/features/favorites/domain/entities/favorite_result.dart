import 'package:equatable/equatable.dart';


/// Files whose favorite mark changed, and those that could not change
/// (in the trash, missing or not the user's).
class FavoriteResult extends Equatable {

  final List<String> updatedIds;
  final List<String> failedIds;

  const FavoriteResult({required this.updatedIds, required this.failedIds});

  bool get hasFailures => failedIds.isNotEmpty;
  bool get allFailed => updatedIds.isEmpty && failedIds.isNotEmpty;

  @override
  List<Object?> get props => [updatedIds, failedIds];
}
