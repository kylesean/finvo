package com.finvo.app

import android.content.Intent
import android.speech.RecognitionService
import android.speech.SpeechRecognizer
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.finvo.app/speech_check"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSystemSpeechAvailable" -> {
                    try {
                        val isAvailable = SpeechRecognizer.isRecognitionAvailable(context)
                        if (isAvailable) {
                            result.success(true)
                        } else {
                            val intent = Intent(RecognitionService.SERVICE_INTERFACE)
                            val resolveInfos = packageManager.queryIntentServices(intent, 0)
                            result.success(resolveInfos.isNotEmpty())
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to check speech availability", e)
                        result.success(false)
                    }
                }
                "getBestSpeechComponent" -> {
                    try {
                        val component = findBestSpeechComponent()
                        if (component != null) {
                            result.success(mapOf(
                                "packageName" to component.packageName,
                                "className" to component.className
                            ))
                        } else {
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to get best speech component", e)
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun findBestSpeechComponent(): android.content.ComponentName? {
        val intent = Intent(RecognitionService.SERVICE_INTERFACE)
        val resolveInfos = packageManager.queryIntentServices(intent, 0)
        if (resolveInfos.isEmpty()) return null

        val priorityPackages = listOf(
            "com.google.android.googlequicksearchbox", // Google GMS
            "com.xiaomi.speech",                       // Xiaomi / HyperOS / MIUI
            "com.miui.voiceassist",
            "com.huawei.vassistant",                    // Huawei / HarmonyOS
            "com.hihonor.vassistant",                   // Honor
            "com.coloros.speech",                       // OPPO / ColorOS
            "com.heytap.speech",
            "com.vivo.speech",                          // Vivo / OriginOS
            "com.vivo.vba",
            "com.iflytek.speechcloud",                  // iFlytek
            "com.baidu.speech"                          // Baidu
        )

        for (pkg in priorityPackages) {
            val match = resolveInfos.firstOrNull { it.serviceInfo.packageName == pkg }
            if (match != null) {
                return android.content.ComponentName(match.serviceInfo.packageName, match.serviceInfo.name)
            }
        }

        val first = resolveInfos.first()
        return android.content.ComponentName(first.serviceInfo.packageName, first.serviceInfo.name)
    }
}
