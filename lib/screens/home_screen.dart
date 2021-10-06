import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/green_pass_card.dart';
import 'package:qrwallet/widgets/title_headline.dart';
import 'package:screen/screen.dart';

import 'new_pass_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bannerAd = BannerAd(
    adUnitId: Globals.bannerAdsUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  double? _originalBrightness;
  bool? _maxBrightClicked; // Click on the button

  @override
  void initState() {
    Screen.brightness.then((brightness) {
      _originalBrightness = brightness;
    });
    bannerAd.load();
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
        child: ListView(
          children: [
            TitleHeadline(
              title: Localization.of(context)!.translate('app_title')!,
              trailingBtn: _maxBright
                  ? Icons.brightness_7_outlined
                  : Icons.brightness_5_outlined,
              trailingBtnAction: () => setState(() {
                _maxBrightClicked = !_maxBright;
              }),
              // TODO Reenable when settings is complete
              //backBtn: true,
              //backBtnCustomIcon: Icons.settings_outlined,
              //backBtnCustomAction: () {
              //  Navigator.of(context).pushNamed('/settings');
              //},
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
            Container(
              alignment: Alignment.center,
              child: AdWidget(ad: bannerAd),
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code_2_rounded),
        onPressed: () => showAppModalBottomSheet(
          context: context,
          builder: () => NewPassDialog(),
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
      key: ValueKey(passList.length == 1),
      // Fix enlarged center page when deleted first pass
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

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }
}
