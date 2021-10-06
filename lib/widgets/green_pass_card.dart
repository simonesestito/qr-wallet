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
import 'package:qrwallet/widgets/pass_form.dart';
import 'package:qrwallet/widgets/title_headline.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              pass.alias,
              style: Theme.of(context).textTheme.headline5,
            ),
            QrBackgroundImage(pass.qrData),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: Localization.of(context)!.translate(
                  "pass_item_delete",
                )!,
                onPressed: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => DeletePass(pass: pass),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: Localization.of(context)!.translate(
                  "pass_item_rename",
                )!,
                onPressed: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => PassEditForm(pass: pass),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class DeletePass extends StatelessWidget {
  final GreenPass pass;

  const DeletePass({
    required this.pass,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(children: [
      TitleHeadline(
          title: Localization.of(context)!.translate("pass_item_delete")!),
      Text(Localization.of(context)!
          .translate("pass_item_delete_confirmation")!),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Annulla"),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await context.read<QrListData>().deleteQr(pass);
            Navigator.pop(context);
          },
          child: Text("Elimina"),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 16),
    ]);
  }
}

class PassEditForm extends StatelessWidget {
  final GreenPass pass;

  const PassEditForm({
    required this.pass,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(children: [
      TitleHeadline(
        title: Localization.of(context)!.translate("pass_item_rename")!,
      ),
      PassForm(
          inputData: PassFormData(name: pass.alias),
          onSave: (data) async {
            await context
                .read<QrListData>()
                .replaceQr(pass, pass.copyWith(alias: data.name));
            Navigator.pop(context);
          }),
      SizedBox.fromSize(
          size: Size.fromHeight(MediaQuery.of(context).viewInsets.bottom)),
    ]);
  }
}

///
/// A QrImage with an adaptive (white) background
///
class QrBackgroundImage extends StatelessWidget {
  final String data;

  const QrBackgroundImage(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = max(
      colorScheme.background.value,
      colorScheme.onBackground.value,
    );

    return QrImage(
      data: data,
      backgroundColor: Color(backgroundColor),
    );
  }
}
