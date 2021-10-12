import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrwallet/utils/globals.dart';

///
/// A QrImage with an adaptive (white) background
///
class QrBackgroundImage extends StatelessWidget {
  final String data;
  final BarcodeFormat format;

  const QrBackgroundImage(this.data, this.format, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(format.toString() + " - " + data);
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = max(
      colorScheme.background.value,
      colorScheme.onBackground.value,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(Globals.borderRadius),
      child: Container(
        color: Color(backgroundColor),
        padding: const EdgeInsets.all(4),
        child: QrImage(
          data: data,
          gapless: false,
        ),
      ),
    );
  }
}
