import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:greenpass/qr_scan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  final _barcodeScanner =
  GoogleMlKit.vision.barcodeScanner([BarcodeFormat.qrCode]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getLostData());
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
              Navigator.pop(context);
              _handleImageFile(photo);
            }
          },
        ),
        Divider(height: 1),
        ListTile(
          title: Text("Estrai da PDF"),
          subtitle: Text("Usa il documento PDF scaricato"),
          leading: Icon(Icons.picture_as_pdf),
          onTap: () {
            // TODO
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Future<void> getLostData() async {
    final LostDataResponse response = await _imagePicker.retrieveLostData();
    if (response.isEmpty) return;

    if (response.files != null) {
      for (final XFile file in response.files ?? []) {
        if (file.mimeType?.startsWith("image/") == true)
          _handleImageFile(file);
        else if (file.name.endsWith(".pdf"))
          _handlePdfFile(file);
        else
          print("Unknown recovered file: ${file.path}");
      }
    } else {
      print(response.exception);
    }
  }

  void _handleImageFile(XFile imageFile) async {
    final result = await _barcodeScanner
        .processImage(InputImage.fromFilePath(imageFile.path));

    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nessun QR code trovato, assicurati che la foto sia corretta e ben illuminata"))
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostQrScanWidget(
            qrData: result.first.value.rawValue!,
          ),
        ),
      );
    }
  }

  void _handlePdfFile(XFile pdfFile) {
    print("PDF: ${pdfFile.path}");
  }
}

