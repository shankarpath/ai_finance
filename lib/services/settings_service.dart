import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists AI-related settings: the user's own Gemini API key and their
/// explicit consent to send spending summaries to the cloud.
///
/// Both live in the platform secure store; nothing here is ever transmitted
/// except the API key, which goes only to Google's Gemini endpoint.
class SettingsService {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyName = 'gemini_api_key';
  static const _consentName = 'cloud_ai_consent';

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
