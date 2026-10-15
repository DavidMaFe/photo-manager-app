# jpeg_xl_codec

Local plugin of Photo Manager. It recompresses a JPEG losslessly into JPEG XL and rebuilds the exact JPEG from it,
with [jxl-coder](https://github.com/awxkee/jxl-coder) **2.6.1** (libjxl 0.10.1) on Android.

It is a plugin, not a channel of `MainActivity`, so it is also registered in the engine of the background sync
(WorkManager). Only Android: on other platforms the calls throw `MissingPluginException` and the app uploads the JPEG
as it is. Do not move to jxl-coder 3.x: it replaces libjxl with Rust crates and has no `reconstructJPEG`
(`ROADMAP-media-compression.md`, Phase 0).
