package com.photomanagerpro.app

import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity: local_auth needs a FragmentActivity to show the fingerprint / device PIN prompt
class MainActivity : FlutterFragmentActivity() {

    // Partial wake lock held while a manual sync uploads files (AndroidSyncKeepAlive), so the CPU does not sleep
    // with the screen off. Not reference counted: acquiring it again renews its timeout.
    private var wakeLock: PowerManager.WakeLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WAKE_LOCK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquire" -> {
                    val timeoutMs = call.argument<Number>("timeoutMs")?.toLong() ?: DEFAULT_TIMEOUT_MS
                    acquireWakeLock(timeoutMs)
                    result.success(null)
                }
                "release" -> {
                    releaseWakeLock()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        releaseWakeLock()
        super.onDestroy()
    }

    private fun acquireWakeLock(timeoutMs: Long) {
        val lock = wakeLock ?: (getSystemService(Context.POWER_SERVICE) as PowerManager)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PhotoManager:sync")
            .apply { setReferenceCounted(false) }
            .also { wakeLock = it }
        lock.acquire(timeoutMs)
    }

    private fun releaseWakeLock() {
        wakeLock?.takeIf { it.isHeld }?.release()
    }

    companion object {
        private const val WAKE_LOCK_CHANNEL = "com.photomanagerpro.app/wake_lock"
        private const val DEFAULT_TIMEOUT_MS = 10 * 60 * 1000L
    }
}
