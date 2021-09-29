import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/data.dart';
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
  bool _isFlashOn = false;

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
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            onPermissionSet: (controller, permission) {
              if (!permission)
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.of(context).pop();
                });
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                padding: EdgeInsets.only(top: 64),
                iconSize: 48,
                icon: Icon(_isFlashOn ? Icons.flash_off : Icons.flash_on),
                onPressed: () async {
                  await _qrViewController?.toggleFlash();
                  final newFlashStatus =
                      await _qrViewController?.getFlashStatus();
                  setState(() {
                    this._isFlashOn = newFlashStatus ?? false;
                  });
                }),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this._qrViewController = controller;
    controller.scannedDataStream
        .firstWhere((scan) => scan.format == BarcodeFormat.qrcode)
        .then((scan) {
          this._qrViewController?.dispose();
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
    } catch (ignored) { }
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
            Text("QR trovato!", style: Theme.of(context).textTheme.headline3),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: QrImage(data: qrData),
            ),
            Text("TODO: Forzare richiesta di un nome inserito qui."),
            TextField(
              controller: nameFieldController,
              decoration: InputDecoration(
                icon: Icon(Icons.edit),
                labelText: "Nome",
              ),
            ),
            ElevatedButton(
              child: Text("SALVA"),
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
