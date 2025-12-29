import 'package:equatable/equatable.dart';


class ManageFolder extends Equatable {

  final String id;
  final String name;
  final int fileCount;
  final DateTime createdAt;

  const ManageFolder({
    required this.id,
    required this.name,
    required this.fileCount,
    required this.createdAt
  });

  @override
  List<Object?> get props => [id, name, fileCount, createdAt];
}