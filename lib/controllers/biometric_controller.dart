import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricController {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } on PlatformException catch (error) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: "Authenticate to access your data",
      );
    } on PlatformException catch (error) {
      return false;
    }
  }
}
