import 'dart:io';

import 'package:cbor/cbor.dart';
import 'package:dart_base45/dart_base45.dart';
import 'package:flutter/foundation.dart';
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

    final String issueDate;
    final GreenPassType passType;
    if (data.containsKey('v')) {
      // Vaccination
      issueDate = data['v'][0]['dt'];
      passType = GreenPassType.VACCINATION;
    } else if (data.containsKey('t')) {
      // Test
      issueDate = data['t'][0]['sc'];
      passType = GreenPassType.TEST;
    } else if (data.containsKey('r')) {
      // Recovery
      issueDate = data['r'][0]['df'];
      passType = GreenPassType.RECOVERY;
    } else {
      throw Exception("Unknown pass type: ${data.keys.join(", ")}");
    }

    return GreenPassData(
      name: data['nam']['gn'].toString().capitalizeWords(),
      surname: data['nam']['fn'].toString().capitalizeWords(),
      issueDate: issueDate,
      type: passType,
    );
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

class GreenPassData {
  final String name;
  final String surname;
  final String issueDate;
  final GreenPassType type;

  GreenPassData({
    required this.name,
    required this.surname,
    required this.issueDate,
    required this.type,
  });

  factory GreenPassData.fromMap(Map<dynamic, dynamic> data) => GreenPassData(
        name: data['name'],
        surname: data['surname'],
        issueDate: data['issueDate'],
        type: GreenPassType.values
            .firstWhere((e) => describeEnum(e) == data['type']),
      );

  Map<String, String> toMap() => {
        'name': name,
        'surname': surname,
        'issueDate': issueDate,
        'type': describeEnum(type),
      };

  String get displayDescription => 'Green Pass - $name';
}

enum GreenPassType {
  VACCINATION,
  TEST,
  RECOVERY,
}

extension GreenPassToString on GreenPassType {
  String get translationKey =>
      {
        GreenPassType.RECOVERY: 'green_pass_recovery',
        GreenPassType.TEST: 'green_pass_test',
        GreenPassType.VACCINATION: 'green_pass_vaccination',
      }[this] ??
      'green_pass_unknown';
}
