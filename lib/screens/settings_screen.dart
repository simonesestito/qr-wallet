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
            child: SingleChildScrollView(
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    shrinkWrap: true,
                    lightBackgroundColor:
                        Theme.of(context).colorScheme.background,
                    darkBackgroundColor:
                        Theme.of(context).colorScheme.background,
                    physics: BouncingScrollPhysics(),
                    sections: [
                      SettingsSection(
                        titlePadding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          bottom: 12,
                        ),
                        title: Localization.of(context)!
                            .translate('customization')!,
                        titleTextStyle: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary),
                        tiles: [
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('enlarge_central_title')!,
                            subtitle: Localization.of(context)!
                                .translate('enlarge_central_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.zoom_out_map_rounded),
                            switchValue: false,
                            onToggle: (bool value) {},
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('vertical_orientation_title')!,
                            subtitle: Localization.of(context)!
                                .translate('vertical_orientation_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.vertical_align_bottom_rounded),
                            switchValue: false,
                            onToggle: (bool value) {},
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('single_item_as_card_title')!,
                            subtitle: Localization.of(context)!
                                .translate('single_item_as_card_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.featured_play_list_rounded),
                            switchValue: false,
                            onToggle: (bool value) {},
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('auto_max_brightness_title')!,
                            subtitle: Localization.of(context)!
                                .translate('auto_max_brightness_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.brightness_7_outlined),
                            switchValue: false,
                            onToggle: (bool value) {},
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('infinite_scroll_title')!,
                            subtitle: Localization.of(context)!
                                .translate('infinite_scroll_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.compare_arrows_rounded),
                            switchValue: false,
                            onToggle: (bool value) {},
                          ),
                          SettingsTile(
                            title: Localization.of(context)!
                                .translate('codes_order_title')!,
                            subtitle: Localization.of(context)!
                                .translate('codes_order_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.sort_rounded),
                            onPressed: (BuildContext context) {},
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('app_lock_title')!,
                            subtitle: Localization.of(context)!
                                .translate('app_lock_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.fingerprint),
                            switchValue: false,
                            onToggle: (bool value) {},
                          ),
                        ],
                      ),
                      SettingsSection(
                        titlePadding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          bottom: 12,
                        ),
                        title:
                            Localization.of(context)!.translate('appearance')!,
                        titleTextStyle: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary),
                        tiles: [
                          SettingsTile(
                            title: Localization.of(context)!
                                .translate('app_theme_title')!,
                            subtitle: Localization.of(context)!
                                .translate('app_theme_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Icon(Icons.color_lens_rounded),
                            onPressed: (BuildContext context) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
          ),
        );
      },
    );
  }
}
