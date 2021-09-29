import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/qr_scan.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen/screen.dart';

import 'data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

const APP_NAME = 'Green Pass Keeper';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ChangeNotifierProvider(
        create: (_) => GreenPassListData(),
        child: const Home(),
      ),
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
          child: Consumer<GreenPassListData>(
              builder: (context, data, _) {
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
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => QrScanWidget()));
        },
      ),
    );
  }
}
