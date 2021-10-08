import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrwallet/lang/localization.dart';
import 'package:qrwallet/utils/globals.dart';
import 'package:qrwallet/utils/standard_dialogs.dart';

import 'button_wide.dart';

///
/// The single form elements when adding a new QR or editing an existing one.
///
class QrForm extends StatefulWidget {
  final PassFormOnSave onSave;
  final QrFormData? inputData;

  QrForm({
    required this.onSave,
    this.inputData,
    Key? key,
  }) : super(key: key);

  @override
  State<QrForm> createState() => _QrFormState();
}

class _QrFormState extends State<QrForm> {
  final _nameController = TextEditingController();
  final _textKey = ValueKey('name_field');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.inputData?.name ?? '';
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              key: _textKey,
              validator: (value) {
                if (value != null && value.isEmpty)
                  return Localization.of(context)!.translate('name_error');
                else
                  return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              decoration: InputDecoration(
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(.6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Globals.borderRadius),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(.3),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Globals.borderRadius),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(.3),
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
          //Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ButtonWide(
              text: Localization.of(context)!.translate('save')!,
              action: () async {
                if (_formKey.currentState?.validate() == true) {
                  StandardDialogs.showSnackbar(
                    context,
                    Localization.of(context)!.translate('item_saved')!,
                  );
                  widget.onSave(QrFormData(name: _nameController.text));
                }
              },
              icon: Icons.save_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

typedef PassFormOnSave = Future<void> Function(QrFormData);

class QrFormData {
  final String name;

  QrFormData({required this.name});
}
