import 'package:equatable/equatable.dart';

/// What deleting the account removes from the server, shown in the first step of the deletion.
class AccountDeletionSummary extends Equatable {
  /// Every file, in the trash or not.
  final int files;

  /// Encrypted bytes stored for the account (originals, thumbnails and previews).
  final int storedBytes;

  /// Albums, without the default folder.
  final int albums;

  /// Linked devices.
  final int devices;

  const AccountDeletionSummary({
    required this.files,
    required this.storedBytes,
    required this.albums,
    required this.devices,
  });

  @override
  List<Object?> get props => [files, storedBytes, albums, devices];
}
