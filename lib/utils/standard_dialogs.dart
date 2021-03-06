import 'package:flutter/material.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/screens/settings_screen.dart';

import 'globals.dart';

class StandardDialogs {
  // Show a dialog to confirm the profile deletion
  static void showGenericErrorDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Attenzione',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        content: Text(
          'Si è verificato un problema di rete o un errore interno del server. Per favore, verifica che il dispositivo sia connesso ad internet e riprova.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        actions: [
          TextButton(
              style: ButtonStyle(
                overlayColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop())
        ],
      ),
    );
  }

  // Show a snackbar with a 5 secs duration
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          side: BorderSide(
              width: Globals.borderWidth,
              color: Theme.of(context).colorScheme.secondary),
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  // Show a dialog to explain how to obtain a QR code to scan
  static void showQrInfoDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
        ),
        title: Text(
          Localization.of(context)!.translate('camera_qr_dialog_title')!,
          style: Theme.of(context).textTheme.headline6,
        ),
        content: Text(
          Localization.of(context)!.translate('camera_qr_dialog_description')!,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        actions: [
          TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Globals.borderRadius),
                  ),
                ),
                overlayColor: MaterialStateProperty.all(
                    Theme.of(context).primaryColor.withOpacity(0.2)),
              ),
              child: Text(
                Localization.of(context)!.translate('ok')!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop())
        ],
      ),
    );
  }

  // Show a dialog to choose the theme
  static Future<ThemeMode> showThemeChoserDialog(
    BuildContext context,
    ThemeMode appTheme,
  ) async {
    var _themeType = appTheme;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) => AlertDialog(
          contentPadding: const EdgeInsets.only(
            bottom: 16,
            top: 16,
            left: 0,
            right: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Globals.borderRadius),
          ),
          title: Text(
            Localization.of(context)!.translate('app_theme_title')!,
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {
                  setState(() {
                    _themeType = ThemeMode.system;
                  });
                },
                minVerticalPadding: 0,
                visualDensity: VisualDensity.compact,
                title: Text(Localization.of(context)!.translate('auto')!),
                leading: Radio<ThemeMode>(
                  fillColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  value: ThemeMode.system,
                  groupValue: _themeType,
                  onChanged: (ThemeMode? value) {
                    if (value != null)
                      setState(() {
                        _themeType = value;
                      });
                  },
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _themeType = ThemeMode.dark;
                  });
                },
                minVerticalPadding: 0,
                visualDensity: VisualDensity.compact,
                title: Text(Localization.of(context)!.translate('dark')!),
                leading: Radio<ThemeMode>(
                  fillColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  value: ThemeMode.dark,
                  groupValue: _themeType,
                  onChanged: (ThemeMode? value) {
                    if (value != null)
                      setState(() {
                        _themeType = value;
                      });
                  },
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _themeType = ThemeMode.light;
                  });
                },
                minVerticalPadding: 0,
                visualDensity: VisualDensity.compact,
                title: Text(Localization.of(context)!.translate('light')!),
                leading: Radio<ThemeMode>(
                  fillColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  value: ThemeMode.light,
                  groupValue: _themeType,
                  onChanged: (ThemeMode? value) {
                    if (value != null)
                      setState(() {
                        _themeType = value;
                      });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Globals.borderRadius),
                  ),
                ),
                overlayColor: MaterialStateProperty.all(
                    Theme.of(context).primaryColor.withOpacity(0.2)),
              ),
              child: Text(
                Localization.of(context)!.translate('ok')!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            )
          ],
        ),
      ),
    );
    return _themeType;
  }
}

///
/// Show a modal bottom sheet with default values for the app.
///
void showAppModalBottomSheet({
  required BuildContext context,
  required Widget Function() builder,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => builder(),
    enableDrag: true,
    isScrollControlled: true,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Globals.borderRadius),
        topRight: Radius.circular(Globals.borderRadius),
      ),
    ),
  );
}
