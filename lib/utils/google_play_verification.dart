import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseVerification {
  const PurchaseVerification();

  Future<bool> verifyPurchase(String verificationData);

  static PurchaseVerification forSource(String source) {
    switch (source) {
      case 'google_play':
        return const GooglePlayVerification();
      default:
        throw UnimplementedError(
          "No purchase verification available for source: $source",
        );
    }
  }

  static Future<bool> verify(PurchaseDetails purchase) {
    return PurchaseVerification.forSource(purchase.verificationData.source)
        .verifyPurchase(purchase.verificationData.localVerificationData);
  }
}

class GooglePlayVerification extends PurchaseVerification {
  static const publicKey =
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsSzWPdvqGC1koln57yAofFX4+kuM42d0UmwtKT7NxrerkAgoxGZ9yjsCtpqb8uerBQUGhAZWch1cEFQsVEhMeWE2OeHrFVRI1mPBG5ELnEi/Wqcg4g81PClKqHfWEI54RISZ8Bjuj2KsHFd3sX+5CrqgnI+R4FR/xozNLxHmHcu9g8P17gOxXGedDnEz7KT9x4pqnldJmuk6J8tYUa1KUgdUnmna9sqC3+1jG7OXqBWakeVTtdbv7TIVSi/SygnVhPF1HB5GiCfSyts2DkFXaa05lMvGYSMtBnPsQ/UzvkmQE3ZBemXNP+d+OLczBmfvFZ6g0y3IX7cHmusKks5O+wIDAQAB';

  const GooglePlayVerification();

  @override
  Future<bool> verifyPurchase(String verificationData) async {
    print(verificationData);
    return true; // TODO: Verify purchase
  }
}
