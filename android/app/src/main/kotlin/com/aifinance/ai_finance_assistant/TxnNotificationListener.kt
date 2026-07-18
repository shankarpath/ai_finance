package com.aifinance.ai_finance_assistant

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

/**
 * Captures money-looking notifications from payment/bank apps (GPay, PhonePe,
 * CRED, bank apps, ...) into a store-and-forward buffer that the Flutter side
 * drains on each sync. This catches transactions that never produce an SMS —
 * e.g. RuPay credit-card-on-UPI payments where banks only push in-app alerts.
 *
 * Privacy: runs entirely on-device. Only notifications whose text contains a
 * currency amount are buffered; everything else is ignored immediately.
 */
class TxnNotificationListener : NotificationListenerService() {

    companion object {
        private const val PREFS = "txn_notif_buffer"
        private const val KEY_PENDING = "pending"
        private const val MAX_BUFFERED = 200

        /** ₹ / Rs / INR followed by digits — the cheap first-pass filter. */
        private val MONEY = Regex("""(?i)(₹|\bRs\.?\s*:?|\bINR\b)\s*[\d,]+""")

        /** Never capture from these: ourselves, and SMS apps (the SMS pipeline
         *  already ingests those messages — capturing both would double-count). */
        private val EXCLUDED_PACKAGES = setOf(
            "com.aifinance.ai_finance_assistant",
            "com.google.android.apps.messaging",
            "com.android.messaging",
            "com.samsung.android.messaging",
            "com.android.mms",
        )

        /** Reads and clears the pending buffer. Called from the MethodChannel. */
        @JvmStatic
        fun drain(context: Context): String {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            synchronized(TxnNotificationListener::class.java) {
                val pending = prefs.getString(KEY_PENDING, "[]") ?: "[]"
                prefs.edit().putString(KEY_PENDING, "[]").apply()
                return pending
            }
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        try {
            val pkg = sbn.packageName ?: return
            if (pkg in EXCLUDED_PACKAGES) return
            // Skip group summaries — the child notification carries the text.
            if (sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY != 0) return

            val extras = sbn.notification.extras
            val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
            val big = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
            val text = big ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            val combined = "$title $text"
            if (combined.isBlank() || !MONEY.containsMatchIn(combined)) return

            val entry = JSONObject().apply {
                put("pkg", pkg)
                put("title", title)
                put("text", text)
                put("postedAt", sbn.postTime)
                // Stable id so re-posted/updated notifications don't duplicate.
                put("key", "${sbn.key}|${sbn.postTime}")
            }

            val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            synchronized(TxnNotificationListener::class.java) {
                val arr = JSONArray(prefs.getString(KEY_PENDING, "[]") ?: "[]")
                // Dedup on key within the buffer.
                for (i in 0 until arr.length()) {
                    if (arr.getJSONObject(i).optString("key") == entry.getString("key")) return
                }
                arr.put(entry)
                // Cap the buffer: drop oldest beyond the limit.
                val trimmed = if (arr.length() > MAX_BUFFERED) {
                    JSONArray().also { out ->
                        for (i in arr.length() - MAX_BUFFERED until arr.length()) {
                            out.put(arr.getJSONObject(i))
                        }
                    }
                } else arr
                prefs.edit().putString(KEY_PENDING, trimmed.toString()).apply()
            }
        } catch (_: Exception) {
            // Never crash the listener — a lost notification is recoverable via
            // the bank app / manual entry; a dead listener loses everything.
        }
    }
}
