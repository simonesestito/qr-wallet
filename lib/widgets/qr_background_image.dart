import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrwallet/utils/globals.dart';

///
/// A QrImage with an adaptive (white) background
///
class QrBackgroundImage extends StatelessWidget {
  final String data;

  const QrBackgroundImage(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = max(
      colorScheme.background.value,
      colorScheme.onBackground.value,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(Globals.borderRadius),
      child: QrImage(
        data: data,
        backgroundColor: Color(backgroundColor),
      ),
    );
  }
}
