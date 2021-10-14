import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/models/free_purchases_status.dart';
import 'package:qrwallet/widgets/in_app_broadcast.dart';

abstract class AdLoader<T extends AdWithoutView> {
  final String unitId;
  T? _loadedAd;
  bool _isLoading = false;

  AdLoader(this.unitId);

  void loadAd(BuildContext context) {
    if (_loadedAd != null || _isLoading) return;

    if (context.read<PremiumStatus>() == PremiumStatus.PREMIUM)
      return; // With UNKNOWN, still load ad

    _isLoading = true;
    _loadAdUnit((ad) {
      _isLoading = false;
      _loadedAd = ad;
    }, (error) {
      print('Ad failed to load: $error');
      _isLoading = false;
    });
  }

  Future<bool> showAdIfAvailable(BuildContext context) {
    if (_loadedAd == null ||
        context.read<PremiumStatus>() != PremiumStatus.BASIC) {
      // If PremiumStatus is UNKNOWN, don't show ad
      return Future.value(false);
    }

    final adCompleter = Completer<bool>();
    _showAd(() {
      _loadedAd?.dispose();
      _loadedAd = null;
      adCompleter.complete(true);
    }, context);
    return adCompleter.future;
  }

  void _showAd(void Function() onComplete, BuildContext context);

  void _loadAdUnit(void Function(T) onSuccess, void Function(AdError) onError);
}

class InterstitialAdLoader extends AdLoader<InterstitialAd> {
  static final InterstitialAdLoader instance = InterstitialAdLoader._();

  InterstitialAdLoader._() : super('ca-app-pub-3883344461454437/6606121084');

  @override
  void _loadAdUnit(void Function(InterstitialAd ad) onSuccess,
      void Function(AdError err) onError) {
    InterstitialAd.load(
      adUnitId: unitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onSuccess,
        onAdFailedToLoad: onError,
      ),
    );
  }

  @override
  void _showAd(void Function() onComplete, BuildContext context) {
    _loadedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => onComplete(),
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        onComplete();
      },
    );
    _loadedAd?.show();
  }
}

class RewardedAdLoader extends AdLoader<RewardedAd> {
  static final RewardedAdLoader instance = RewardedAdLoader._();

  RewardedAdLoader._() : super('ca-app-pub-3883344461454437/7228011576');

  @override
  void _loadAdUnit(void Function(RewardedAd ad) onSuccess,
      void Function(AdError err) onError) {
    RewardedAd.load(
      adUnitId: unitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          onSuccess(ad);
        },
        onAdFailedToLoad: (err) {
          onError(err);
        },
      ),
    );
  }

  @override
  void _showAd(void Function() onComplete, BuildContext context) {
    RewardItem? reward;
    _loadedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) async {
        if (reward != null) {
          await FreePurchasesStatus.instance.addFreePurchase(
            reward!.type,
            Duration(days: reward!.amount.toInt()),
          );
          InAppBroadcast.of(context).emitEventType(InAppEvent.SUCCESS);
          await InAppBroadcast.of(context).refreshStatus();
        }
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        onComplete();
      },
    );
    _loadedAd?.show(
      onUserEarnedReward: (RewardedAd ad, RewardItem earnedReward) async {
        reward = earnedReward;
      },
    );
  }
}
