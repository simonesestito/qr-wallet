import 'package:flutter/material.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class LaunchUrlWidget extends StatelessWidget {
  final String url;

  const LaunchUrlWidget({required this.url, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: canLaunch(url),
      builder: (context, snap) {
        if (snap.data == true) {
          return buildLaunchWidget(context);
        } else {
          return buildFallbackWidget(context);
        }
      },
    );
  }

  Widget buildLaunchWidget(BuildContext context);

  Widget buildFallbackWidget(BuildContext context) {
    return SizedBox.shrink();
  }
}

class MiniOpenButton extends LaunchUrlWidget {
  const MiniOpenButton({
    required String url,
    Key? key,
  }) : super(url: url, key: key);

  @override
  Widget buildLaunchWidget(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(Globals.buttonPadding),
      icon: Icon(Icons.open_in_new),
      tooltip: Localization.of(context)!.translate("open_link_tooltip")!,
      onPressed: () => launch(url),
    );
  }
}

class WideOpenButton extends LaunchUrlWidget {
  const WideOpenButton({required String url, Key? key})
      : super(url: url, key: key);

  @override
  Widget buildLaunchWidget(BuildContext context) {
    return ButtonWideOutlined(
      action: () => launch(url),
      text: Localization.of(context)!.translate("open_link_tooltip")!,
      icon: Icons.open_in_new,
    );
  }
}
