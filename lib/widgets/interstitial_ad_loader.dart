import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/widgets/in_app_broadcast.dart';

class InterstitialAdLoader {
  static const unitId = 'ca-app-pub-3883344461454437/6606121084';
  static InterstitialAd? _loadedAd;
  static bool _isLoading = false;

  static void loadAd(BuildContext context) {
    if (_loadedAd != null || _isLoading) return;

    if (context.read<PremiumStatus>() == PremiumStatus.PREMIUM)
      return; // With UNKNOWN, still load ad

    _isLoading = true;
    InterstitialAd.load(
        adUnitId: unitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _isLoading = false;
            _loadedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  static Future<void> showAdIfAvailable(BuildContext context) {
    if (_loadedAd == null ||
        context.read<PremiumStatus>() != PremiumStatus.BASIC) {
      // If PremiumStatus is UNKNOWN, don't show ad
      return Future.value();
    }

    final adCompleter = Completer();
    final postAdCallback = (InterstitialAd ad) {
      ad.dispose();
      _loadedAd = null;
      adCompleter.complete();
    };

    _loadedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: postAdCallback,
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        postAdCallback(ad);
      },
    );
    _loadedAd?.show();

    return adCompleter.future;
  }
}
