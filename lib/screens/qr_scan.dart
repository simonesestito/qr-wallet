import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/models/data.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:greenpass/utils/standard_dialogs.dart';
import 'package:greenpass/widgets/button_wide_outlined.dart';
import 'package:greenpass/widgets/title_headline.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

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
      body: Column(
        children: [
          // TODO Maybe put a trailing button to better explain the screen, alignment problem
          TitleHeadline(
            title: Localization.of(context)!.translate('qr_title')!,
            backBtn: true,
          ),
          Expanded(
            flex: 15,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                  result.isNotEmpty
                      ? result
                      : Localization.of(context)!.translate('scan_a_code')!,
                  style: Theme.of(context).textTheme.headline6),
            ),
          ),
          Expanded(
            flex: 2,
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
                    text: flashOn ? 'Spegni flash' : 'Accendi flash',
                  ),
                ),
                Flexible(
                  child: ButtonWideOutlined(
                    padding: 8,
                    action: () async {
                      await _qrViewController?.flipCamera();
                      setState(() {});
                    },
                    text: 'Cambia fotocamera',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // Ensure the Scanner view is properly sized after rotation (the app won'r rotate tho)
    return QRView(
      key: qrKey,
      formatsAllowed: [BarcodeFormat.qrcode],
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.secondary,
          borderRadius: Globals.borderRadius,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      // Define what happens when the permission is not granted
      onPermissionSet: (ctrl, granted) {
        if (!granted) {
          CommonDialogs.showSnackbar(context,
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
          builder: (_) => PostQrScanWidget(qrData: scan.code),
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

class PostQrScanWidget extends StatelessWidget {
  final String qrData;
  final TextEditingController nameFieldController = TextEditingController();

  PostQrScanWidget({required this.qrData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(Localization.of(context)!.translate('qr_found')!,
                style: Theme.of(context).textTheme.headline3),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: QrImage(data: qrData),
            ),
            Text('TODO: Forzare richiesta di un nome inserito qui.'),
            TextField(
              controller: nameFieldController,
              decoration: InputDecoration(
                icon: Icon(Icons.edit),
                labelText: Localization.of(context)!.translate('name')!,
              ),
            ),
            ElevatedButton(
              child: Text(Localization.of(context)!.translate('save')!),
              onPressed: () async {
                await context.read<GreenPassListData>().addData(GreenPass(
                      alias: nameFieldController.value.text,
                      qrData: this.qrData,
                    ));
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            )
          ],
        ),
      ),
    );
  }
}