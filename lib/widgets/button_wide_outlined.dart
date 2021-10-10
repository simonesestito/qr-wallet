import 'package:flutter/material.dart';
import 'package:qrwallet/utils/globals.dart';

class ButtonWideOutlined extends StatelessWidget {
  final VoidCallback action;
  final String text;
  final IconData? icon;
  final double padding;

  ButtonWideOutlined({
    required this.action,
    required this.text,
    this.icon,
    this.padding = Globals.buttonPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Padding(
        padding: EdgeInsets.only(
          left: padding,
          right: padding,
          top: 6,
          bottom: 6,
        ),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
                width: Globals.borderWidth, color: Color(0xffaaaaaa)),
            primary: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
            ),
            minimumSize: Size(96, 44),
          ),
          onPressed: action,
          child: icon == null
              ? Text(
                  text.toUpperCase(),
                  style: Theme.of(context).textTheme.button?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      text.toUpperCase(),
                      style: Theme.of(context).textTheme.button?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
