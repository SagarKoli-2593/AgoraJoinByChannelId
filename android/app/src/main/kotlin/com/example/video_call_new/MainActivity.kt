package com.example.video_call_new

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {


    var appId = "42766e6d3d2945719a923106cfc0f7c2"
    var appCertificate = "85640c7555cf44168c5c24a32457fccb"
    var uid = 0 // The integer uid, required for an RTC token

    var expirationTimeInSeconds = 3600 // The time after which the token expires

    private val CHANNEL = "samples.flutter.dev/agoraToken"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
                call, result ->
            if (call.method == "getNewTokenFromAgora") {
                val newToken = App.generatedToken(appId,appCertificate,call.argument("channel"),uid,expirationTimeInSeconds)
                if (newToken != null) {
                    result.success(newToken)
                } else {
                    result.error("UNAVAILABLE", "Failed to generate token.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
