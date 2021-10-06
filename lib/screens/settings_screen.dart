import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/widgets/credits_card.dart';
import 'package:qrwallet/widgets/title_headline.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, data) {
        final appVersion = data.data?.version ?? '';
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
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
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 128,
                          ),
                        ),
                      ),
                    ),
                    CreditsCard(
                      description:
                          Localization.of(context)!.translate('author_back')!,
                      url: 'https://simonesestito.com/',
                      image: Image.asset('assets/images/author_back.jpg'),
                    ),
                    CreditsCard(
                      description:
                          Localization.of(context)!.translate('author_front')!,
                      url: 'https://www.minar.ml',
                      image: Image.asset('assets/images/author_front.jpg'),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
