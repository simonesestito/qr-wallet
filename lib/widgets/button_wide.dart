import 'package:flutter/material.dart';
import 'package:greenpass/utils/globals.dart';

class ButtonWide extends StatelessWidget {
  final VoidCallback action;
  final String text;
  final IconData? icon;
  final double padding;
  final bool showLoading;

  ButtonWide({
    required this.action,
    required this.text,
    this.icon,
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
            : icon == null
                ? Text(
                    text.toUpperCase(),
                    style: Theme.of(context).textTheme.button,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).textTheme.button!.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        text.toUpperCase(),
                        style: Theme.of(context).textTheme.button,
                      )
                    ],
                  ),
        color: Theme.of(context).colorScheme.primary,
        disabledColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
      ),
    );
  }
}
