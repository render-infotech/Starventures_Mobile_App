package com.example.starcapitalventures

import androidx.annotation.NonNull
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.geosentry.geosentry_sdk.Geosentry
import kotlinx.coroutines.launch

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
                    // Launch a coroutine to call the suspend function
                    lifecycleScope.launch {
                        try {
                            val sdkResult = Geosentry.initialiseSDK(
                                this@MainActivity, 
                                apiKey, 
                                cipherKey, 
                                userID
                            )
                            
                            // Print the result to see what it contains
                            println("SDK Initialization Result: $sdkResult")
                            
                            // Return the result as a string
                            result.success(sdkResult.toString())
                        } catch (e: Exception) {
                            println("Error in getting org details: ${e.message}")
                            result.error("SDK_INITIALIZATION_FAILED", e.message, null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "A required key was null.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}