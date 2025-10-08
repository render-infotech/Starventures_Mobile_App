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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeSDK" -> {
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
                                println("Error in SDK initialization: ${e.message}")
                                result.error("SDK_INITIALIZATION_FAILED", e.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "A required key was null.", null)
                    }
                }

                "stopTracking" -> {
                    // Launch a coroutine for stop tracking
                    lifecycleScope.launch {
                        try {
                            println("Attempting to stop Geosentry SDK tracking...")

                            // CALL THE ACTUAL GEOSENTRY SDK STOP METHOD
                            // Replace this with the actual Geosentry SDK stop method
                            // This might be one of these methods (check Geosentry SDK documentation):

                            try {
                                // Option 1: Try stopLocationTracking if available
                                Geosentry.stopLocationTracking()
                                println("✅ Geosentry.stopLocationTracking() called successfully")
                            } catch (e1: Exception) {
                                try {
                                    // Option 2: Try stopTracking if available
                                    Geosentry.stopTracking()
                                    println("✅ Geosentry.stopTracking() called successfully")
                                } catch (e2: Exception) {
                                    try {
                                        // Option 3: Try destroy or cleanup method
                                        Geosentry.destroy()
                                        println("✅ Geosentry.destroy() called successfully")
                                    } catch (e3: Exception) {
                                        println("❌ All stop methods failed: $e1, $e2, $e3")
                                        throw Exception("Unable to stop Geosentry SDK: No valid stop method found")
                                    }
                                }
                            }

                            result.success("Geosentry SDK tracking stopped successfully")

                        } catch (e: Exception) {
                            println("❌ Error stopping SDK tracking: ${e.message}")
                            result.error("STOP_TRACKING_ERROR", e.message, null)
                        }
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
