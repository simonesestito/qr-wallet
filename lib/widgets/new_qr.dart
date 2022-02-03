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
import 'package:screenshot/screenshot.dart';

class NewQR extends StatefulWidget {
  final String? selectedFilePath;

  const NewQR({
    Key? key,
    this.selectedFilePath,
  }) : super(key: key);

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
      InterstitialAdLoader.instance.loadAd(context);

      if (widget.selectedFilePath == null) {
        recoverLostData();
      } else {
        setState(() {
          _isLoading = true;
        });
        Future.delayed(
          Duration(seconds: 2), // Wait a bit until an ad is loaded
          () {
            if (widget.selectedFilePath?.endsWith(".pdf") == true)
              handlePdfFileUi(widget.selectedFilePath, context);
            else
              handleImageFileUi(widget.selectedFilePath, context);
          },
        );
      }
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
      Padding(
        padding: const EdgeInsets.only(
          left: Globals.buttonPadding,
          right: Globals.buttonPadding,
          bottom: 8,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Globals.borderRadius),
            color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.share_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                Localization.of(context)!.translate('additional_detail_share')!,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
          setState(() {
            _isLoading = true;
          });
          await handleImageFileUi(photo?.path, context);
          setState(() {
            _isLoading = false;
          });
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
          handlePdfFileUi(fileResult?.files.single.path, context);
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

  Future<void> handleImageFileUi(
      String? imagePath, BuildContext context) async {
    if (imagePath != null && !await _handleImageFile(imagePath)) {
      StandardDialogs.showSnackbar(
        context,
        Localization.of(context)!.translate('no_qr_found')!,
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _handleImageFile(String imagePath) async {
    final qrContent;
    try {
      // FIX: Add padding around the given image
      final imageFile = File.fromUri(Uri.file(imagePath));
      final paddedImageBytes = await ScreenshotController().captureFromWidget(
        Padding(
          padding: EdgeInsets.all(128),
          child: Image.file(imageFile),
        ),
      );
      await imageFile.writeAsBytes(paddedImageBytes);
      // Give the padded image to the library
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

  Future<void> handlePdfFileUi(String? pdfFile, BuildContext context) async {
    if (pdfFile != null) {
      setState(() {
        _isLoading = true;
      });

      final success = await _handlePdfFile(pdfFile).catchError((err) {
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
