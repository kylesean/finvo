package com.finvo.app

import android.content.Intent
import android.speech.RecognitionService
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.finvo.app/speech_check"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isSystemSpeechAvailable") {
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
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
