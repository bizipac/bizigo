package com.sahasrara.icici_bank

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

class MainActivity : FlutterActivity() {

    private val CHANNEL = "rd_service_channel"
    private var pendingResult: MethodChannel.Result? = null
    private val RD_REQUEST = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "openRdService") {

                val action: String? = call.argument("action")
                val extras: String? = call.argument("extras")

                if (action.isNullOrEmpty()) {
                    result.error("INVALID_ACTION", "Action missing", null)
                    return@setMethodCallHandler
                }

                pendingResult = result

                try {
                    val intent = Intent(action)

                    // Optional: restrict to specific RD package
                    // intent.setPackage("com.precision.pb510.rdservice")

                    if (!extras.isNullOrEmpty()) {
                        intent.putExtra("PID_OPTIONS", extras)
                    }

                    Log.d("RD_SERVICE", "Launching RD Service with action: $action")

                    startActivityForResult(intent, RD_REQUEST)

                } catch (e: Exception) {
                    Log.e("RD_SERVICE", "Error launching RD Service: ${e.message}")
                    pendingResult = null
                    result.error(
                        "RD_ERROR",
                        "RD Service not installed or failed to open",
                        null
                    )
                }

            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == RD_REQUEST) {

            pendingResult?.let { result ->

                if (resultCode == Activity.RESULT_OK && data != null) {

                    val response = HashMap<String, Any?>()

                    data.extras?.keySet()?.forEach { key ->
                        response[key] = data.extras?.get(key)
                    }

                    Log.d("RD_SERVICE", "RD Response: $response")

                    result.success(response)

                } else {

                    Log.e("RD_SERVICE", "RD Service cancelled or failed")

                    result.error(
                        "CANCELLED",
                        "RD Service cancelled or failed",
                        null
                    )
                }

                pendingResult = null
            }
        }
    }
}
