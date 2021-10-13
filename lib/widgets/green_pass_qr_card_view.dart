import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';
import 'package:qrwallet/widgets/expanded_scroll_column.dart';
import 'package:qrwallet/widgets/text_with_icon.dart';

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
      clipBehavior: Clip.none,
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ExpandedScrollColumn(
        children: [
          ..._buildQrHeader(context),
          _buildPassDetails(context),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  List<Widget> _buildQrHeader(BuildContext context) {
    return [
      Text(
        pass.alias,
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      QrBackgroundImage(pass.qrData, pass.format),
    ];
  }

  Widget _buildPassDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWithIcon(
            icon: Icons.person,
            padding: 8,
            text: '${pass.greenPassData.name} ${pass.greenPassData.surname}',
          ),
          const SizedBox(height: 6),
          TextWithIcon(
            icon: Icons.event_available,
            padding: 8,
            text: '${pass.greenPassData.issueDate}',
          ),
          const SizedBox(height: 6),
          TextWithIcon(
            icon: Icons.receipt_long,
            padding: 8,
            text: Localization.of(context)!.translate(
              pass.greenPassData.type.translationKey,
            )!,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
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
