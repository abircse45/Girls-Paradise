package com.girlsparadise.shoppingapp

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.girlsparadise.shoppingapp/messenger"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "launchMessenger" -> {
                    val url = call.argument<String>("url") ?: "https://m.me/creationedges"
                    launchMessenger(url, result)
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        openUrl(url, result)
                    } else {
                        result.error("INVALID_URL", "URL cannot be null", null)
                    }
                }
                "openWhatsApp" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        openUrl(url, result)
                    } else {
                        result.error("INVALID_URL", "WhatsApp URL cannot be null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun launchMessenger(url: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", "Messenger not available", e.toString())
        }
    }

    private fun openUrl(url: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", "Could not open URL", e.toString())
        }
    }
}