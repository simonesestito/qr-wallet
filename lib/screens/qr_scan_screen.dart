import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/screens/post_qr_screen.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';
import 'package:qrwallet/widgets/qr_background_image.dart';
import 'package:qrwallet/widgets/title_headline.dart';

class QrScanWidget extends StatefulWidget {
  const QrScanWidget({Key? key}) : super(key: key);

  @override
  _QrScanWidgetState createState() => _QrScanWidgetState();
}

class _QrScanWidgetState extends State<QrScanWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrViewController;
  String result = '';
  bool flashOn = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrViewController?.pauseCamera();
    } else if (Platform.isIOS) {
      _qrViewController?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TitleHeadline(
              title: Localization.of(context)!.translate('qr_title')!,
              backBtn: true,
              trailingBtn: Icons.info,
              trailingBtnAction: () =>
                  StandardDialogs.showQrInfoDialog(context),
            ),
            Expanded(
              flex: 32,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  _buildQrView(context),
                  Container(
                    width: double.infinity,
                    height: Globals.borderRadius,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Globals.borderRadius),
                        topRight: Radius.circular(Globals.borderRadius),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      height: Globals.borderRadius,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(Globals.borderRadius),
                          bottomRight: Radius.circular(Globals.borderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ButtonWideOutlined(
                      padding: 8,
                      action: () async {
                        await _qrViewController?.toggleFlash();
                        flashOn = (await _qrViewController?.getFlashStatus())!;
                        setState(() {});
                      },
                      text: flashOn
                          ? Localization.of(context)!
                              .translate('turn_flash_off')!
                          : Localization.of(context)!
                              .translate('turn_flash_on')!,
                    ),
                  ),
                  Flexible(
                    child: ButtonWideOutlined(
                      padding: 8,
                      action: () async {
                        await _qrViewController?.flipCamera();
                        setState(() {});
                      },
                      text:
                          Localization.of(context)!.translate('switch_camera')!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // Ensure the Scanner view is properly sized after rotation (the app won't rotate tho)
    return QRView(
      key: qrKey,
      formatsAllowed: QrBackgroundImage.barcodeFormatMap.keys.toList(),
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).colorScheme.secondary,
        borderRadius: Globals.borderRadius,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      // Define what happens when the permission is not granted
      onPermissionSet: (ctrl, granted) {
        if (!granted) {
          StandardDialogs.showSnackbar(context,
              Localization.of(context)!.translate('camera_permission_denied')!);
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._qrViewController = controller;
    controller.scannedDataStream.first.then((scan) async {
      await this._qrViewController?.pauseCamera();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PostQrScreen(qrData: scan.code, format: scan.format),
        ),
      );
    });
  }

  @override
  void dispose() {
    try {
      _qrViewController?.dispose();
    } catch (ignored) {}
    super.dispose();
  }
}
