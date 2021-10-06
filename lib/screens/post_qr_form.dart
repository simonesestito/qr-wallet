import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';
import 'package:qrwallet/utils/utils.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';
import 'package:qrwallet/widgets/green_pass_card.dart';
import 'package:qrwallet/widgets/pass_form.dart';
import 'package:qrwallet/widgets/title_headline.dart';

///
/// The screen shown after a new QR has been scanned successfully.
///
class PostQrForm extends StatefulWidget {
  final String qrData;

  PostQrForm({required this.qrData, Key? key}) : super(key: key);

  @override
  State<PostQrForm> createState() => _PostQrFormState();
}

class _PostQrFormState extends State<PostQrForm> {
  @override
  Widget build(BuildContext context) {
    final duplicatePass = context
        .read<GreenPassListData>()
        .passes
        .firstWhereOrNull((pass) => pass.qrData == widget.qrData);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TitleHeadline(
                title: Localization.of(context)!.translate('qr_found')!,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 96,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Globals.borderRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.1),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: Globals.borderWidth * 2,
                      ),
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: QrBackgroundImage(widget.qrData),
                  ),
                ),
              ),
              duplicatePass == null
                  ? buildAddQrForm(context)
                  : buildDuplicateQrMessage(context, duplicatePass),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDuplicateQrMessage(BuildContext context, GreenPass pass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(Globals.buttonPadding),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
              color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(
                Localization.of(context)!.translate("pass_duplicate_message")!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(pass.alias),
            ]),
          ),
        ),
        ButtonWideOutlined(
          action: () => Navigator.popUntil(
            context,
            (route) => route.isFirst,
          ),
          text: Localization.of(context)!.translate("cancel_action")!,
        ),
      ],
    );
  }

  Widget buildAddQrForm(BuildContext context) {
    final qrData = GreenPassDecoder().tryDecode(widget.qrData);
    return PassForm(
        inputData: PassFormData(
          name: qrData?.displayDescription ?? '',
        ),
        onSave: (data) async {
          await context.read<GreenPassListData>().addData(
                GreenPass(
                  alias: data.name,
                  qrData: this.widget.qrData,
                ),
              );
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        });
  }
}
