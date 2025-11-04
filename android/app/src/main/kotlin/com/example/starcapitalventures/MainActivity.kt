package com.starcapital.ventures

import androidx.annotation.NonNull
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.geosentry.geosentry_sdk.Geosentry
import kotlinx.coroutines.launch
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.geosentry.sdk/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "initializeSDK") {
                val apiKey = call.argument<String>("apiKey")
                val cipherKey = call.argument<String>("cipherKey")
                val userID = call.argument<String>("userID")

                if (apiKey != null && cipherKey != null && userID != null) {
                    lifecycleScope.launch {
                        try {
                            val sdkResult = Geosentry.initialiseSDK(
                                this@MainActivity,
                                apiKey,
                                cipherKey,
                                userID
                            )

                            println("SDK Initialization Result: $sdkResult")
                            result.success(sdkResult.toString())
                        } catch (e: Exception) {
                            println("Error in getting org details: ${e.message}")
                            result.error("SDK_INITIALIZATION_FAILED", e.message, null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "A required key was null.", null)
                }
            } else if (call.method == "stopTracking") {
                // Handle stop tracking
                lifecycleScope.launch {
                    try {
                        val response = Geosentry.stopTracking(this@MainActivity)
                        Log.d("GeosentrySDK", "Stop Tracking Response: $response")

                        if (response["success"] as? Boolean == true) {
                            result.success("Location tracking stopped successfully")
                        } else {
                            val errorMessage = response["errormessage"] as? String ?: "Unknown error"
                            result.error("STOP_ERROR", "Failed to stop tracking: $errorMessage", null)
                        }
                    } catch (e: Exception) {
                        Log.e("GeosentrySDK", "Error stopping tracking", e)
                        result.error("STOP_ERROR", "Exception while stopping tracking", e.message)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
