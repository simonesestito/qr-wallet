import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/text_double_weight.dart';

import 'delete_qr.dart';
import 'qr_background_image.dart';
import 'qr_edit_form.dart';

// Represent a Green Pass, with every possible information
class GreenPassCardView extends StatelessWidget {
  final GreenPass pass;

  GreenPassCardView({
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
      child: GreenPassQrView(pass: pass),
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
    return Padding(
      padding: qrPadding,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            height: constraints.maxHeight,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._buildQrHeader(context),
                const SizedBox(height: 6),
                _buildPassDetails(context),
                const SizedBox(height: 6),
                _buildActionButtons(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildQrHeader(BuildContext context) {
    return [
      Text(
        pass.alias,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      QrBackgroundImage(pass.qrData),
    ];
  }

  Widget _buildPassDetails(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextWithIcon(
          icon: Icons.person,
          //Localization.of(context)!.translate('name')! + ':',
          text: '${pass.greenPassData.name} ${pass.greenPassData.surname}',
        ),
        const SizedBox(height: 6),
        TextWithIcon(
          icon: Icons.event_available,
          //Localization.of(context)!.translate('issue_date')! + ':',
          text: '${pass.greenPassData.issueDate}',
        ),
        const SizedBox(height: 6),
        TextWithIcon(
          icon: Icons.receipt_long,
          //Localization.of(context)!.translate('type')! + ':',
          text: Localization.of(context)!.translate(
            pass.greenPassData.type.translationKey,
          )!,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
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
    );
  }
}
