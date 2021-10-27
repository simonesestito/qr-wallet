import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/green_pass.dart';
import 'package:qrwallet/providers/data.dart';
import 'package:qrwallet/screens/full_screen_qr_screen.dart';
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FullScreenQR(qr: pass)),
        );
      },
      child: Padding(
        padding: qrPadding,
        child: ExpandedScrollColumn(
          children: [
            ..._buildQrHeader(context),
            _buildPassDetails(context),
            _buildActionButtons(context),
          ],
        ),
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
      Hero(
        tag: pass.qrData,
        child: QrBackgroundImage(pass.qrData, pass.format),
      ),
    ];
  }

  Widget _buildPassDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWithIcon(
            icon: Icons.person,
            asChip: true,
            padding: 8,
            text: '${pass.greenPassData.name} ${pass.greenPassData.surname}',
          ),
          const SizedBox(height: 2),
          TextWithIcon(
            icon: Icons.event_available,
            asChip: true,
            padding: 8,
            text: _formatDate(pass.greenPassData.issueDate, context),
          ),
          const SizedBox(height: 2),
          TextWithIcon(
            icon: Icons.receipt_long,
            asChip: true,
            padding: 8,
            text: Localization.of(context)!.translate(
              pass.greenPassData.type.translationKey,
            )!,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final offset = DateTime.now().timeZoneOffset;
    final localDate = date.add(offset);

    final locale = Localizations.localeOf(context).toLanguageTag();
    final day = DateFormat.yMEd(locale).format(localDate);
    if (date.hour == 0 && date.minute == 0 && date.second == 0) {
      return day;
    }

    final hour = DateFormat.Hm(locale).format(localDate);
    return "$day $hour";
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
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
        const SizedBox(width: 4),
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
