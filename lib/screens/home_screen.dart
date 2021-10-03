import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/models/data.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen/screen.dart';

import 'new_pass_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _maxBright = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.of(context)!.translate('app_title')!),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => !_maxBright
                ? setState(() {
                    _maxBright = true;
                    Screen.setBrightness(1);
                  })
                : () {},
            icon: Icon(
              _maxBright
                  ? Icons.brightness_7_outlined
                  : Icons.brightness_5_outlined,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: Consumer<GreenPassListData>(builder: (context, data, _) {
            if (data.passes.isEmpty) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_qr_placeholder.png',
                      height: 96,
                      alignment: Alignment.center,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .color!
                          .withOpacity(0.4),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      Localization.of(context)!
                          .translate('no_pass_placeholder')!,
                    ),
                  ],
                ),
              );
            } else {
              // Set max brightness if there's at least one pass
              setState(() {
                Screen.setBrightness(1);
              });
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
            }
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code_2_rounded),
        onPressed: () => showModalBottomSheet(
          enableDrag: true,
          elevation: 4,
          context: context,
          builder: (_) => NewPassDialog(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Globals.borderRadius),
              topRight: Radius.circular(Globals.borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
