import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/providers/theme_provider.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/credits_card.dart';
import 'package:qrwallet/widgets/review_buy_app.dart';
import 'package:qrwallet/widgets/title_headline.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OrderType { alphabetic, date, type }

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
  var codesOrder = OrderType.date;

  //var appLock = false;
  var appTheme = ThemeMode.system;

  @override
  void didChangeDependencies() async {
    sp = await SharedPreferences.getInstance();
    // Retrieve settings values or assign a default value
    enlargeCentral = sp!.getBool('enlarge_central') ?? false;
    verticalOrientation = sp!.getBool('vertical_orientation') ?? false;
    autoMaxBrightness = sp!.getBool('auto_max_brightness') ?? true;
    infiniteScroll = sp!.getBool('infinite_scroll') ?? false;
    singleAsCard = sp!.getBool('single_as_card') ?? false;
    appTheme = ThemeMode.values.firstWhere((element) =>
        (sp!.getString('app_theme') ?? ThemeMode.system.toString()) ==
        element.toString());

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
    return WillPopScope(
      onWillPop: () async {
        // Always return true, TODO Could be optimized
        Navigator.of(context).pop(true);
        return true;
      },
      child: FutureBuilder<PackageInfo>(
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
                      backBtnCustomAction: () {
                        // Always return true, TODO Could be optimized
                        Navigator.of(context).pop(true);
                      },
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
                      shrinkWrap: true,
                      lightTheme: SettingsThemeData(
                        settingsListBackground:
                            Theme.of(context).colorScheme.background,
                      ),
                      darkTheme: SettingsThemeData(
                        settingsListBackground:
                            Theme.of(context).colorScheme.background,
                      ),
                      physics: BouncingScrollPhysics(),
                      sections: [
                        SettingsSection(
                          title: Text(
                            Localization.of(context)!
                                .translate('customization')!,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                          tiles: [
                            SettingsTile.switchTile(
                              title: Text(
                                Localization.of(context)!
                                    .translate('vertical_orientation_title')!,
                              ),
                              description: Text(
                                Localization.of(context)!.translate(
                                    'vertical_orientation_subtitle')!,
                                maxLines: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.vertical_align_bottom_rounded,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Globals.borderRadius),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              initialValue: verticalOrientation,
                              activeSwitchColor:
                                  Theme.of(context).colorScheme.secondary,
                              onToggle: (bool value) {
                                setState(() {
                                  verticalOrientation = value;
                                });
                                sp!.setBool('vertical_orientation',
                                    verticalOrientation);
                              },
                            ),
                            SettingsTile.switchTile(
                              title: Text(
                                Localization.of(context)!
                                    .translate('auto_max_brightness_title')!,
                              ),
                              description: Text(
                                Localization.of(context)!
                                    .translate('auto_max_brightness_subtitle')!,
                                maxLines: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.brightness_7_outlined,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Globals.borderRadius),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              initialValue: autoMaxBrightness,
                              activeSwitchColor:
                                  Theme.of(context).colorScheme.secondary,
                              onToggle: (bool value) {
                                setState(() {
                                  autoMaxBrightness = value;
                                });
                                sp!.setBool(
                                    'auto_max_brightness', autoMaxBrightness);
                              },
                            ),
                            SettingsTile.switchTile(
                              title: Text(
                                Localization.of(context)!
                                    .translate('infinite_scroll_title')!,
                              ),
                              description: Text(
                                Localization.of(context)!
                                    .translate('infinite_scroll_subtitle')!,
                                maxLines: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.compare_arrows_rounded,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Globals.borderRadius),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              initialValue: infiniteScroll,
                              activeSwitchColor:
                                  Theme.of(context).colorScheme.secondary,
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
                            //         color: Theme.of(context).colorScheme.primary),
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
                            //         color: Theme.of(context).colorScheme.primary),
                            //   ),
                            //   switchValue: appLock,
                            //   switchActiveColor: Theme.of(context).colorScheme.secondary,
                            //   onToggle: (bool value) {},
                            // ),
                          ],
                        ),
                        SettingsSection(
                          title: Text(
                            Localization.of(context)!.translate('appearance')!,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                          tiles: [
                            SettingsTile(
                              title: Text(
                                Localization.of(context)!
                                    .translate('app_theme_title')!,
                              ),
                              description: Text(
                                Localization.of(context)!
                                    .translate('app_theme_subtitle')!,
                                maxLines: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.color_lens_rounded,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Globals.borderRadius),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              onPressed: (BuildContext context) async {
                                final result =
                                    await StandardDialogs.showThemeChoserDialog(
                                        context, appTheme);
                                // Refresh app and set theme using the provider
                                appTheme = result;
                                sp!.setString('app_theme', result.toString());
                                await Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).toggleTheme(appTheme);
                              },
                            ),
                            SettingsTile.switchTile(
                              title: Text(
                                Localization.of(context)!
                                    .translate('enlarge_central_title')!,
                              ),
                              description: Text(
                                Localization.of(context)!
                                    .translate('enlarge_central_subtitle')!,
                                maxLines: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.zoom_out_map_rounded,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Globals.borderRadius),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              initialValue: enlargeCentral,
                              activeSwitchColor:
                                  Theme.of(context).colorScheme.secondary,
                              onToggle: (bool value) {
                                setState(() {
                                  enlargeCentral = value;
                                });
                                sp!.setBool('enlarge_central', enlargeCentral);
                              },
                            ),
                            SettingsTile.switchTile(
                              title: Text(Localization.of(context)!
                                  .translate('single_item_as_card_title')!),
                              description: Text(
                                Localization.of(context)!
                                    .translate('single_item_as_card_subtitle')!,
                                maxLines: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.featured_play_list_rounded,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Globals.borderRadius),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              initialValue: singleAsCard,
                              activeSwitchColor:
                                  Theme.of(context).colorScheme.secondary,
                              onToggle: (bool value) {
                                setState(() {
                                  singleAsCard = value;
                                });
                                sp!.setBool('single_as_card', singleAsCard);
                              },
                            ),
                          ],
                        ),
                        SettingsSection(
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    Localization.of(context)!
                                        .translate('credits')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                ),
                              ),
                              CreditsCard(
                                description: Localization.of(context)!
                                    .translate('author_front')!,
                                image: Image.asset(
                                    'assets/images/author_front.jpg'),
                                github: Globals.authorFrontGithub,
                                playStore: Globals.authorFrontPlayStore,
                                site: Globals.authorFrontSite,
                                instagram: Globals.authorFrontInstagram,
                              ),
                              CreditsCard(
                                description: Localization.of(context)!
                                    .translate('author_back')!,
                                image: Image.asset(
                                    'assets/images/author_back.jpg'),
                                github: Globals.authorBackGithub,
                                playStore: Globals.authorBackPlayStore,
                                site: Globals.authorBackSite,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                          tiles: [],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
