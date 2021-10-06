import 'package:flutter/material.dart';
import 'package:qrwallet/utils/globals.dart';

class ButtonWideOutlined extends StatelessWidget {
  final VoidCallback action;
  final String text;
  final double padding;

  ButtonWideOutlined({
    required this.action,
    required this.text,
    this.padding = Globals.buttonPadding,
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
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side:
              BorderSide(width: Globals.borderWidth, color: Color(0xffaaaaaa)),
          primary: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Globals.borderRadius),
          ),
          minimumSize: Size(double.infinity, 44),
        ),
        onPressed: action,
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ),
    );
  }
}
