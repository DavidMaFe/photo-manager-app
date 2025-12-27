

enum FileType {
  image,
  video;

  String toApiString() {
    switch (this) {
      case FileType.image:
        return 'IMAGE';
      case FileType.video:
        return 'VIDEO';
    }
  }

  static FileType fromApiString(String value) {
    switch(value.toUpperCase()) {
      case 'IMAGE':
        return FileType.image;
      case 'VIDEO':
        return FileType.video;
      default:
        return FileType.image;
    }
  }
}