import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qrwallet/models/green_pass.dart';
import 'package:qrwallet/models/simple_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple
///
class QrListData extends ChangeNotifier {
  final List<SimpleCode> _qrList = List.empty(growable: true);

  QrListData() {
    _getData().then((passes) {
      _qrList.clear();
      _qrList.addAll(passes);
      notifyListeners();
    });
  }

  Future<List<SimpleCode>> _getData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final rawData = sharedPrefs.getString("data");
    var needsRewrite = false; // The list must be rewritten to disk

    final diskReadQrList = jsonDecode(rawData ?? "[]")
        .map((e) => e as Map<dynamic, dynamic>)
        .map<SimpleCode>((entry) {
      if (entry.containsKey('greenPassData')) {
        try {
          return GreenPass.fromMap(entry);
        } catch (err) {
          print(err);
          // Error while parsing cached data, reload from raw string data!
          needsRewrite = true;
          return GreenPass.fromMapAndDecode(entry);
        }
      } else {
        return SimpleCode.fromMap(entry);
      }
    }).toList();

    if (needsRewrite) await storeData(diskReadQrList);

    return diskReadQrList;
  }

  UnmodifiableListView<SimpleCode> get passes => UnmodifiableListView(_qrList);

  Future<void> storeData(List<SimpleCode> passes) async {
    _qrList.clear();
    _qrList.addAll(passes);
    _updatePersistenceAndNotify();
  }

  Future<void> replaceQr(SimpleCode toReplace, SimpleCode newQr) async {
    if (!_qrList.contains(toReplace)) {
      return addQr(newQr);
    }

    final oldPassIndex = _qrList.indexOf(toReplace);
    _qrList.replaceRange(oldPassIndex, oldPassIndex + 1, [newQr]);
    _updatePersistenceAndNotify();
  }

  Future<void> deleteQr(SimpleCode toDelete) async {
    _qrList.remove(toDelete);
    _updatePersistenceAndNotify();
  }

  Future<void> addQr(SimpleCode qr) async {
    _qrList.add(qr);
    _updatePersistenceAndNotify();
  }

  Future<void> _updatePersistenceAndNotify() async {
    final rawData = jsonEncode(_qrList.map((e) => e.toMap()).toList());
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString("data", rawData);
    notifyListeners();
  }
}
