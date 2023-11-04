import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricController {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    }
  }

  static Future<bool> authenticate(String message) async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: message,
      );
    } on PlatformException catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    }
  }
}
