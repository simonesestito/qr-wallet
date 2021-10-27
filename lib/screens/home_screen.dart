import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/green_pass.dart';
import 'package:qrwallet/models/simple_code.dart';
import 'package:qrwallet/providers/data.dart';
import 'package:qrwallet/utils/custom_icons.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/ad_loader.dart';
import 'package:qrwallet/widgets/green_pass_qr_card_view.dart';
import 'package:qrwallet/widgets/in_app_broadcast.dart';
import 'package:qrwallet/widgets/remove_ads.dart';
import 'package:qrwallet/widgets/simple_qr_card_view.dart';
import 'package:qrwallet/widgets/title_headline.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/new_qr.dart';

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
  var _showReviewBadge = false;
  SharedPreferences? sp;
  StreamSubscription? _fileSharingStreamSubscription;
  var _firstLaunch = true;

  // Settings related variables
  var enlargeCentral = false;
  var verticalOrientation = false;
  var singleAsCard = false;
  var autoMaxBrightness = true;
  var infiniteScroll = false;

  @override
  void initState() {
    Screen.brightness.then((brightness) {
      _originalBrightness = brightness;
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _disposeInAppSubscription = InAppBroadcast.of(context).listenAll((event) {
        StandardDialogs.showSnackbar(
          context,
          Localization.of(context)!.translate(event.translationKey)!,
        );
      });

      _fileSharingStreamSubscription =
          ReceiveSharingIntent.getMediaStream().listen(_handleFileSharing);
      ReceiveSharingIntent.getInitialMedia().then(_handleFileSharing);
    });

    super.initState();
  }

  void _handleFileSharing(List<SharedMediaFile> sharedFiles) async {
    if (sharedFiles.isEmpty) return;

    final file = sharedFiles.first.path;
    print('>>>> SHARED FILE: $file');
    showAppModalBottomSheet(
      context: context,
      builder: () => NewQR(
        selectedFilePath: file,
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    sp = await SharedPreferences.getInstance();

    // Fetch settings values
    fetchSettingsValues();

    // Update the count or show the review dialog
    var timesOpened = sp!.getInt('times_opened') ?? 0;
    var firstLaunchTime = sp!.getInt('first_launch_time') ?? 0;
    var dontShowAgain = sp!.getBool('dont_show_again') ?? false;
    if (!dontShowAgain &&
        timesOpened >= Globals.launchesToReview &&
        DateTime.now().millisecondsSinceEpoch >=
            firstLaunchTime + Globals.daysBeforeReview * 24 * 60 * 60 * 1000) {
      // Conditions fullfilled
      setState(() {
        _showReviewBadge = true;
      });
    } else {
      sp!.setInt('times_opened', timesOpened + 1);
      if (firstLaunchTime == 0)
        sp!.setInt('first_launch_time', DateTime.now().millisecondsSinceEpoch);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userStatus = context.watch<PremiumStatus>();
    final passList = context.watch<QrListData>().passes;

    // Max brightness only if enabled from settings
    final _maxBright = _maxBrightClicked ??
        ((!_firstLaunch && passList.isNotEmpty) ||
            (_firstLaunch && passList.isNotEmpty && autoMaxBrightness));
    if (_maxBright) {
      _firstLaunch = false;
      Screen.setBrightness(1);
    } else if (_originalBrightness != null)
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
              backBtnBadge: _showReviewBadge,
              backBtn: true,
              backBtnCustomIcon: Icons.settings_outlined,
              backBtnCustomAction: () async {
                Navigator.of(context).pushNamed(
                  '/settings',
                  arguments: {'showReviewSheet': _showReviewBadge},
                ).then((value) {
                  // The screen returns true if a setting has changed
                  if (value != null && value == true) {
                    // TODO Unefficient, only fetch or return changed values
                    setState(() {
                      fetchSettingsValues();
                    });
                  }
                });
                // The rate dialog is displayed a single time, no matter what
                sp!.setBool('dont_show_again', true);
                setState(() {
                  _showReviewBadge = false;
                });
              },
            ),
            _buildAdBanner(userStatus),
            Expanded(
              child: Container(
                padding: verticalOrientation
                    ? const EdgeInsets.symmetric(horizontal: 18)
                    : const EdgeInsets.only(bottom: 18),
                child: passList.isEmpty
                    ? buildEmptyView(context)
                    : passList.length == 1
                        ? buildSingleQR(passList.first)
                        : buildList(passList),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          userStatus == PremiumStatus.BASIC
              ? FloatingActionButton(
                  child: Icon(
                    CustomIcons.ads_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  heroTag: 'no_ads_fab',
                  mini: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Globals.borderRadius / 1.5),
                  ),
                  onPressed: () async {
                    showAppModalBottomSheet(
                        context: context,
                        builder: () {
                          return RemoveAdsBottomSheet();
                        });
                  })
              : const SizedBox(),
          userStatus == PremiumStatus.BASIC
              ? const SizedBox(height: 8)
              : const SizedBox(),
          FloatingActionButton(
            child: Icon(Icons.qr_code_2_rounded),
            heroTag: 'new_qr_fab',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
            ),
            onPressed: () => showAppModalBottomSheet(
              context: context,
              builder: () => NewQR(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner(PremiumStatus userStatus) {
    if (userStatus == PremiumStatus.BASIC) {
      return Container(
        alignment: Alignment.topCenter,
        child: AdWidget(ad: _bannerAd..load()),
        width: _bannerAd.size.width.toDouble(),
        height: _bannerAd.size.height.toDouble(),
      );
    }

    //if (userStatus == PremiumStatus.PREMIUM)
    return SizedBox.shrink();
  }

  // Build the placeholder
  Widget buildEmptyView(BuildContext context) {
    InterstitialAdLoader.instance.loadAd(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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

  // Build an expanded layout for a single item or a card depending on settings
  Widget buildSingleQR(SimpleCode qr) {
    if (singleAsCard)
      return buildCardForType(qr);
    else {
      if (qr is GreenPass) {
        return GreenPassQrView(pass: qr);
      }
      return SimpleQrView(qr: qr);
    }
  }

  // Build the list of passes
  Widget buildList(List<SimpleCode> passList) {
    return LayoutBuilder(builder: (context, constraints) {
      return CarouselSlider.builder(
        key: ValueKey(passList.length == 1),
        // Fix enlarged center page when deleted first pass
        itemCount: passList.length,
        itemBuilder: (context, i, _) => buildCardForType(passList[i]),
        options: CarouselOptions(
          viewportFraction: .9,
          aspectRatio: max(constraints.biggest.aspectRatio, 9 / 14),
          autoPlay: false,
          initialPage: passList.length - 1,
          reverse: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          // TODO Create a fading edge effect on vertical scrolling
          scrollDirection:
              verticalOrientation ? Axis.vertical : Axis.horizontal,
          enlargeCenterPage: enlargeCentral,
          enableInfiniteScroll: infiniteScroll,
          scrollPhysics: BouncingScrollPhysics(),
        ),
      );
    });
  }

  Widget buildCardForType(SimpleCode qr) {
    if (qr is GreenPass) {
      return GreenPassCardView(pass: qr);
    } else {
      return SimpleQrCardView(qr: qr);
    }
  }

  // Fetch the values for the settings
  void fetchSettingsValues() {
    enlargeCentral = sp!.getBool('enlarge_central') ?? false;
    verticalOrientation = sp!.getBool('vertical_orientation') ?? false;
    autoMaxBrightness = sp!.getBool('auto_max_brightness') ?? true;
    infiniteScroll = sp!.getBool('infinite_scroll') ?? false;
    singleAsCard = sp!.getBool('single_as_card') ?? false;
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _disposeInAppSubscription?.call();
    _fileSharingStreamSubscription?.cancel();
    super.dispose();
  }
}
