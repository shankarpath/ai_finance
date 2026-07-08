import 'package:local_auth/local_auth.dart';

/// Wraps device biometric / credential authentication for the app lock.
class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device can perform any local auth (biometric or device PIN).
  /// If false, the app should not lock the user out.
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts for biometric/device-credential auth. Returns true on success.
  Future<bool> authenticate() async {
    try {
      // local_auth v3 API: options are passed as named flags directly.
      return await _auth.authenticate(
        localizedReason: 'Unlock AI Finance Assistant',
        biometricOnly: false, // allow device PIN/pattern as fallback
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
