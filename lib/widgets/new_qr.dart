import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/screens/post_qr_screen.dart';
import 'package:qrwallet/screens/qr_scan_screen.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/ad_loader.dart';
import 'package:qrwallet/widgets/bottomsheet_container.dart';

class NewQR extends StatefulWidget {
  const NewQR({Key? key}) : super(key: key);

  @override
  _NewQRState createState() => _NewQRState();
}

class _NewQRState extends State<NewQR> {
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      recoverLostData();
      InterstitialAdLoader.instance.loadAd(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return BottomSheetContainer(children: [
        SizedBox(
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        ),
      ]);
    }

    return BottomSheetContainer(children: [
      ListTile(
        title: Text(Localization.of(context)!.translate('take_photo_title')!),
        subtitle: Text(
            Localization.of(context)!.translate('take_photo_description')!),
        isThreeLine: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
              color: Theme.of(context).colorScheme.error),
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => QrScanWidget())),
      ),
      const Divider(height: 1),
      ListTile(
        title: Text(Localization.of(context)!.translate('pick_photo_title')!),
        subtitle: Text(
            Localization.of(context)!.translate('pick_photo_description')!),
        isThreeLine: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.photo,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
              color: Theme.of(context).colorScheme.primary),
        ),
        onTap: () async {
          final photo = await _imagePicker.pickImage(
            source: ImageSource.gallery,
          );

          if (photo != null && !await _handleImageFile(photo.path)) {
            StandardDialogs.showSnackbar(
              context,
              Localization.of(context)!.translate('no_qr_found')!,
            );
            Navigator.pop(context);
          }
        },
      ),
      const Divider(height: 1),
      ListTile(
        title: Text(
            Localization.of(context)!.translate('extract_from_pdf_title')!),
        subtitle: Text(Localization.of(context)!
            .translate('extract_from_pdf_description')!),
        isThreeLine: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.picture_as_pdf,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
              color: Theme.of(context).colorScheme.primaryVariant),
        ),
        onTap: () async {
          final fileResult = await FilePicker.platform.pickFiles(
            allowMultiple: false,
            allowedExtensions: ["pdf"],
            type: FileType.custom,
          );
          final fileResultPath = fileResult?.files.single.path;

          if (fileResultPath != null) {
            setState(() {
              _isLoading = true;
            });
            final success =
                await _handlePdfFile(fileResultPath).catchError((err) {
              print(err);
              return false;
            });
            if (!success) {
              StandardDialogs.showSnackbar(
                context,
                Localization.of(context)!.translate('no_qr_found')!,
              );
              Navigator.pop(context);
            }
          }
        },
      ),
    ]);
  }

  Future<void> recoverLostData() async {
    if (!mounted) {
      print(
          '_NewPassDialogState#recoverLostData() called when already unmounted');
      return;
    }

    final LostDataResponse response = await _imagePicker.retrieveLostData();
    if (response.isEmpty) return;

    if (response.files != null && response.files!.isNotEmpty) {
      _handleImageFile(response.files!.first.path);
    } else {
      print(response.exception);
    }
  }

  Future<bool> _handleImageFile(String imagePath) async {
    final qrContent;
    try {
      qrContent = await QrCodeToolsPlugin.decodeFrom(imagePath);
    } catch (err) {
      print(err);
      return false;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PostQrScreen(
          qrData: qrContent,
          format: BarcodeFormat
              .qrcode, // Only one supported format from gallery/PDF
        ),
      ),
    );

    return true;
  }

  Future<bool> _handlePdfFile(String pdfFile) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = await File(tempDir.path + '/temp_img.tmp.png').create();

    final docPages = Printing.raster(
      await File(pdfFile).readAsBytes(),
      dpi: 220,
    );

    try {
      await for (final docPage in docPages) {
        final docPageBytes = await docPage.toPng();
        await tempFile.writeAsBytes(docPageBytes, flush: true);
        final successResult = await _handleImageFile(tempFile.path);
        if (successResult) return true;
      }
    } finally {
      await tempFile.delete();
    }

    return false;
  }
}
