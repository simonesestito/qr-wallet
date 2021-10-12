import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/src/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/custom_icons.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/widgets/button_wide.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bottomsheet_container.dart';
import 'in_app_broadcast.dart';
import 'title_headline.dart';

class ReviewBuyApp extends StatelessWidget {
  const ReviewBuyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      children: [
        TitleHeadline(
          title:
              Localization.of(context)!.translate('support_developers_title')!,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Localization.of(context)!
                .translate('support_developers_description')!,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            ButtonWideOutlined(
              action: () async {
                final sp = await SharedPreferences.getInstance();
                sp.setBool('dont_show_again', true);
                if (await canLaunch(Globals.appUrl)) {
                  await launch(Globals.appUrl);
                }
                Navigator.pop(context);
              },
              padding: 8,
              icon: Icons.star_border_rounded,
              text: Localization.of(context)!.translate('review')!,
            ),
            context.watch<PremiumStatus>() == PremiumStatus.BASIC
                ? ButtonWide(
                    action: () async {
                      final products =
                          await InAppBroadcast.of(context).productDetails;
                      InAppPurchase.instance.buyNonConsumable(
                        purchaseParam:
                            PurchaseParam(productDetails: products.first),
                      );
                      final sp = await SharedPreferences.getInstance();
                      sp.setBool('dont_show_again', true);
                      Navigator.pop(context);
                    },
                    padding: 8,
                    icon: CustomIcons.ads_off,
                    text: Localization.of(context)!.translate('remove_ads')!,
                  )
                : const SizedBox(),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
