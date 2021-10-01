import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/qr_scan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen/screen.dart';

import 'data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => GreenPassListData(),
    child: MyApp(),
  ));
}

const APP_NAME = 'Green Pass Keeper';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Screen.setBrightness(1);

    return Scaffold(
        appBar: AppBar(title: Text(APP_NAME)),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 96),
            child: Consumer<GreenPassListData>(builder: (context, data, _) {
              if (data.passes.isEmpty) {
                return Center(
                    child: Text(
                  "Premi il + qui sotto per scansionare il tuo pass",
                ));
              }

              return CarouselSlider.builder(
                itemCount: data.passes.length,
                itemBuilder: (context, i, _) => Card(
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        data.passes[i].alias,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      QrImage(data: data.passes[i].qrData),
                    ],
                  ),
                ),
                options: CarouselOptions(
                  autoPlay: false,
                  initialPage: data.passes.length - 1,
                  reverse: true,
                  viewportFraction: 0.8,
                  aspectRatio: 9 / 12,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
              );
            }),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => NewPassDialog(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ));
  }
}

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text("Scatta foto"),
          subtitle: Text("Scatta una nuova foto al pass (es: cartaceo)"),
          leading: Icon(Icons.camera_alt),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => QrScanWidget())),
        ),
        Divider(height: 1),
        ListTile(
          title: Text("Apri foto"),
          subtitle: Text("Scegli una foto dalla galleria (es: screenshot)"),
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
                      "Nessun QR code trovato, assicurati che la foto sia corretta e ben illuminata",
                    ),
                  ),
                );
              }
            }
          },
        ),
        Divider(height: 1),
        ListTile(
          title: Text("Estrai da PDF"),
          subtitle: Text("Usa il documento PDF scaricato"),
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
    );
  }

  Future<void> recoverLostData() async {
    if (!mounted) {
      print(
          "_NewPassDialogState#recoverLostData() called when already unmounted");
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
            "Il PDF selezionato è troppo grande, riprova.",
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
