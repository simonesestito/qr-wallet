import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/credits_card.dart';
import 'package:qrwallet/widgets/review_buy_app.dart';
import 'package:qrwallet/widgets/title_headline.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { auto, light, dark }
enum FilterType { alphabetic, date, type }

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences? sp;
  var enlargeCentral = false;
  var verticalOrientation = false;
  var singleAsCard = false;
  var autoMaxBrightness = true;
  var infiniteScroll = false;
  var codesOrder = 0; //TODO Use enum
  //var appLock = false;
  var appTheme = 0; // TODO Use enum

  @override
  void didChangeDependencies() async {
    sp = await SharedPreferences.getInstance();
    super.didChangeDependencies();
  }

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
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.zoom_out_map_rounded,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Globals.borderRadius),
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            switchValue: enlargeCentral,
                            onToggle: (bool value) {
                              setState(() {
                                enlargeCentral = value;
                              });
                              sp!.setBool('enlarge_central', enlargeCentral);
                            },
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('vertical_orientation_title')!,
                            subtitle: Localization.of(context)!
                                .translate('vertical_orientation_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.vertical_align_bottom_rounded,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Globals.borderRadius),
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            switchValue: verticalOrientation,
                            onToggle: (bool value) {
                              setState(() {
                                verticalOrientation = value;
                              });
                              sp!.setBool(
                                  'vertical_orientation', verticalOrientation);
                            },
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('single_item_as_card_title')!,
                            subtitle: Localization.of(context)!
                                .translate('single_item_as_card_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.featured_play_list_rounded,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Globals.borderRadius),
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            switchValue: singleAsCard,
                            onToggle: (bool value) {
                              setState(() {
                                singleAsCard = value;
                              });
                              sp!.setBool('single_as_card', singleAsCard);
                            },
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('auto_max_brightness_title')!,
                            subtitle: Localization.of(context)!
                                .translate('auto_max_brightness_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.brightness_7_outlined,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Globals.borderRadius),
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            switchValue: autoMaxBrightness,
                            onToggle: (bool value) {
                              setState(() {
                                autoMaxBrightness = value;
                              });
                              sp!.setBool(
                                  'auto_max_brightness', autoMaxBrightness);
                            },
                          ),
                          SettingsTile.switchTile(
                            title: Localization.of(context)!
                                .translate('infinite_scroll_title')!,
                            subtitle: Localization.of(context)!
                                .translate('infinite_scroll_subtitle')!,
                            subtitleMaxLines: 4,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.compare_arrows_rounded,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Globals.borderRadius),
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            switchValue: infiniteScroll,
                            onToggle: (bool value) {
                              setState(() {
                                infiniteScroll = value;
                              });
                              sp!.setBool('infinite_scroll', infiniteScroll);
                            },
                          ),
                          // SettingsTile(
                          //   title: Localization.of(context)!
                          //       .translate('codes_order_title')!,
                          //   subtitle: Localization.of(context)!
                          //       .translate('codes_order_subtitle')!,
                          //   subtitleMaxLines: 4,
                          //   leading: Container(
                          //     padding: const EdgeInsets.all(8),
                          //     child: Icon(
                          //       Icons.sort_rounded,
                          //       color: Colors.white,
                          //     ),
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(
                          //             Globals.borderRadius),
                          //         color: Theme.of(context).colorScheme.error),
                          //   ),
                          //   onPressed: (BuildContext context) {
                          //     // TODO Open a dialog to choose between date and other criteria
                          //   },
                          // ),
                          // SettingsTile.switchTile(
                          //   title: Localization.of(context)!
                          //       .translate('app_lock_title')!,
                          //   subtitle: Localization.of(context)!
                          //       .translate('app_lock_subtitle')!,
                          //   subtitleMaxLines: 4,
                          //   leading: Container(
                          //     padding: const EdgeInsets.all(8),
                          //     child: Icon(
                          //       Icons.fingerprint_rounded,
                          //       color: Colors.white,
                          //     ),
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(
                          //             Globals.borderRadius),
                          //         color: Theme.of(context).colorScheme.error),
                          //   ),
                          //   switchValue: appLock,
                          //   onToggle: (bool value) {},
                          // ),
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
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.color_lens_rounded,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Globals.borderRadius),
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            onPressed: (BuildContext context) async {
                              final result =
                                  await StandardDialogs.showThemeChoserDialog(
                                      context);
                            },
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
