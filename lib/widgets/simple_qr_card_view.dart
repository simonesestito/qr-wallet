import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/bottomsheet_container.dart';
import 'package:qrwallet/widgets/qr_form.dart';
import 'package:qrwallet/widgets/title_headline.dart';

import 'button_round_mini.dart';
import 'delete_qr.dart';
import 'qr_background_image.dart';
import 'qr_edit_form.dart';

class SimpleQrCardView extends StatelessWidget {
  final SimpleQr qr;

  const SimpleQrCardView({
    required this.qr,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        side: BorderSide(width: Globals.borderWidth, color: Color(0xffaaaaaa)),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              qr.alias,
              style: Theme.of(context).textTheme.headline5,
            ),
            QrBackgroundImage(qr.qrData),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ButtonRoundMini(
                action: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => DeleteQr(qr: qr),
                  );
                },
                icon: Icons.delete,
                label: Localization.of(context)!.translate(
                  "qr_item_delete",
                )!,
              ),
              ButtonRoundMini(
                action: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => QrEditForm(qr: qr),
                  );
                },
                icon: Icons.edit,
                label: Localization.of(context)!.translate(
                  "qr_item_rename",
                )!,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
