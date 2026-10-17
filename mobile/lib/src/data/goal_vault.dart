import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Encrypts private goal data on the device. On Android this is an AES-256-GCM key in the
/// Android Keystore (see android/app/src/main/kotlin/.../GoalVault.kt). Ciphertext is stored by
/// [LocalStore] in app-private preferences; plaintext goals are never written to disk.
abstract class GoalVault {
  /// False where no hardware-backed key store is available (e.g. the web build). HATUA then
  /// does not store goals at all rather than storing them unprotected.
  bool get isSupported;

  Future<String> encrypt(String plainText);
  Future<String> decrypt(String blob);
  Future<void> deleteKey();
}

class GoalVaultException implements Exception {
  const GoalVaultException(this.detail);

  /// Technical reason (exception type and message). Never contains goal text.
  final String detail;

  @override
  String toString() => 'GoalVaultException($detail)';
}

class PlatformGoalVault implements GoalVault {
  const PlatformGoalVault();

  static const _channel = MethodChannel('hatua/goal_vault');

  @override
  bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<String> encrypt(String plainText) => _call<String>('encrypt', plainText);

  @override
  Future<String> decrypt(String blob) => _call<String>('decrypt', blob);

  @override
  Future<void> deleteKey() => _call<void>('deleteKey');

  Future<T> _call<T>(String method, [Object? argument]) async {
    try {
      final value = await _channel.invokeMethod<T>(method, argument);
      if (value == null && null is! T) throw const GoalVaultException('Empty response from vault');
      return value as T;
    } on PlatformException catch (e) {
      throw GoalVaultException(e.message ?? e.code);
    } on MissingPluginException {
      throw const GoalVaultException('Secure goal storage is not available on this platform');
    }
  }
}
