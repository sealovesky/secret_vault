import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/app_logger.dart';

/// 生物识别认证服务
class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _pinHashKey = 'vault_pin_hash';
  static const String _pinSaltKey = 'vault_pin_salt';

  /// 检查设备是否支持生物识别
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } on PlatformException catch (e) {
      AppLogger.error('检查生物识别支持时出错', e);
      return false;
    }
  }

  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      AppLogger.error('获取生物识别类型时出错', e);
      return [];
    }
  }

  /// 获取生物识别类型键名（UI 层负责本地化显示）
  Future<String> getBiometricTypeKey() async {
    final types = await getAvailableBiometrics();

    if (types.contains(BiometricType.face)) {
      return 'faceId';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'iris';
    } else if (types.contains(BiometricType.strong) ||
        types.contains(BiometricType.weak)) {
      return 'biometric';
    }

    return 'devicePasscode';
  }

  /// 执行生物识别认证
  Future<AuthResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return AuthResult(
          success: false,
          error: AuthError.notAvailable,
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          error: AuthError.failed,
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  // ============ PIN 码相关 ============

  /// 检查是否已设置 PIN 码
  Future<bool> hasPinCode() async {
    final hash = await _secureStorage.read(key: _pinHashKey);
    return hash != null;
  }

  /// 设置 PIN 码
  Future<void> setPinCode(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinHashKey, value: hash);
  }

  /// 清除 PIN 码
  Future<void> clearPinCode() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
  }

  /// 验证 PIN 码
  Future<bool> verifyPinCode(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    final storedSalt = await _secureStorage.read(key: _pinSaltKey);
    if (storedHash == null || storedSalt == null) return false;

    final hash = _hashPin(pin, storedSalt);
    return hash == storedHash;
  }

  /// 生成随机盐值
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List.generate(32, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// 哈希 PIN（SHA-256 + 盐值）
  String _hashPin(String pin, String salt) {
    final data = utf8.encode('$salt:$pin');
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// 处理平台异常
  AuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotEnrolled':
        return AuthResult(
          success: false,
          error: AuthError.notEnrolled,
        );
      case 'LockedOut':
        return AuthResult(
          success: false,
          error: AuthError.lockedOut,
        );
      case 'PermanentlyLockedOut':
        return AuthResult(
          success: false,
          error: AuthError.permanentlyLockedOut,
        );
      case 'PasscodeNotSet':
        return AuthResult(
          success: false,
          error: AuthError.passcodeNotSet,
        );
      default:
        return AuthResult(
          success: false,
          error: AuthError.unknown,
        );
    }
  }

  /// 取消认证
  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}

/// 认证结果
class AuthResult {
  final bool success;
  final AuthError? error;
  final String? message;

  AuthResult({
    required this.success,
    this.error,
    this.message,
  });
}

/// 认证错误类型
enum AuthError {
  notAvailable,     // 设备不支持
  notEnrolled,      // 未注册生物识别
  lockedOut,        // 临时锁定
  permanentlyLockedOut, // 永久锁定
  passcodeNotSet,   // 未设置密码
  failed,           // 认证失败
  cancelled,        // 用户取消
  unknown,          // 未知错误
}
