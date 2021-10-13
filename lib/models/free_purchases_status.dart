import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreePurchasesStatus {
  static const SHARED_PREFS_KEY_PREFIX = 'free_purchase_status';
  static const AES_KEY = 'l80dYsmNby2sQgk2oc6OdI7/deh7g9kmrYg9EVXLPuA=';
  static const AES_IV = 'vMgOe5qIARSeFi1FZANbOw==';

  static final instance = FreePurchasesStatus._();

  FreePurchasesStatus._();

  Future<void> addFreePurchase(String sku, Duration duration) async {
    final startDate = await _getCurrentDate();
    final endDate = startDate.add(duration);
    await _writeDateTime(_keyFor(sku), endDate);
  }

  Future<bool> getFreePurchaseStatus(String sku) async {
    final currentDate = await _getCurrentDate();
    final endDate = await _readDateTime(_keyFor(sku));
    return endDate.isAfter(currentDate);
  }

  String _keyFor(String sku) => SHARED_PREFS_KEY_PREFIX + ":" + sku;

  Future<int> _getCurrentMillis() async {
    try {
      final response = await http.get(Uri.parse(
        'https://currentmillis.com/time/minutes-since-unix-epoch.php',
      ));
      final minutesSinceEpoch = int.parse(response.body);
      return minutesSinceEpoch * 60 * 1000;
    } catch (err) {
      debugPrint(err.toString());
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<DateTime> _getCurrentDate() => _getCurrentMillis()
      .then((millis) => DateTime.fromMillisecondsSinceEpoch(millis));

  Future<DateTime> _readDateTime(String key) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final encryptedValue = sharedPrefs.getString(key) ?? '';
    if (encryptedValue.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final encryptedBytes = base64Decode(encryptedValue);
    final decryptedBytes = _aesCbcDecrypt(encryptedBytes);
    final timeParts = decryptedBytes.toList();
    var readMillis = 0;
    timeParts.forEach((part) {
      readMillis = readMillis * 128 + part;
    });
    return DateTime.fromMillisecondsSinceEpoch(readMillis);
  }

  Future<void> _writeDateTime(String key, DateTime date) async {
    final sharedPrefs = await SharedPreferences.getInstance();

    var millis = date.millisecondsSinceEpoch;
    final timeParts = List<int>.empty(growable: true);
    while (millis > 0) {
      timeParts.add(millis % 128);
      millis = millis ~/ 128;
    }

    final encryptedBytes = _aesCbcEncrypt(timeParts);
    final encryptedValue = base64Encode(encryptedBytes);
    await sharedPrefs.setString(key, encryptedValue);
  }

  Uint8List _aesCbcEncrypt(List<int> plainText) {
    // Create a CBC block cipher with AES, and initialize with key and IV
    final key = base64Decode(AES_KEY);
    final iv = base64Decode(AES_IV);
    final paddingLength = iv.length - plainText.length;
    final paddedPlainText = Uint8List.fromList(
        List.filled(paddingLength, 0, growable: true)..addAll(plainText));

    final cbc = CBCBlockCipher(AESFastEngine())
      ..init(true, ParametersWithIV(KeyParameter(key), iv)); // true=encrypt

    // Encrypt the plaintext block-by-block

    final cipherText = Uint8List(paddedPlainText.length); // allocate space
    cbc.processBlock(paddedPlainText, 0, cipherText, 0);

    return cipherText;
  }

  Uint8List _aesCbcDecrypt(Uint8List cipherText) {
    // Create a CBC block cipher with AES, and initialize with key and IV
    final key = base64Decode(AES_KEY);
    final iv = base64Decode(AES_IV);

    final cbc = CBCBlockCipher(AESFastEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv)); // false=decrypt

    // Decrypt the cipherText block-by-block

    final paddedPlainText = Uint8List(cipherText.length); // allocate space
    cbc.processBlock(cipherText, 0, paddedPlainText, 0);

    return paddedPlainText;
  }
}
