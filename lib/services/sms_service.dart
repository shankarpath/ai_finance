import 'package:another_telephony/telephony.dart';

/// A minimal, UI-agnostic representation of an SMS pulled from the device.
class RawSms {
  final String body;
  final String? sender;
  final DateTime receivedAt;
  final String? providerId;

  const RawSms({
    required this.body,
    required this.receivedAt,
    this.sender,
    this.providerId,
  });
}

/// Thin wrapper around `another_telephony` that handles permissions, reading
/// the existing inbox, and listening for new incoming messages.
///
/// All SMS access stays on-device; this class never sends anything out.
class SmsService {
  final Telephony _telephony = Telephony.instance;

  /// Requests SMS (and phone) permissions. Returns true if granted.
  Future<bool> requestPermissions() async {
    final granted = await _telephony.requestSmsPermissions;
    return granted ?? false;
  }

  /// Reads the full SMS inbox once. Callers should filter to bank senders /
  /// transaction bodies via the parser.
  Future<List<RawSms>> readInbox() async {
    final messages = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ID],
    );
    return messages.map(_toRaw).toList();
  }

  /// Starts listening for newly received SMS. [onSms] fires for each foreground
  /// message. Background handling is intentionally omitted for the vertical
  /// slice (it requires a top-level isolate entrypoint).
  void listenIncoming(void Function(RawSms sms) onSms) {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) => onSms(_toRaw(message)),
      listenInBackground: false,
    );
  }

  RawSms _toRaw(SmsMessage m) {
    final millis = m.date;
    return RawSms(
      body: m.body ?? '',
      sender: m.address,
      receivedAt: millis != null
          ? DateTime.fromMillisecondsSinceEpoch(millis)
          : DateTime.now(),
      providerId: m.id?.toString(),
    );
  }
}
