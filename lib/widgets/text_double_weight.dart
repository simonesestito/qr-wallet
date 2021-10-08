import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  TextWithIcon({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 4),
        Expanded(
            child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        )),
      ],
    );
  }
}
