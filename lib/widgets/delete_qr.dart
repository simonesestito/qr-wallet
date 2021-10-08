import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';

import 'bottomsheet_container.dart';
import 'title_headline.dart';

class DeleteQr extends StatelessWidget {
  final SimpleQr qr;

  const DeleteQr({
    required this.qr,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(children: [
      TitleHeadline(
        title: Localization.of(context)!.translate("qr_item_delete")!,
      ),
      Text(
        Localization.of(context)!.translate("qr_item_delete_confirmation")!,
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(Localization.of(context)!.translate("cancel_action")!),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await context.read<QrListData>().deleteQr(qr);
            StandardDialogs.showSnackbar(
              context,
              Localization.of(context)!.translate('item_deleted')!,
            );
            Navigator.pop(context);
          },
          child: Text(Localization.of(context)!.translate("qr_item_delete")!),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 16),
    ]);
  }
}
