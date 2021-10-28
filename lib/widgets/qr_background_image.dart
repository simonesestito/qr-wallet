import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as scanner;
import 'package:qrwallet/utils/completable_future.dart';
import 'package:qrwallet/utils/globals.dart';

///
/// A QrImage with an adaptive (white) background
///
class QrBackgroundImage extends StatelessWidget {
  static const QR_IMAGES_SUB_DIR = '/qr_codes_render';
  final String data;
  final scanner.BarcodeFormat format;
  final _repaintKey = GlobalKey();
  late final LateFuture postRenderSaving;

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

  QrBackgroundImage(this.data, this.format, {Key? key}) : super(key: key) {
    postRenderSaving = LateFuture(() => Future.delayed(
          Duration(milliseconds: 160),
          _saveRenderedQr,
        ));
  }

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
        child: SizedBox.expand(
          child: Image.file(File(_renderedQrPath()),
              errorBuilder: (context, err, __) {
            print('QR code not found in cache: ${_renderedQrPath()}');
            print('Error:');
            print(err);

            postRenderSaving.execute();

            return RepaintBoundary(
              key: _repaintKey,
              child: BarcodeWidget(
                padding: const EdgeInsets.all(Globals.borderRadius),
                barcode: barcodeFormatMap[format] ?? Barcode.qrCode(),
                data: data,
                backgroundColor: Color(backgroundColor),
              ),
            );
          }),
        ),
      ),
    );
  }

  ///
  /// Filename for the already rendered QR
  ///
  String _renderedQrPath() {
    final dir =
        Globals.cacheDirectory.cachedResult!.absolute.path + QR_IMAGES_SUB_DIR;
    final bytesData = Utf8Encoder().convert(data);
    final hash = md5.convert(bytesData).bytes;
    final filename = hex.encode(hash) + '.png';
    return dir + '/' + filename;
  }

  void _saveRenderedQr() async {
    if (_repaintKey.currentContext == null) {
      print('_saveRenderedQr: BuildContext is null');
      return;
    }

    final RenderRepaintBoundary? render = _repaintKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary?;
    if (render == null) {
      print('_saveRenderedQr: Render Object is null');
      return;
    }

    try {
      final image = await render.toImage(pixelRatio: 5);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final filePath = await _renderedQrPath();
      final pngData = bytes!.buffer.asUint8List();
      await File(filePath).writeAsBytes(pngData, flush: true);
    } catch (err) {
      print('_saveRenderedQr: Error encountered');
      print(err);
    }
  }
}
