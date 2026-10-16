package com.photomanagerpro.device_media

import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.StatFs
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream
import java.util.UUID
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * The gallery of the device for the downloads (ROADMAP-downloads-and-account-deletion.md): the ids of every photo and
 * video, the free space, and saving a file in chunks into a pending MediaStore row that is published at the end. The
 * work runs on one background thread, in order, so the chunks of a file are written in the order they arrive.
 */
class DeviceMediaPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private class PendingSave(val uri: Uri, val stream: OutputStream)

    private lateinit var channel: MethodChannel
    private lateinit var resolver: ContentResolver
    private lateinit var worker: ExecutorService
    private val main = Handler(Looper.getMainLooper())
    private val pending = HashMap<String, PendingSave>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        resolver = binding.applicationContext.contentResolver
        worker = Executors.newSingleThreadExecutor()
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        worker.execute {
            // Saves left half-way (the engine is going away): their pending rows are removed
            pending.keys.toList().forEach { abort(it) }
        }
        worker.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "isSupported") {
            result.success(SUPPORTED)
            return
        }
        if (!SUPPORTED) {
            result.error("UNSUPPORTED", "Android 10 or later is needed", null)
            return
        }
        worker.execute {
            try {
                val value: Any? = when (call.method) {
                    "galleryIds" -> galleryIds()
                    "storage" -> storage()
                    "beginSave" -> beginSave(call)
                    "write" -> write(call)
                    "commit" -> commit(call.argument<String>("token")!!)
                    "abort" -> abort(call.argument<String>("token")!!)
                    else -> {
                        main.post { result.notImplemented() }
                        return@execute
                    }
                }
                main.post { result.success(value) }
            } catch (e: Throwable) {
                // Never names nor content: only the kind of failure
                main.post { result.error("DEVICE_MEDIA_FAILED", e.javaClass.simpleName, null) }
            }
        }
    }

    private fun galleryIds(): LongArray {
        val ids = ArrayList<Long>()
        resolver.query(
            MediaStore.Files.getContentUri("external"), arrayOf(MediaStore.Files.FileColumns._ID),
            "${MediaStore.Files.FileColumns.MEDIA_TYPE} IN (?, ?)",
            arrayOf(
                MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE.toString(),
                MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO.toString()
            ), null
        )?.use { cursor -> while (cursor.moveToNext()) ids.add(cursor.getLong(0)) }
        return ids.toLongArray()
    }

    private fun storage(): Map<String, Long> {
        val stat = StatFs(Environment.getExternalStorageDirectory().path)
        return mapOf("free" to stat.availableBytes, "total" to stat.totalBytes)
    }

    private fun beginSave(call: MethodCall): String {
        val mimeType = call.argument<String>("mimeType")!!
        val collection = if (mimeType.startsWith("video/")) {
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        }
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, call.argument<String>("displayName"))
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, call.argument<String>("relativePath"))
            // Android 16 (S23) ignores it and takes the date from the EXIF or the video metadata of the file, which is
            // the original byte for byte; files without them show the date of the download
            call.argument<Number>("dateTakenMs")?.let { put(MediaStore.MediaColumns.DATE_TAKEN, it.toLong()) }
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val uri = resolver.insert(collection, values) ?: throw IllegalStateException("MediaStore insert failed")
        val stream = try {
            resolver.openOutputStream(uri, "w") ?: throw IllegalStateException("No output stream")
        } catch (e: Throwable) {
            resolver.delete(uri, null, null)
            throw e
        }
        val token = UUID.randomUUID().toString()
        pending[token] = PendingSave(uri, stream)
        return token
    }

    private fun write(call: MethodCall): Nothing? {
        val save = pending[call.argument<String>("token")!!] ?: throw IllegalStateException("Unknown save")
        save.stream.write(call.argument<ByteArray>("bytes")!!)
        return null
    }

    private fun commit(token: String): String {
        val save = pending.remove(token) ?: throw IllegalStateException("Unknown save")
        try {
            save.stream.flush()
            save.stream.close()
            resolver.update(save.uri, ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) }, null, null)
        } catch (e: Throwable) {
            resolver.delete(save.uri, null, null)
            throw e
        }
        return ContentUris.parseId(save.uri).toString()
    }

    private fun abort(token: String): Nothing? {
        val save = pending.remove(token) ?: return null
        try {
            save.stream.close()
        } catch (_: Throwable) {
        }
        resolver.delete(save.uri, null, null)
        return null
    }

    companion object {
        private const val CHANNEL = "com.photomanagerpro/device_media"
        private val SUPPORTED = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    }
}
