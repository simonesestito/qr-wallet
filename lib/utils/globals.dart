import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:qrwallet/utils/completable_future.dart';

class Globals {
  // Some values (even different in type) to constantly reuse across the app
  static const double borderRadius = 16;
  static const double avatarRadius = 32;
  static const double borderWidth = 2;
  static const double buttonPadding = 24;
  static const double linksIconSize = 24;
  static const double badgeSize = 10;
  static const int maxLinksNumber = 4;
  static const String bannerAdsUnitId =
      'ca-app-pub-3883344461454437/5943921896';
  static const int launchesToReview = 5;
  static const int daysBeforeReview = 3;
  static const String appUrl =
      'https://play.google.com/store/apps/details?id=com.exos.qrwallet';

  // Developers sites
  static const String authorBackGithub = 'https://www.github.com/simonesestito';
  static const String authorBackPlayStore =
      'https://play.google.com/store/apps/dev?id=6582390767433501974';
  static const String authorBackSite = 'https://simonesestito.com/';
  static const String authorFrontGithub = 'https://www.github.com/m-i-n-a-r';
  static const String authorFrontPlayStore =
      'https://play.google.com/store/apps/dev?id=7720251761301594831';
  static const String authorFrontSite = 'https://minar.ml/';
  static const String authorFrontInstagram =
      'https://www.instagram.com/minar.tastic/';

  static CompletableFuture<Directory> cacheDirectory = CompletableFuture(
    future: getTemporaryDirectory(),
  );
}
