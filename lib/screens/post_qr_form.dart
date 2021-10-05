import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/models/data.dart';
import 'package:greenpass/utils/globals.dart';
import 'package:greenpass/widgets/button_wide.dart';
import 'package:greenpass/widgets/title_headline.dart';
import 'package:provider/src/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PostQrForm extends StatefulWidget {
  final String qrData;

  PostQrForm({required this.qrData, Key? key}) : super(key: key);

  @override
  State<PostQrForm> createState() => _PostQrFormState();
}

class _PostQrFormState extends State<PostQrForm> {
  var _validate = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                    child: QrImage(data: widget.qrData),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value != null && value.isEmpty)
                      return Localization.of(context)!.translate('name_error');
                    else
                      return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: InputDecoration(
                    errorText: !_validate
                        ? Localization.of(context)!.translate('name_error')
                        : null,
                    errorStyle: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Theme.of(context).colorScheme.error),
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    labelText: Localization.of(context)!.translate('name')!,
                    labelStyle: TextStyle(
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(.6),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                      borderSide: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                      borderSide: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: Globals.borderWidth,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: Globals.borderWidth,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: Globals.borderWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: const SizedBox(height: 16),
                fit: FlexFit.loose,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ButtonWide(
                  text: Localization.of(context)!.translate('save')!,
                  action: () async {
                    setState(() {
                      _controller.text.isNotEmpty
                          ? _validate = true
                          : _validate = false;
                    });
                    if (_validate) {
                      await context.read<GreenPassListData>().addData(
                            GreenPass(
                              alias: _controller.value.text,
                              qrData: this.widget.qrData,
                            ),
                          );
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    }
                  },
                  icon: Icons.save_outlined,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
