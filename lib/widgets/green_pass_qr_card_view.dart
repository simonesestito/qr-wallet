import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/simple_qr_card_view.dart';
import 'package:qrwallet/widgets/text_double_weight.dart';

import 'delete_qr.dart';
import 'qr_background_image.dart';
import 'qr_edit_form.dart';

// Represent a Green Pass, with every possibile information
class GreenPassCardView extends StatelessWidget {
  final GreenPass qr;

  GreenPassCardView({
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
      child: GreenPassQrView(pass: qr),
    );
  }
}

class GreenPassQrView extends StatelessWidget {
  final GreenPass pass;
  final EdgeInsetsGeometry qrPadding;

  const GreenPassQrView({
    required this.pass,
    this.qrPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _passData = GreenPassDecoder().tryDecode(pass.qrData);

    if (_passData == null)
      return SimpleQrView(
        qr: pass,
        key: key,
        qrPadding: qrPadding,
      );
    else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: qrPadding,
            child: Text(
              pass.alias,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: qrPadding,
            child: QrBackgroundImage(pass.qrData),
          ),
          TextDoubleWeight(
            boldStart: Localization.of(context)!.translate('name')! + ':',
            regularEnd: '${_passData.name} ${_passData.surname}',
          ),
          const SizedBox(height: 6),
          TextDoubleWeight(
            boldStart: Localization.of(context)!.translate('issue_date')! + ':',
            regularEnd: '${_passData.issueDate}',
          ),
          const SizedBox(height: 6),
          TextDoubleWeight(
            boldStart: Localization.of(context)!.translate('type')! + ':',
            regularEnd: '${getTypeDescription(_passData.type, context)}',
          ),
          const SizedBox(height: 6),
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => DeleteQr(qr: pass),
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
                onPressed: () {
                  showAppModalBottomSheet(
                    context: context,
                    builder: () => QrEditForm(qr: pass),
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
          const SizedBox(height: 36)
        ],
      );
    }
  }

  // Return the appropriate description
  String getTypeDescription(GreenPassType type, BuildContext context) {
    if (type == GreenPassType.RECOVERY) {
      return Localization.of(context)!.translate('recovery')!;
    } else if (type == GreenPassType.TEST) {
      return Localization.of(context)!.translate('test')!;
    } else if (type == GreenPassType.VACCINATION) {
      return Localization.of(context)!.translate('vaccination')!;
    } else
      return Localization.of(context)!.translate('unknown')!;
  }
}
