import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdLoader {
  static InterstitialAd? _loadedAd;
  static bool _isLoading = false;

  static void loadAd() {
    if (_loadedAd != null || _isLoading) return;

    _isLoading = true;
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        // FIXME: Create real unit
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

  static Future<void> showAdIfAvailable() {
    if (_loadedAd == null) return Future.value();

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
