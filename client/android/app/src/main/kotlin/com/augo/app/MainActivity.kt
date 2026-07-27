package com.augo.app

import android.content.Intent
import android.speech.RecognitionService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.augo.app/speech_check"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isSystemSpeechAvailable") {
                try {
                    val intent = Intent(RecognitionService.SERVICE_INTERFACE)
                    val resolveInfos = packageManager.queryIntentServices(intent, 0)
                    if (resolveInfos.isEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    var hasValidPublicService = false
                    for (info in resolveInfos) {
                        val pkgName = info.serviceInfo.packageName.lowercase()
                        // Filter out known OEM private voice wakeup services that cause SecurityException
                        if (!pkgName.contains("oneplus.voicewakeup") &&
                            !pkgName.contains("qualcomm.qti.sva") &&
                            !pkgName.contains("heytap.speech")) {
                            hasValidPublicService = true
                            break
                        }
                    }
                    result.success(hasValidPublicService)
                } catch (e: Exception) {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
