package com.aifinance.ai_finance_assistant

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by the local_auth plugin so the biometric
// prompt can attach to the activity's fragment manager.
class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fincoach/notif_capture"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                // Whether the user has granted notification access to this app.
                "isEnabled" -> {
                    val flat = Settings.Secure.getString(
                        contentResolver, "enabled_notification_listeners"
                    )
                    result.success(flat?.contains(packageName) == true)
                }
                // Opens the system "Notification access" settings screen.
                "openSettings" -> {
                    startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                    result.success(null)
                }
                // Returns and clears buffered notifications (JSON array string).
                "drain" -> result.success(TxnNotificationListener.drain(this))
                else -> result.notImplemented()
            }
        }
    }
}
