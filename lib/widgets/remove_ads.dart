import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/custom_icons.dart';
import 'package:qrwallet/widgets/button_wide.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';

import 'ad_loader.dart';
import 'bottomsheet_container.dart';
import 'in_app_broadcast.dart';
import 'title_headline.dart';

class RemoveAdsBottomSheet extends StatelessWidget {
  const RemoveAdsBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      RewardedAdLoader.instance.loadAd(context);
    });

    return BottomSheetContainer(
      children: [
        TitleHeadline(
          title: Localization.of(context)!.translate('remove_ads_title')!,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Localization.of(context)!.translate('remove_ads_description')!,
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
                final success =
                    await RewardedAdLoader.instance.showAdIfAvailable(context);
                if (success) {
                  Navigator.pop(context);
                }
              },
              padding: 8,
              icon: Icons.ondemand_video_rounded,
              text: Localization.of(context)!.translate('reward_ad')!,
            ),
            ButtonWide(
              action: () async {
                final products =
                    await InAppBroadcast.of(context).productDetails;
                await InAppPurchase.instance.buyNonConsumable(
                  purchaseParam: PurchaseParam(productDetails: products.first),
                );
                Navigator.pop(context);
              },
              padding: 8,
              icon: CustomIcons.ads_off,
              text: Localization.of(context)!.translate('remove_ads')!,
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
