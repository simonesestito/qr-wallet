import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/screens/post_qr_form.dart';
import 'package:qrwallet/screens/qr_scan.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/bottomsheet_container.dart';

class NewPassDialog extends StatefulWidget {
  const NewPassDialog({Key? key}) : super(key: key);

  @override
  _NewPassDialogState createState() => _NewPassDialogState();
}

class _NewPassDialogState extends State<NewPassDialog> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      recoverLostData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(children: [
      ListTile(
        title: Text(Localization.of(context)!.translate('take_photo_title')!),
        subtitle: Text(
            Localization.of(context)!.translate('take_photo_description')!),
        isThreeLine: true,
        leading: Icon(Icons.camera_alt),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => QrScanWidget())),
      ),
      const Divider(height: 1),
      ListTile(
        title: Text(Localization.of(context)!.translate('pick_photo_title')!),
        subtitle: Text(
            Localization.of(context)!.translate('pick_photo_description')!),
        isThreeLine: true,
        leading: Icon(Icons.photo),
        onTap: () async {
          final photo = await _imagePicker.pickImage(
            source: ImageSource.gallery,
          );

          if (photo != null && !await _handleImageFile(photo.path)) {
            CommonDialogs.showSnackbar(
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
