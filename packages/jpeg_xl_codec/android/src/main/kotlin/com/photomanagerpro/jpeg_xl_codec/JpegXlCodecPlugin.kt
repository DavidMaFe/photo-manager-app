package com.photomanagerpro.jpeg_xl_codec

import android.os.Handler
import android.os.Looper
import com.awxkee.jxlcoder.JxlCoder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Lossless JPEG <-> JPEG XL with jxl-coder 2.6.1 (libjxl 0.10.1). The conversions run on one background thread, one
 * at a time: libjxl reserves several hundred MB of native memory while it works (ROADMAP-media-compression.md).
 */
class JpegXlCodecPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var worker: ExecutorService
    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        worker = Executors.newSingleThreadExecutor()
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        worker.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val operation: (ByteArray) -> ByteArray = when (call.method) {
            "jpegToJxl" -> { bytes -> JxlCoder.Convenience.construct(bytes) }
            "jxlToJpeg" -> { bytes -> JxlCoder.Convenience.reconstructJPEG(bytes) }
            else -> {
                result.notImplemented()
                return
            }
        }
        val input = call.arguments as? ByteArray
        if (input == null) {
            result.error("INVALID_ARGUMENT", "Expected the bytes of the image", null)
            return
        }
        worker.execute {
            try {
                val output = operation(input)
                main.post { result.success(output) }
            } catch (e: Throwable) {
                // Never the content: only the kind of failure
                main.post { result.error("JXL_FAILED", e.javaClass.simpleName, null) }
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.photomanagerpro/jpeg_xl_codec"
    }
}
