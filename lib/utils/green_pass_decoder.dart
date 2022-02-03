import 'dart:io';

import 'package:cbor/cbor.dart';
import 'package:dart_base45/dart_base45.dart';
import 'package:flutter/widgets.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/utils.dart';

class GreenPassDecoder {
  GreenPassData decode(String stringData) {
    final compressedBytes = Base45.decode(stringData.substring(4));
    final bytes = zlib.decoder.convert(compressedBytes);
    final cbor = Cbor();
    cbor.decodeFromList(bytes);
    final cborData = cbor.getDecodedData()![0][2];
    cbor.clearDecodeStack();
    cbor.decodeFromList(cborData);

    final data = cbor.getDecodedData()![0][-260][1] as Map<dynamic, dynamic>;

    String name = data['nam']['gn'].toString().capitalizeWords();
    String surname = data['nam']['fn'].toString().capitalizeWords();

    final String issueDate;
    if (data.containsKey('v')) {
      // Vaccination
      issueDate = data['v'][0]['dt'];
      return VaccinationGreenPassData(
        name: name,
        surname: surname,
        issueDate: DateTime.parse(issueDate),
        doses: int.parse(data['v'][0]['dn'].toString()),
      );
    } else if (data.containsKey('t')) {
      // Test
      issueDate = data['t'][0]['sc'];
      return TestGreenPassData(
        name: name,
        surname: surname,
        issueDate: DateTime.parse(issueDate),
        isRapid: data['t'][0].containsKey('ma'),
      );
    } else if (data.containsKey('r')) {
      // Recovery
      issueDate = data['r'][0]['df'];
      return RecoveryGreenPassData(
        name: name,
        surname: surname,
        issueDate: DateTime.parse(issueDate),
      );
    } else {
      throw Exception("Unknown pass type: ${data.keys.join(", ")}");
    }
  }

  GreenPassData? tryDecode(String stringData) {
    try {
      return decode(stringData);
    } catch (err) {
      print(err);
      return null;
    }
  }
}

abstract class GreenPassData {
  final String name;
  final String surname;
  final DateTime issueDate;

  GreenPassData({
    required this.name,
    required this.surname,
    required this.issueDate,
  });

  factory GreenPassData.fromMap(Map<dynamic, dynamic> data) {
    switch (data['type']) {
      case VaccinationGreenPassData.typeName:
        return VaccinationGreenPassData.fromMap(data);
      case RecoveryGreenPassData.typeName:
        return RecoveryGreenPassData.fromMap(data);
      case TestGreenPassData.typeName:
        return TestGreenPassData.fromMap(data);
      default:
        throw ArgumentError('Unknown type while parsing: ${data['type']}');
    }
  }

  Map<String, String> toMap() => {
        'name': name,
        'surname': surname,
        'issueDate': issueDate.toIso8601String(),
        'type': type,
      };

  String get displayDescription => 'Green Pass - $name';

  String get translationKey;

  String get type;

  String displayName(BuildContext context) =>
      Localization.of(context)!.translate(translationKey)!;
}

class VaccinationGreenPassData extends GreenPassData {
  static const String typeName = 'VACCINATION';
  final int doses;

  VaccinationGreenPassData({
    required String name,
    required String surname,
    required DateTime issueDate,
    required this.doses,
  }) : super(name: name, surname: surname, issueDate: issueDate);

  factory VaccinationGreenPassData.fromMap(Map<dynamic, dynamic> data) =>
      VaccinationGreenPassData(
        name: data['name'],
        surname: data['surname'],
        issueDate: DateTime.parse(data['issueDate']),
        doses: int.parse(data['doses']),
      );

  @override
  Map<String, String> toMap() {
    return super.toMap()
      ..addAll({
        'doses': doses.toString(),
      });
  }

  @override
  String get translationKey => 'green_pass_vaccination';

  @override
  String displayName(BuildContext context) {
    return super.displayName(context) + " (n. $doses)";
  }

  @override
  String get type => typeName;
}

class TestGreenPassData extends GreenPassData {
  final bool isRapid;
  static const String typeName = 'TEST';

  TestGreenPassData({
    required String name,
    required String surname,
    required DateTime issueDate,
    required this.isRapid,
  }) : super(name: name, surname: surname, issueDate: issueDate);

  factory TestGreenPassData.fromMap(Map<dynamic, dynamic> data) =>
      TestGreenPassData(
        name: data['name'],
        surname: data['surname'],
        issueDate: DateTime.parse(data['issueDate']),
        isRapid: data['rapid'] == 'true',
      );

  @override
  Map<String, String> toMap() {
    return super.toMap()..addAll({'rapid': isRapid.toString()});
  }

  @override
  String get translationKey => 'green_pass_test';

  @override
  String displayName(BuildContext context) {
    return super.displayName(context) + " (${isRapid ? 48 : 72}h)";
  }

  @override
  String get type => typeName;
}

class RecoveryGreenPassData extends GreenPassData {
  static const String typeName = 'RECOVERY';

  RecoveryGreenPassData({
    required String name,
    required String surname,
    required DateTime issueDate,
  }) : super(name: name, surname: surname, issueDate: issueDate);

  factory RecoveryGreenPassData.fromMap(Map<dynamic, dynamic> data) =>
      RecoveryGreenPassData(
        name: data['name'],
        surname: data['surname'],
        issueDate: DateTime.parse(data['issueDate']),
      );

  @override
  String get translationKey => 'green_pass_recovery';

  @override
  String get type => typeName;
}
