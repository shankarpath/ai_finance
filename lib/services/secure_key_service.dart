import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the database encryption passphrase.
///
/// The key is a random 256-bit value generated once on first launch and stored
/// in the platform secure store (Android Keystore-backed). It never leaves the
/// device and is only ever used to unlock the local SQLCipher database.
class SecureKeyService {
  static const _storage = FlutterSecureStorage();
  static const _dbKeyName = 'db_passphrase_v1';

  /// Returns the DB key as 64 hex chars (a raw 256-bit SQLCipher key),
  /// creating and persisting one on first use.
  static Future<String> getOrCreateDbKeyHex() async {
    final existing = await _storage.read(key: _dbKeyName);
    if (existing != null && existing.length == 64) return existing;

    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _dbKeyName, value: hex);
    return hex;
  }
}
