import 'package:flutter/material.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/models/data.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:greenpass/utils/green_pass_decoder.dart';
import 'package:greenpass/widgets/green_pass_card.dart';
import 'package:greenpass/widgets/pass_form.dart';
import 'package:greenpass/widgets/title_headline.dart';
import 'package:provider/src/provider.dart';

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
    final qrData = GreenPassDecoder().tryDecode(widget.qrData);
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
              PassForm(
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
                  })
            ],
          ),
        ),
      ),
    );
  }
}
