import 'package:flutter/material.dart';

class TextDoubleWeight extends StatelessWidget {
  final String boldStart;
  final String regularEnd;

  TextDoubleWeight({
    required this.boldStart,
    required this.regularEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 116),
            child: Text(
              boldStart,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              regularEnd,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
