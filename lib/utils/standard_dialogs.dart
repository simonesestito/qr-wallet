import 'package:flutter/material.dart';

import 'globals.dart';

class CommonDialogs {
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
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
        ),
      ),
    );
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
