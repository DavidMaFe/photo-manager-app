/// Where a device permission stands.
enum PermissionAccess {
  /// Not granted yet; asking shows the system prompt.
  pending,

  granted,

  /// Denied after asking: only the system settings can grant it now.
  blocked,
}
