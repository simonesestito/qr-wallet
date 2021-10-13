import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/credits_card.dart';
import 'package:qrwallet/widgets/review_buy_app.dart';
import 'package:qrwallet/widgets/title_headline.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      // Open the review dialog if specified
      if (arguments != null && arguments['showReviewSheet']) {
        showAppModalBottomSheet(
          context: context,
          builder: () => ReviewBuyApp(),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, data) {
        final appVersion = data.data?.version ?? '';

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                TitleHeadline(
                  title: Localization.of(context)!.translate('settings')!,
                  backBtn: true,
                  trailingBtn: Icons.article_outlined,
                  trailingBtnAction: () => showLicensePage(
                    context: context,
                    applicationName:
                        Localization.of(context)!.translate('app_title')!,
                    applicationVersion: appVersion,
                    applicationIcon: Container(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 128,
                      ),
                    ),
                  ),
                ),
                SettingsList(
                  contentPadding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  lightBackgroundColor:
                      Theme.of(context).colorScheme.background,
                  darkBackgroundColor: Theme.of(context).colorScheme.background,
                  physics: BouncingScrollPhysics(),
                  sections: [
                    SettingsSection(
                      title: Localization.of(context)!.translate('review')!,
                      titleTextStyle: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(
                              color: Theme.of(context).colorScheme.secondary),
                      tiles: [
                        SettingsTile(
                          title: 'Mock 1',
                          subtitle: 'Mock setting, doesn\'t work',
                          leading: Icon(Icons.language),
                          onPressed: (BuildContext context) {},
                        ),
                        SettingsTile.switchTile(
                          title: 'Mock 2',
                          leading: Icon(Icons.fingerprint),
                          switchValue: false,
                          onToggle: (bool value) {},
                        ),
                      ],
                    ),
                  ],
                ),
                CreditsCard(
                  description:
                      Localization.of(context)!.translate('author_back')!,
                  image: Image.asset('assets/images/author_back.jpg'),
                  github: Globals.authorBackGithub,
                  playStore: Globals.authorBackPlayStore,
                  site: Globals.authorBackSite,
                ),
                CreditsCard(
                  description:
                      Localization.of(context)!.translate('author_front')!,
                  image: Image.asset('assets/images/author_front.jpg'),
                  github: Globals.authorFrontGithub,
                  playStore: Globals.authorFrontPlayStore,
                  site: Globals.authorFrontSite,
                  instagram: Globals.authorFrontInstagram,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
