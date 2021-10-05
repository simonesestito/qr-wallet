import 'package:flutter/material.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/models/data.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GreenPassCardView extends StatelessWidget {
  final GreenPass pass;

  const GreenPassCardView({
    required this.pass,
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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  pass.alias,
                  style: Theme.of(context).textTheme.headline5,
                ),
                QrImage(data: pass.qrData),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton(itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      // TODO
                    },
                    child: Text(
                      Localization.of(context)!.translate("pass_item_delete")!,
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      // TODO
                    },
                    child: Text(
                      Localization.of(context)!.translate("pass_item_rename")!,
                    ),
                  ),
                ];
              }),
            ),
          ],
        ),
      ),
    );
  }
}
