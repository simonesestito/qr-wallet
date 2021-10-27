import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/simple_code.dart';
import 'package:qrwallet/providers/data.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/button_wide.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';

import 'bottomsheet_container.dart';
import 'title_headline.dart';

class DeleteQr extends StatelessWidget {
  final SimpleCode qr;

  const DeleteQr({
    required this.qr,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      children: [
        TitleHeadline(
          title: Localization.of(context)!.translate("qr_item_delete")!,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Localization.of(context)!.translate("qr_item_delete_confirmation")!,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            ButtonWideOutlined(
              action: () => Navigator.pop(context),
              padding: 8,
              icon: Icons.cancel_outlined,
              text: Localization.of(context)!.translate('cancel_action')!,
            ),
            ButtonWide(
              action: () async {
                await context.read<QrListData>().deleteQr(qr);
                StandardDialogs.showSnackbar(
                  context,
                  Localization.of(context)!.translate('item_deleted')!,
                );
                Navigator.pop(context);
              },
              padding: 8,
              icon: Icons.delete_outline_rounded,
              text: Localization.of(context)!.translate('qr_item_delete')!,
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
