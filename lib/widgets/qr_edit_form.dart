import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/simple_code.dart';
import 'package:qrwallet/providers/data.dart';
import 'package:qrwallet/widgets/qr_form.dart';

import 'bottomsheet_container.dart';
import 'title_headline.dart';

class QrEditForm extends StatelessWidget {
  final SimpleCode qr;

  const QrEditForm({
    required this.qr,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(children: [
      TitleHeadline(
        title: Localization.of(context)!.translate("qr_item_rename")!,
      ),
      QrForm(
          inputData: QrFormData(name: qr.alias, format: qr.format),
          onSave: (data) async {
            await context
                .read<QrListData>()
                .replaceQr(qr, qr.copyWith(alias: data.name));
            Navigator.pop(context);
          }),
      SizedBox.fromSize(
        size: Size.fromHeight(MediaQuery.of(context).viewInsets.bottom),
      ),
    ]);
  }
}
