import 'package:flutter/material.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/widgets/credits_card.dart';
import 'package:greenpass/widgets/title_headline.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TitleHeadline(
              title: Localization.of(context)!.translate('settings')!,
              backBtn: true,
              trailingBtn: Icons.article_outlined,
              trailingBtnAction: () => showLicensePage(context: context),
            ),
            CreditsCard(
              description: Localization.of(context)!.translate('author_back')!,
              url: 'https://simonesestito.com/',
              image: Image.asset('assets/images/author_back.jpg'),
            ),
            CreditsCard(
              description: Localization.of(context)!.translate('author_front')!,
              url: 'https://www.minar.ml',
              image: Image.asset('assets/images/author_front.jpg'),
            ),
          ],
        ),
      ),
    );
  }
}
