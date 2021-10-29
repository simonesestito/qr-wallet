import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as scanner;
import 'package:qrwallet/utils/globals.dart';
import 'package:screenshot/screenshot.dart';

///
/// A QrImage with an adaptive (white) background
///
class QrBackgroundImage extends StatefulWidget {
  static const QR_IMAGES_SUB_DIR = '/qr_codes_render';
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

  QrBackgroundImage(this.data, this.format, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrBackgroundImageState();
}

class _QrBackgroundImageState extends State<QrBackgroundImage> {
  @override
  Widget build(BuildContext context) {
    final qrImagePath = _renderedQrPath();
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        child: qrImagePath.existsSync() && qrImagePath.lengthSync() > 0
            ? Image.file(
                qrImagePath,
                errorBuilder: (context, err, __) {
                  print('QrBackgroundImage: $err');
                  return _renderAndDisplayEmpty(qrImagePath);
                },
              )
            : _renderAndDisplayEmpty(qrImagePath),
      ),
    );
  }

  Widget _renderAndDisplayEmpty(File qrImagePath) {
    final backgroundColor = Color(0xfff5f5f5);
    // FIXME: Background color is only used when first rendering.
    //        If theme is changed, cache must be invalidated to
    //        perform a rendering again and save the updated image in cache.

    ScreenshotController()
        .captureFromWidget(
          AspectRatio(
            aspectRatio: 1,
            child: BarcodeWidget(
              barcode: QrBackgroundImage.barcodeFormatMap[widget.format] ??
                  Barcode.qrCode(),
              data: widget.data,
              backgroundColor: backgroundColor,
              style: const TextStyle(color: Colors.black),
              padding: const EdgeInsets.all(Globals.borderRadius),
            ),
          ),
          delay: Duration(milliseconds: 100),
          pixelRatio: 4,
          context: context,
        )
        .then(
          (pngData) => qrImagePath.writeAsBytes(pngData, flush: true),
        )
        .then((_) => setState(() {}));

    return Container();
  }

  ///
  /// Filename for the already rendered QR
  ///
  File _renderedQrPath() {
    final dir = Globals.cacheDirectory.cachedResult!.absolute.path +
        QrBackgroundImage.QR_IMAGES_SUB_DIR;
    final bytesData = Utf8Encoder().convert(widget.data);
    final hash = md5.convert(bytesData).bytes;
    final filename = hex.encode(hash) + '.png';
    return File(dir + '/' + filename);
  }
}
