import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/screens/qr_scan.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
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
            leading: Icon(Icons.photo),
            onTap: () async {
              final photo = await _imagePicker.pickImage(
                source: ImageSource.gallery,
              );
              if (photo != null) {
                if (!await _handleImageFile(photo.path)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Localization.of(context)!.translate('no_qr_found')!,
                      ),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
                Localization.of(context)!.translate('extract_from_pdf_title')!),
            subtitle: Text(Localization.of(context)!
                .translate('extract_from_pdf_description')!),
            leading: Icon(Icons.picture_as_pdf),
            onTap: () async {
              final fileResult = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                allowedExtensions: ["pdf"],
                type: FileType.custom,
              );
              final fileResultPath = fileResult?.files.single.path;

              if (fileResultPath != null) {
                await _handlePdfFile(fileResultPath); //, context);
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
    final qrContent = await QrCodeToolsPlugin.decodeFrom(imagePath);

    if (qrContent.isEmpty) {
      return false;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PostQrScanWidget(qrData: qrContent)),
    );

    return true;
  }

  Future<void> _handlePdfFile(String pdfFile) async {
    final doc = await PdfDocument.openFile(pdfFile);

    if (doc.pageCount > MAX_PDF_PAGES || doc.isEncrypted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localization.of(context)!.translate('pdf_too_big')!,
          ),
        ),
      );
    } else {
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File(tempDir.path + '/temp_img.tmp.png').create();

      for (int i = 1; i <= doc.pageCount; i++) {
        final page = await doc.getPage(i);
        final pageImage = await page.render();
        final image = await pageImage.createImageDetached();
        final imageBytes = await image.toByteData(format: ImageByteFormat.png);
        await tempFile.writeAsBytes(imageBytes!.buffer.asUint8List(),
            flush: true);
        final successResult = await _handleImageFile(tempFile.path);
        image.dispose();

        if (successResult) break;
      }

      await tempFile.delete();
    }

    doc.dispose();
  }
}
