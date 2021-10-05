import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/screens/post_qr_form.dart';
import 'package:greenpass/screens/qr_scan.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

class NewPassDialog extends StatefulWidget {
  const NewPassDialog({Key? key}) : super(key: key);

  @override
  _NewPassDialogState createState() => _NewPassDialogState();
}

class _NewPassDialogState extends State<NewPassDialog> {
  final _imagePicker = ImagePicker();
  static const MAX_PDF_PAGES = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      recoverLostData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              Globals.borderRadius,
            ),
            child: Container(
              height: 4,
              width: 30,
              color: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .color!
                  .withOpacity(0.4),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            title:
                Text(Localization.of(context)!.translate('take_photo_title')!),
            subtitle: Text(
                Localization.of(context)!.translate('take_photo_description')!),
            isThreeLine: true,
            leading: Icon(Icons.camera_alt),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => QrScanWidget())),
          ),
          const Divider(height: 1),
          ListTile(
            title:
                Text(Localization.of(context)!.translate('pick_photo_title')!),
            subtitle: Text(
                Localization.of(context)!.translate('pick_photo_description')!),
            isThreeLine: true,
            leading: Icon(Icons.photo),
            onTap: () async {
              final photo = await _imagePicker.pickImage(
                source: ImageSource.gallery,
              );

              if (photo != null && !await _handleImageFile(photo.path)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Localization.of(context)!.translate('no_qr_found')!,
                    ),
                  ),
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
            leading: Icon(Icons.picture_as_pdf),
            onTap: () async {
              final fileResult = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ["pdf"],
                type: FileType.custom,
              );
              final fileResultPath = fileResult?.files.single.path;

              if (fileResultPath != null) {
                await _handlePdfFile(fileResultPath);
              }
            },
          ),
        ],
      ),
    );
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
      MaterialPageRoute(builder: (_) => PostQrForm(qrData: qrContent)),
    );

    return true;
  }

  Future<void> _handlePdfFile(String pdfFile) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = await File(tempDir.path + '/temp_img.tmp.png').create();

    final docPages = Printing.raster(
      await File(pdfFile).readAsBytes(),
      dpi: 140,
    );

    await for (final docPage in docPages) {
      final docPageBytes = await docPage.toPng();
      await tempFile.writeAsBytes(docPageBytes, flush: true);
      final successResult = await _handleImageFile(tempFile.path);
      if (successResult) break;
    }

    await tempFile.delete();
  }
}
