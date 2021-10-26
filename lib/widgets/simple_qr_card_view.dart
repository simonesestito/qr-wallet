import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/screens/full_screen_qr_screen.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/qr_edit_form.dart';

import 'delete_qr.dart';
import 'qr_background_image.dart';

abstract class QrCardView<T extends SimpleQr> extends StatelessWidget {
  final T qr;

  const QrCardView({
    required this.qr,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.none,
      margin: const EdgeInsets.only(
        bottom: 8,
        right: 8,
        left: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        side: BorderSide(width: Globals.borderWidth, color: Color(0xffaaaaaa)),
      ),
      elevation: 4,
      child: SimpleQrView(qr: qr),
    );
  }

  Widget buildInnerView(BuildContext context, T qr);
}

class SimpleQrCardView extends QrCardView<SimpleQr> {
  SimpleQrCardView({
    required SimpleQr qr,
    Key? key,
  }) : super(key: key, qr: qr);

  @override
  Widget buildInnerView(BuildContext context, SimpleQr qr) {
    return SimpleQrView(qr: qr, qrPadding: const EdgeInsets.all(16));
  }
}

class SimpleQrView extends StatelessWidget {
  final SimpleQr qr;
  final EdgeInsetsGeometry qrPadding;

  const SimpleQrView({
    required this.qr,
    this.qrPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FullScreenQR(qr: qr)),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: qrPadding,
            child: Text(
              qr.alias,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: qrPadding,
            child: Hero(
              tag: qr.qrData,
              child: QrBackgroundImage(qr.qrData, qr.format),
            ),
          ),
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).primaryColor.withOpacity(0.2)),
                ),
                onPressed: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => DeleteQr(qr: qr),
                  );
                },
                icon: Icon(Icons.delete),
                label: Text(Localization.of(context)!
                    .translate(
                      "qr_item_delete",
                    )!
                    .toUpperCase()),
              ),
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).primaryColor.withOpacity(0.2)),
                ),
                onPressed: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => QrEditForm(qr: qr),
                  );
                },
                icon: Icon(Icons.edit),
                label: Text(Localization.of(context)!
                    .translate(
                      "qr_item_rename",
                    )!
                    .toUpperCase()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
