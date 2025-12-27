
enum FileStatus {
  pending,
  managed,
  deleted;

  String toApiString(){
    switch (this) {
      case FileStatus.pending:
        return "PENDING";
      case FileStatus.managed:
        return "MANAGED";
      case FileStatus.deleted:
        return "DELETED";
    }
  }

  static FileStatus fromApiString(String value){
    switch (value.toUpperCase()) {
      case "PENDING":
        return FileStatus.pending;
      case "MANAGED":
        return FileStatus.managed;
      case "DELETED":
        return FileStatus.deleted;
      default:
        return FileStatus.pending;
    }
  }

  bool get isPending => this == FileStatus.pending;
  bool get isManaged => this == FileStatus.managed;
  bool get isDeleted => this == FileStatus.deleted;
}