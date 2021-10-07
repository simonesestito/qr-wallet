import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/green_pass_qr_card_view.dart';
import 'package:qrwallet/widgets/in_app_broadcast.dart';
import 'package:qrwallet/widgets/simple_qr_card_view.dart';
import 'package:qrwallet/widgets/title_headline.dart';
import 'package:screen/screen.dart';

import 'new_pass_dialog.dart';

class HomeScreen extends StatefulWidget with RouteAware {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerAd = BannerAd(
    adUnitId: Globals.bannerAdsUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  double? _originalBrightness;
  bool? _maxBrightClicked; // Click on the button
  Runnable? _disposeInAppSubscription;

  @override
  void initState() {
    Screen.brightness.then((brightness) {
      _originalBrightness = brightness;
    });
    _bannerAd.load();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _disposeInAppSubscription =
          InAppBroadcast.of(context).listenForEvent(InAppEvent.ERROR, () {
        CommonDialogs.showSnackbar(
          context,
          Localization.of(context)!.translate("in_app_purchase_error")!,
        );
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final passList = context.watch<QrListData>().passes;
    final _maxBright = _maxBrightClicked ?? passList.isNotEmpty;
    if (_maxBright)
      Screen.setBrightness(1);
    else if (_originalBrightness != null)
      Screen.setBrightness(_originalBrightness);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TitleHeadline(
              title: Localization.of(context)!.translate('app_title')!,
              trailingBtn: _maxBright
                  ? Icons.brightness_7_outlined
                  : Icons.brightness_4_outlined,
              trailingBtnAction: () => setState(() {
                _maxBrightClicked = !_maxBright;
              }),
              // TODO Remove this (test only!)
              backBtn: true,
              backBtnCustomIcon: Icons.star,
              backBtnCustomAction: () async {
                final products =
                    await InAppBroadcast.of(context).productDetails;
                InAppPurchase.instance.buyNonConsumable(
                  purchaseParam: PurchaseParam(productDetails: products.first),
                );
              },
              // TODO Re-enable when settings is complete
              //backBtn: true,
              //backBtnCustomIcon: Icons.settings_outlined,
              //backBtnCustomAction: () {
              //  Navigator.of(context).pushNamed('/settings');
              //},
            ),

            // TODO: check if in-app is purchased from InAppBroadcast class
            Container(
              alignment: Alignment.topCenter,
              child: AdWidget(ad: _bannerAd),
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
            ),

            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 30),
                child: passList.isEmpty
                    ? buildEmptyView(context)
                    : passList.length == 1
                        ? buildSingleQR(passList.first)
                        : buildList(context, passList),
              ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Text(
            Localization.of(context)!.translate('no_pass_placeholder')!,
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Build the expanded layout for a single item
  Widget buildSingleQR(SimpleQr qr) {
    final qrView;
    if (qr is GreenPass) {
      qrView = GreenPassQrView(pass: qr);
    } else {
      qrView = SimpleQrView(qr: qr);
    }

    return SingleChildScrollView(child: qrView);
  }

  // Build the list of passes
  Widget buildList(BuildContext context, List<SimpleQr> passList) {
    return CarouselSlider.builder(
      key: ValueKey(passList.length == 1),
      // Fix enlarged center page when deleted first pass
      itemCount: passList.length,
      itemBuilder: (context, i, _) => buildCardForType(passList[i]),
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

  Widget buildCardForType(SimpleQr qr) {
    if (qr is GreenPass) {
      return GreenPassCardView(qr: qr);
    } else {
      return SimpleQrCardView(qr: qr);
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _disposeInAppSubscription?.call();
    super.dispose();
  }
}
