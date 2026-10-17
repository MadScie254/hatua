package com.example.hatua_app

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private val mainThread = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hatua/goal_vault").setMethodCallHandler { call, result ->
            // Keystore operations can block for a moment; keep them off the UI thread.
            worker.execute {
                try {
                    val value: Any? = when (call.method) {
                        "encrypt" -> GoalVault.encrypt(call.arguments as String)
                        "decrypt" -> GoalVault.decrypt(call.arguments as String)
                        "deleteKey" -> GoalVault.deleteKey().let { null }
                        else -> {
                            mainThread.post { result.notImplemented() }
                            return@execute
                        }
                    }
                    mainThread.post { result.success(value) }
                } catch (e: Throwable) {
                    // Exception class + message only: never echo goal text back.
                    val detail = "${e.javaClass.simpleName}: ${e.message ?: "no message"}"
                    mainThread.post { result.error("vault_error", detail, null) }
                }
            }
        }
    }

    override fun onDestroy() {
        worker.shutdown()
        super.onDestroy()
    }
}
