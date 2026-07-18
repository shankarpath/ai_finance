import 'dart:convert';

import 'package:flutter/services.dart';

/// A money-looking notification captured from another app (GPay, PhonePe,
/// CRED, a bank app, …) by the Android listener service.
class RawAppNotification {
  final String package;
  final String title;
  final String text;
  final DateTime postedAt;

  /// Stable id (system notification key + post time) for deduplication.
  final String key;

  const RawAppNotification({
    required this.package,
    required this.title,
    required this.text,
    required this.postedAt,
    required this.key,
  });

  /// The pseudo SMS body handed to the parser.
  String get body => title.isEmpty ? text : '$title. $text';
}

/// Maps a payment app's package name to a sender token the parser already
/// trusts. Unknown packages return null — their transaction-shaped
/// notifications then land in the review queue instead of auto-logging
/// (same never-drop philosophy as unknown SMS senders).
String? senderTokenForPackage(String package) {
  const map = <String, String>{
    'com.google.android.apps.nbu.paisa.user': 'GPAY',
    'com.phonepe.app': 'PHONPE',
    'net.one97.paytm': 'PAYTM',
    'com.dreamplug.androidapp': 'CRED',
    'in.org.npci.upiapp': 'BHIM', // BHIM
    'com.csam.icici.bank.imobile': 'ICIC',
    'com.snapwork.hdfc': 'HDFC',
    'com.sbi.lotusintouch': 'SBI',
    'com.sbi.SBIFreedomPlus': 'SBI',
    'com.axis.mobile': 'AXIS',
    'com.msf.kbank.mobile': 'KOTAK',
    'com.yesbank.iris': 'YES',
    'com.YesBank': 'YES',
    'in.amazon.mShop.android.shopping': 'AMZN',
    'com.mobikwik_new': 'MOBIKW',
    'com.freecharge.android': 'FREECH',
    'com.onecard.ocl': 'ONECARD',
    'com.naviapp': 'NAVI',
    'com.jupiter.money': 'JUPITER',
    'indwin.c3.shareapp': 'SLICE',
    'com.bobcard.app': 'BOB',
  };
  return map[package];
}

/// Bridge to the Android [TxnNotificationListener]: permission status, the
/// system settings screen, and draining the store-and-forward buffer.
class NotificationCaptureService {
  static const _channel = MethodChannel('fincoach/notif_capture');

  /// Whether the user has granted notification access.
  Future<bool> isEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system "Notification access" settings page.
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } catch (_) {}
  }

  /// Returns and clears all buffered notifications.
  Future<List<RawAppNotification>> drain() async {
    try {
      final raw = await _channel.invokeMethod<String>('drain') ?? '[]';
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in list.whereType<Map<String, dynamic>>())
          RawAppNotification(
            package: e['pkg'] as String? ?? '',
            title: e['title'] as String? ?? '',
            text: e['text'] as String? ?? '',
            postedAt: DateTime.fromMillisecondsSinceEpoch(
                (e['postedAt'] as num?)?.toInt() ?? 0),
            key: e['key'] as String? ?? '',
          ),
      ];
    } catch (_) {
      return const [];
    }
  }
}
