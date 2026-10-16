# device_media

Local plugin of Photo Manager for the downloads to the device (`ROADMAP-downloads-and-account-deletion.md`):

- the ids of every photo and video of the gallery, in one MediaStore query (about 6 times faster than building the
  `AssetEntity` list of photo_manager);
- the free space of the device;
- saving a file into the gallery in chunks: the row is created pending (`IS_PENDING`), the bytes are written as they
  are decrypted and the row is published at the end, so a video is never held whole in memory and nothing decrypted
  is written outside MediaStore.

It is a plugin, not a channel of `MainActivity`, so it is also registered in the engine of WorkManager. Only Android
10 (API 29) and later, which have `RELATIVE_PATH` and `IS_PENDING`: elsewhere `isSupported` is false and the other
calls throw `MissingPluginException` or `UNSUPPORTED`.
