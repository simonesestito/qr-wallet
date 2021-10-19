import 'dart:math';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as scanner;
import 'package:qrwallet/utils/globals.dart';

///
/// A QrImage with an adaptive (white) background
///
class QrBackgroundImage extends StatelessWidget {
  final String data;
  final scanner.BarcodeFormat format;

  static final barcodeFormatMap =
  Map<scanner.BarcodeFormat, Barcode>.unmodifiable({
    scanner.BarcodeFormat.qrcode: Barcode.qrCode(),
    scanner.BarcodeFormat.aztec: Barcode.aztec(),
    scanner.BarcodeFormat.code39: Barcode.code39(),
    scanner.BarcodeFormat.code93: Barcode.code93(),
    scanner.BarcodeFormat.code128: Barcode.code128(),
    scanner.BarcodeFormat.dataMatrix: Barcode.dataMatrix(),
    scanner.BarcodeFormat.ean8: Barcode.ean8(),
    scanner.BarcodeFormat.ean13: Barcode.ean13(),
    scanner.BarcodeFormat.itf: Barcode.itf(),
  });

  const QrBackgroundImage(this.data, this.format, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = max(
      colorScheme.background.value,
      colorScheme.onBackground.value,
    );

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        child: BarcodeWidget(
          padding: const EdgeInsets.all(Globals.borderRadius),
          barcode: barcodeFormatMap[format] ?? Barcode.qrCode(),
          data: data,
          backgroundColor: Color(backgroundColor),
        ),
      ),
    );
  }
}
