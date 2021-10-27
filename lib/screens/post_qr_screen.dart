import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/models/green_pass.dart';
import 'package:qrwallet/models/simple_code.dart';
import 'package:qrwallet/providers/data.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/green_pass_decoder.dart';
import 'package:qrwallet/utils/utils.dart';
import 'package:qrwallet/widgets/button_wide_outlined.dart';
import 'package:qrwallet/widgets/ad_loader.dart';
import 'package:qrwallet/widgets/qr_background_image.dart';
import 'package:qrwallet/widgets/qr_form.dart';
import 'package:qrwallet/widgets/title_headline.dart';

///
/// The screen shown after a new QR has been scanned successfully.
///
class PostQrScreen extends StatefulWidget {
  final String qrData;
  final BarcodeFormat format;

  PostQrScreen({
    required this.qrData,
    required this.format,
    Key? key,
  }) : super(key: key);

  @override
  State<PostQrScreen> createState() => _PostQrScreenState();
}

class _PostQrScreenState extends State<PostQrScreen> {
  @override
  Widget build(BuildContext context) {
    final duplicatePass = context
        .read<QrListData>()
        .passes
        .firstWhereOrNull((pass) => pass.qrData == widget.qrData);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: Globals.borderWidth * 2,
                    ),
                    borderRadius: BorderRadius.circular(Globals.borderRadius),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: QrBackgroundImage(widget.qrData, widget.format),
                ),
              ),
            ),
            ...(duplicatePass == null
                ? [buildAddQrForm(context)]
                : buildDuplicateQrMessage(context, duplicatePass)),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDuplicateQrMessage(BuildContext context, SimpleCode pass) {
    return [
      Padding(
        padding: const EdgeInsets.all(Globals.buttonPadding),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Globals.borderRadius),
            color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text(
              Localization.of(context)!.translate("qr_duplicate_message")!,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(pass.alias),
          ]),
        ),
      ),
      // Put the button at the bottom, but cannot do that with PassForm
      // --> Spacer(),
      ButtonWideOutlined(
        action: () async {
          await InterstitialAdLoader.instance.showAdIfAvailable(context);
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        },
        text: Localization.of(context)!.translate("cancel_action")!,
      ),
    ];
  }

  Widget buildAddQrForm(BuildContext context) {
    final passData = GreenPassDecoder().tryDecode(widget.qrData);
    return QrForm(
        inputData: QrFormData(
          name: passData?.displayDescription ?? '',
          format: widget.format,
        ),
        onSave: (data) async {
          await context.read<QrListData>().addQr(
                passData == null
                    ? SimpleCode(
                        alias: data.name!,
                        qrData: widget.qrData,
                        format: widget.format,
                      )
                    : GreenPass(
                        alias: data.name!,
                        qrData: widget.qrData,
                        greenPassData: passData,
                      ),
              );
          await InterstitialAdLoader.instance.showAdIfAvailable(context);
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        });
  }
}
