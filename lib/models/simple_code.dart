import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SimpleCode {
  final String alias;
  final String qrData;
  final BarcodeFormat format;

  SimpleCode({
    required this.alias,
    required this.qrData,
    required this.format,
  });

  factory SimpleCode.fromMap(Map<dynamic, dynamic> data) => SimpleCode(
        alias: data['alias']!,
        qrData: data['qrData']!,
        format: BarcodeFormat.values.firstWhere(
          (format) => describeEnum(format) == data['format'],
          orElse: () => BarcodeFormat.qrcode,
        ),
      );

  Map<String, dynamic> toMap() => {
        'alias': alias,
        'qrData': qrData,
        'format': describeEnum(format),
      };

  SimpleCode copyWith({
    String? alias,
    String? qrData,
    BarcodeFormat? format,
  }) {
    return SimpleCode(
      alias: alias ?? this.alias,
      qrData: qrData ?? this.qrData,
      format: format ?? this.format,
    );
  }
}
