import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreenPass {
  final String alias;
  final String qrData;

  GreenPass({
    required this.alias,
    required this.qrData,
  });

  factory GreenPass.fromMap(Map<String, dynamic> data) => GreenPass(
        alias: data['alias']!,
        qrData: data['qrData']!,
      );

  Map<String, String> toMap() => {
        'alias': alias,
        'qrData': qrData,
      };

  GreenPass copyWith({
    String? alias,
    String? qrData,
  }) {
    return GreenPass(
      alias: alias ?? this.alias,
      qrData: qrData ?? this.qrData,
    );
  }
}

///
/// https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple
///
class GreenPassListData extends ChangeNotifier {
  final List<GreenPass> _passesList = List.empty(growable: true);

  GreenPassListData() {
    _getData().then((passes) {
      _passesList.addAll(passes);
      notifyListeners();
    });
  }

  Future<List<GreenPass>> _getData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final data = jsonDecode(sharedPrefs.getString("data") ?? "[]") as List;
    return data.map((e) => GreenPass.fromMap(e)).toList();
  }

  UnmodifiableListView<GreenPass> get passes =>
      UnmodifiableListView(_passesList);

  Future<void> storeData(List<GreenPass> passes) async {
    _passesList.clear();
    _passesList.addAll(passes);
    _updatePersistenceAndNotify();
  }

  Future<void> replacePass(GreenPass toReplace, GreenPass newPass) async {
    if (!_passesList.contains(toReplace)) {
      return addData(newPass);
    }

    final oldPassIndex = _passesList.indexOf(toReplace);
    _passesList.replaceRange(oldPassIndex, oldPassIndex + 1, [newPass]);
    _updatePersistenceAndNotify();
  }

  Future<void> deletePass(GreenPass toDelete) async {
    _passesList.remove(toDelete);
    _updatePersistenceAndNotify();
  }

  Future<void> addData(GreenPass greenPass) async {
    _passesList.add(greenPass);
    _updatePersistenceAndNotify();
  }

  Future<void> _updatePersistenceAndNotify() async {
    final rawData = jsonEncode(_passesList.map((e) => e.toMap()).toList());
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString("data", rawData);
    notifyListeners();
  }
}
