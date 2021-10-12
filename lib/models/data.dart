import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleQr {
  final String alias;
  final String qrData;
  final BarcodeFormat format;

  SimpleQr({
    required this.alias,
    required this.qrData,
    required this.format,
  });

  factory SimpleQr.fromMap(Map<dynamic, dynamic> data) => SimpleQr(
        alias: data['alias']!,
        qrData: data['qrData']!,
        format: BarcodeFormat.values.firstWhere(
          (format) => describeEnum(format) == data['format'],
          orElse: () => BarcodeFormat.qrcode,
        ),
      );

  Map<String, dynamic> toMap() =>
      {
        'alias': alias,
        'qrData': qrData,
        'format': describeEnum(format),
      };

  SimpleQr copyWith({
    String? alias,
    String? qrData,
    BarcodeFormat? format,
  }) {
    return SimpleQr(
      alias: alias ?? this.alias,
      qrData: qrData ?? this.qrData,
      format: format ?? this.format,
    );
  }
}

class GreenPass extends SimpleQr {
  final GreenPassData greenPassData;

  GreenPass({
    required String alias,
    required String qrData,
    required this.greenPassData,
  }) : super(alias: alias, qrData: qrData, format: BarcodeFormat.qrcode);

  factory GreenPass.fromMap(Map<dynamic, dynamic> data) => GreenPass(
        alias: data['alias']!,
        qrData: data['qrData']!,
        greenPassData: GreenPassData.fromMap(data['greenPassData']),
      );

  @override
  Map<String, dynamic> toMap() => {
        'alias': alias,
        'qrData': qrData,
        'greenPassData': greenPassData.toMap(),
      };

  @override
  GreenPass copyWith({
    String? alias,
    String? qrData,
    GreenPassData? passData,
    BarcodeFormat? format, // Ignored as it's always QR code
  }) {
    return GreenPass(
      alias: alias ?? this.alias,
      qrData: qrData ?? this.qrData,
      greenPassData: passData ?? greenPassData,
    );
  }
}

///
/// https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple
///
class QrListData extends ChangeNotifier {
  final List<SimpleQr> _qrList = List.empty(growable: true);

  QrListData() {
    _getData().then((passes) {
      _qrList.addAll(passes);
      notifyListeners();
    });
  }

  Future<List<SimpleQr>> _getData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final rawData = sharedPrefs.getString("data");
    return jsonDecode(rawData ?? "[]")
        .map((e) => e as Map<dynamic, dynamic>)
        .map<SimpleQr>((e) {
      if (e.containsKey('greenPassData')) {
        return GreenPass.fromMap(e);
      } else {
        return SimpleQr.fromMap(e);
      }
    }).toList();
  }

  UnmodifiableListView<SimpleQr> get passes => UnmodifiableListView(_qrList);

  Future<void> storeData(List<GreenPass> passes) async {
    _qrList.clear();
    _qrList.addAll(passes);
    _updatePersistenceAndNotify();
  }

  Future<void> replaceQr(SimpleQr toReplace, SimpleQr newQr) async {
    if (!_qrList.contains(toReplace)) {
      return addQr(newQr);
    }

    final oldPassIndex = _qrList.indexOf(toReplace);
    _qrList.replaceRange(oldPassIndex, oldPassIndex + 1, [newQr]);
    _updatePersistenceAndNotify();
  }

  Future<void> deleteQr(SimpleQr toDelete) async {
    _qrList.remove(toDelete);
    _updatePersistenceAndNotify();
  }

  Future<void> addQr(SimpleQr qr) async {
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
