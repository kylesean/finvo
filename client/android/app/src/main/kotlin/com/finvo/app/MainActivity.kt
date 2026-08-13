package com.finvo.app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
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
                // Probe whether the DEFAULT system recognition service (the
                // exact one speech_to_text's SpeechRecognizer.startListening
                // will bind) actually allows third-party binding.
                //
                // Some OEM services (e.g. OnePlus' WakeupService) resolve as
                // the default recognizer but are protected by signature-level
                // permissions: binding them throws a SecurityException that
                // speech_to_text does NOT catch, crashing the whole app from
                // inside the plugin's native thread (Dart try/catch cannot
                // see it). bindService throws synchronously, so a probe with
                // immediate unbind detects this without any side effects.
                "canBindDefaultSpeechService" -> {
                    try {
                        // Resolve the default service for the standard
                        // recognition intent (same resolution SpeechRecognizer
                        // performs internally; no hidden APIs used).
                        val intent = Intent(RecognitionService.SERVICE_INTERFACE)
                        val component = intent.resolveActivity(packageManager)
                        if (component == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val bound = probeBind(
                            Intent(intent).setComponent(component)
                        )
                        result.success(bound)
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to probe speech service binding", e)
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Attempt a synchronous bind probe; any SecurityException means "not bindable". */
    private fun probeBind(intent: Intent): Boolean {
        var bound = false
        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {}
            override fun onServiceDisconnected(name: ComponentName?) {}
        }
        try {
            bound = context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
            if (bound) {
                // Probe succeeded: release the service immediately.
                context.unbindService(connection)
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "Speech service refused binding (security)", e)
            bound = false
        }
        return bound
    }

    private fun findBestSpeechComponent(): android.content.ComponentName? {
        val intent = Intent(RecognitionService.SERVICE_INTERFACE)
        val resolveInfos = packageManager.queryIntentServices(intent, 0)
        if (resolveInfos.isEmpty()) return null

        // Generic preference heuristic, identical for EVERY device: a device
        // may expose several recognition services (Google GMS + one or more
        // OEM providers), and we simply prefer the most standards-compliant
        // one that is actually installed. The list below is pure DATA about
        // known service package names — a device that lacks a package simply
        // skips that entry. Google GMS first (strict AOSP protocol
        // compliance), then major OEM providers, then whatever is available.
        val preferredPackages = listOf(
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

        for (pkg in preferredPackages) {
            val match = resolveInfos.firstOrNull { it.serviceInfo.packageName == pkg }
            if (match != null) {
                return android.content.ComponentName(match.serviceInfo.packageName, match.serviceInfo.name)
            }
        }

        val first = resolveInfos.first()
        return android.content.ComponentName(first.serviceInfo.packageName, first.serviceInfo.name)
    }
}
