import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass/lang/localization.dart';
import 'package:greenpass/utils/globals.dart';

import 'button_wide.dart';

///
/// The single form elements when adding a new QR or editing an existing one.
///
class PassForm extends StatelessWidget {
  final PassFormOnSave onSave;
  final PassFormData? inputData;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PassForm({
    required this.onSave,
    this.inputData,
    Key? key,
  }) : super(key: key) {
    _nameController.text = inputData?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
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
                if (_formKey.currentState?.validate() == true) {
                  onSave(PassFormData(name: _nameController.text));
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

typedef PassFormOnSave = Future<void> Function(PassFormData);

class PassFormData {
  final String name;

  PassFormData({required this.name});
}
