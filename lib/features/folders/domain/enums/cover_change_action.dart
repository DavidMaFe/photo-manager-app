/// What to do with a photo in an album's covers.
enum CoverChangeAction {
  /// Add the photo to the covers (the album must have room).
  add,

  /// Remove the photo from the covers.
  remove,

  /// Put the photo in the place of another cover (for a full album).
  replace,
}
