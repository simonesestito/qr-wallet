import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/models/data.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:greenpass/widgets/green_pass_card.dart';
import 'package:greenpass/widgets/title_headline.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';

import 'new_pass_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _originalBrightness;
  bool? _maxBrightClicked; // Click on the button

  @override
  void initState() {
    Screen.brightness.then((brightness) {
      _originalBrightness = brightness;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final passList = context.watch<GreenPassListData>().passes;
    final _maxBright = _maxBrightClicked ?? passList.isNotEmpty;
    if (_maxBright)
      Screen.setBrightness(1);
    else if (_originalBrightness != null)
      Screen.setBrightness(_originalBrightness);

    if (Theme.of(context).brightness == Brightness.dark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xff313131),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xffffffff),
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TitleHeadline(
              title: Localization.of(context)!.translate('app_title')!,
              trailingBtn: _maxBright
                  ? Icons.brightness_7_outlined
                  : Icons.brightness_5_outlined,
              trailingBtnAction: () => setState(() {
                _maxBrightClicked = !_maxBright;
              }),
              backBtn: true,
              backBtnCustomIcon: Icons.settings_outlined,
              backBtnCustomAction: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 42),
                child: passList.isEmpty
                    ? buildEmptyView(context)
                    : buildList(context, passList),
              ),
            ),
          ],
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

  // Build the placeholder
  Widget buildEmptyView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Image.asset(
          'assets/images/no_qr_placeholder.png',
          height: 96,
          alignment: Alignment.center,
          color: Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.4),
        ),
        const SizedBox(height: 20),
        Text(
          Localization.of(context)!.translate('no_pass_placeholder')!,
        ),
      ],
    );
  }

  // Build the list of passes
  Widget buildList(BuildContext context, List<GreenPass> passList) {
    return CarouselSlider.builder(
      itemCount: passList.length,
      itemBuilder: (context, i, _) => GreenPassCardView(pass: passList[i]),
      options: CarouselOptions(
        autoPlay: false,
        initialPage: passList.length - 1,
        reverse: true,
        viewportFraction: 0.8,
        aspectRatio: 9 / 12,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
      ),
    );
  }
}
