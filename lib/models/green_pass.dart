import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';

import 'simple_code.dart';

class GreenPass extends SimpleCode {
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
