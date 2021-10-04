import 'package:flutter/material.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsCard extends StatelessWidget {
  final String description;
  final String url;
  final Image image;
  final Color? rippleColor;

  CreditsCard({
    required this.description,
    required this.url,
    required this.image,
    this.rippleColor,
  });

  // Launch an url inside the browser (use forceWebView: true for in app launch)
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.borderRadius),
      ),
      elevation: 4,
      child: InkWell(
        splashColor:
            rippleColor != null ? Theme.of(context).splashColor : rippleColor,
        highlightColor:
            rippleColor != null ? Theme.of(context).splashColor : rippleColor,
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        onTap: () {
          // Open the required site
          _launchURL(url);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                description,
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              image,
            ],
          ),
        ),
      ),
    );
  }
}
