import 'package:flutter/material.dart';
import 'package:qrwallet/utils/globals.dart';

///
/// Wrap the contents of a BottomSheet applying all the layout it needs
/// (e.g.: clip on top, rounded borders, etc)
///
class BottomSheetContainer extends StatelessWidget {
  final List<Widget> children;

  const BottomSheetContainer({
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Globals.borderRadius),
            child: Container(
              height: 4,
              width: 30,
              color: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .color!
                  .withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
