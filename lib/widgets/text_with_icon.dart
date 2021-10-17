import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/utils/globals.dart';

class TextWithIcon extends StatelessWidget {
  final IconData icon;
  final double? padding;
  final bool asChip;
  final String text;

  TextWithIcon({
    required this.icon,
    this.padding,
    this.asChip = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: !asChip
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(Globals.borderRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.4),
              ),
            ),
      margin: !asChip
          ? null
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: !asChip ? null : EdgeInsets.all(padding != null ? padding! : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: asChip
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onBackground,
          ),
          padding != null ? const SizedBox(width: 4) : SizedBox(width: padding),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: asChip
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onBackground,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
