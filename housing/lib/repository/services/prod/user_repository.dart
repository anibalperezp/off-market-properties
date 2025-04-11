import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  FlutterSecureStorage _storage = Platform.isAndroid
      ? FlutterSecureStorage(
          aOptions: AndroidOptions(
              encryptedSharedPreferences: true, resetOnError: true))
      : FlutterSecureStorage(
          iOptions:
              IOSOptions(accessibility: KeychainAccessibility.first_unlock));

  //********************STORE START *******************************/

  Future<String> readKey(String keyChain) async {
    String token = '';
    try {
      final all = await _storage.readAll();
      if (all.containsKey(keyChain)) {
        token = all[keyChain]!;
      }
      // obviously there is more code here
    } on PlatformException catch (e) {
      _storage.deleteAll();
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }

    return token;
  }

  Future<bool> persistToken(String value) async {
    try {
      final all = await _storage.readAll();
      if (all.containsValue(value)) {
        return true;
      }
    } on PlatformException catch (e) {
      _storage.deleteAll();
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return false;
  }

  Future<bool> hasToken() async {
    try {
      final all = await _storage.readAll();
      if (all.containsKey('token')) {
        return true;
      }
    } on PlatformException catch (e) {
      _storage.deleteAll();
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }

    return false;
  }

  Future<void> deleteToken(String variable) async {
    try {
      await _storage.delete(key: variable);
    } on PlatformException catch (e) {
      _storage.deleteAll();
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
  }

  Future<bool> writeToken(String key, String token) async {
    bool saveKeyChain = false;
    try {
      await _storage.write(key: key, value: token);
      saveKeyChain = true;
    } on PlatformException catch (e) {
      _storage.deleteAll();
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }

    return saveKeyChain;
  }

  Future<bool> deleteAll() async {
    bool deleteAll = false;
    try {
      await _storage.deleteAll();
      deleteAll = true;
    } on PlatformException catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });

      _storage.deleteAll();
    }

    return deleteAll;
  }
  //********************STORE END *******************************/
}
