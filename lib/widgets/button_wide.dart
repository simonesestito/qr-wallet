import 'package:flutter/material.dart';
import 'package:greenpass/utils/globals.dart';

class ButtonWide extends StatelessWidget {
  final VoidCallback action;
  final String text;
  final double padding;
  final bool showLoading;

  ButtonWide({
    required this.action,
    required this.text,
    this.padding = 24.0,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        top: 6,
        bottom: 6,
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
        ),
        onPressed: action,
        minWidth: double.infinity,
        height: 44,
        child: showLoading
            ? Transform.scale(
                scale: 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text.toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
        color: Theme.of(context).colorScheme.secondary,
        disabledColor: Color(0xffcd66ae),
      ),
    );
  }
}
