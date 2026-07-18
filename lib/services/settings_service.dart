import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A tally of the last inbox scan, for the diagnostics screen.
class ScanSummary {
  final int scanned;
  final int parsed;
  final int ignored;
  final int needsAttention;
  final DateTime? at;
  const ScanSummary({
    this.scanned = 0,
    this.parsed = 0,
    this.ignored = 0,
    this.needsAttention = 0,
    this.at,
  });
}

/// Persists AI-related settings: the user's own Gemini API key and their
/// explicit consent to send spending summaries to the cloud.
///
/// Both live in the platform secure store; nothing here is ever transmitted
/// except the API key, which goes only to Google's Gemini endpoint.
class SettingsService {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyName = 'gemini_api_key';
  static const _consentName = 'cloud_ai_consent';
  static const _smsParseConsentName = 'sms_ai_parse_consent';
  static const _lastScanName = 'last_scan_summary';

  Future<String?> getApiKey() async {
    final k = await _storage.read(key: _apiKeyName);
    return (k == null || k.trim().isEmpty) ? null : k.trim();
  }

  Future<void> setApiKey(String key) =>
      _storage.write(key: _apiKeyName, value: key.trim());

  Future<void> clearApiKey() => _storage.delete(key: _apiKeyName);

  Future<bool> hasConsent() async =>
      (await _storage.read(key: _consentName)) == 'true';

  Future<void> setConsent(bool value) =>
      _storage.write(key: _consentName, value: value ? 'true' : 'false');

  /// Separate, stronger consent: allow the *raw text* of bank SMS the parser
  /// couldn't read to be sent to Gemini for extraction. Off by default.
  Future<bool> hasSmsParseConsent() async =>
      (await _storage.read(key: _smsParseConsentName)) == 'true';

  Future<void> setSmsParseConsent(bool value) =>
      _storage.write(key: _smsParseConsentName, value: value ? 'true' : 'false');

  /// The last inbox-scan tally (for diagnostics). Non-sensitive; stored as JSON.
  Future<ScanSummary> getLastScan() async {
    final raw = await _storage.read(key: _lastScanName);
    if (raw == null) return const ScanSummary();
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return ScanSummary(
        scanned: (m['scanned'] as num?)?.toInt() ?? 0,
        parsed: (m['parsed'] as num?)?.toInt() ?? 0,
        ignored: (m['ignored'] as num?)?.toInt() ?? 0,
        needsAttention: (m['needsAttention'] as num?)?.toInt() ?? 0,
        at: m['at'] != null ? DateTime.tryParse(m['at'] as String) : null,
      );
    } catch (_) {
      return const ScanSummary();
    }
  }

  Future<void> setLastScan(ScanSummary s) => _storage.write(
        key: _lastScanName,
        value: jsonEncode({
          'scanned': s.scanned,
          'parsed': s.parsed,
          'ignored': s.ignored,
          'needsAttention': s.needsAttention,
          'at': (s.at ?? DateTime.now()).toIso8601String(),
        }),
      );

  /// True only when the user has both provided a key and granted consent.
  Future<bool> isAiReady() async {
    final key = await getApiKey();
    return key != null && await hasConsent();
  }

  // ---- Savings goal --------------------------------------------------------

  static const _goalName = 'goal_monthly_save';

  Future<double?> getMonthlySavingsGoal() async {
    final raw = await _storage.read(key: _goalName);
    return raw == null ? null : double.tryParse(raw);
  }

  Future<void> setMonthlySavingsGoal(double? amount) async {
    if (amount == null || amount <= 0) {
      await _storage.delete(key: _goalName);
    } else {
      await _storage.write(key: _goalName, value: amount.toString());
    }
  }
}
