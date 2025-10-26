package com.example.orion

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "orion.system"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApkPath" -> {
                    try {
                        val pm = applicationContext.packageManager
                        val info = pm.getApplicationInfo(applicationContext.packageName, 0)
                        result.success(info.sourceDir)
                    } catch (e: Exception) {
                        result.error("APK_PATH_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
