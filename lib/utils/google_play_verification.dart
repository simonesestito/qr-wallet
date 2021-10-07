import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

abstract class PurchaseVerification<T extends PurchaseDetails> {
  const PurchaseVerification();

  Future<bool> verifyPurchase(T purchase);

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
        .verifyPurchase(purchase)
        .catchError((err) {
      debugPrint(err.toString());
      return false;
    });
  }
}

class GooglePlayVerification
    extends PurchaseVerification<GooglePlayPurchaseDetails> {
  const GooglePlayVerification();

  @override
  Future<bool> verifyPurchase(GooglePlayPurchaseDetails purchase) async {
    final signature = purchase.billingClientPurchase.signature;
    final signatureBytes = convert.base64Decode(signature);

    final inputData = purchase.billingClientPurchase.originalJson;
    final inputBytes = convert.ascii.encode(inputData);

    final publicKey = RSAPublicKey(
      // Extracted with
      // openssl enc -base64 -d -in publickey.base64 -A | openssl rsa -inform DER -pubin -text
      BigInt.parse(
          "B12CD63DDBEA182D64A259F9EF20287C55F8FA4B8CE36774526C2D293ECDC6B7AB900828C4667DCA3B02B69A9BF2E7AB050506840656721D5C10542C54484C79613639E1EB155448D663C11B910B9C48BF5AA720E20F353C294AA877D6108E78448499F018EE8F62AC1C5777B17FB90ABAA09C8F91E0547FC68CCD2F11E61DCBBD83C3F5EE03B15C679D0E7133ECA4FDC78A6A9E57499AE93A27CB5851AD4A5207549E69DAF6CA82DFED631BB397A8159A91E553B5D6EFED32154A2FD2CA09D584F1751C1E468827D2CADB360E415769AD3994CBC661232D0673EC43F533BE49901376417A65CD3FE77E38B7330667EF159EA0D32DC85FB7079AEB0A92CE4EFB",
          radix: 16),
      BigInt.from(0x10001),
    );
    final keyParams = PublicKeyParameter<RSAPublicKey>(publicKey);
    final signer = RSASigner(SHA1Digest(), '06052b0e03021a');
    signer.init(false, keyParams);
    return signer.verifySignature(inputBytes, RSASignature(signatureBytes));
  }

  RSAPublicKey keyFromString(String publicKeyString) {
    final publicKeyDER = convert.base64Decode(publicKeyString);
    final asn1Parser = ASN1Parser(publicKeyDER);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;

    final publicKeyAsn = ASN1Parser(publicKeyBitString.valueBytes!);
    final publicKeySeq = publicKeyAsn.nextObject() as ASN1BitString;
    final modulus = publicKeySeq.elements![0] as ASN1Integer;
    final exponent = publicKeySeq.elements![1] as ASN1Integer;

    return RSAPublicKey(modulus.integer!, exponent.integer!);
  }
}
