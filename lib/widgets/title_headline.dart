import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// The top header of each screen. It supports a back button and an action button, just like the appbar
class TitleHeadline extends StatelessWidget {
  final String title;
  final bool backBtn;
  final IconData? backBtnCustomIcon;
  final VoidCallback? backBtnCustomAction;
  final IconData? trailingBtn;
  final VoidCallback? trailingBtnAction;

  TitleHeadline({
    required this.title,
    this.backBtn = false,
    this.backBtnCustomIcon,
    this.backBtnCustomAction,
    this.trailingBtn,
    this.trailingBtnAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO Check if something is clipped
      height: 48,
      padding: const EdgeInsets.only(
        top: 4,
        left: 8,
        right: 8,
      ),
      child: Stack(
        children: [
          Container(
            // Avoid overlapping between long texts and buttons
            padding: (trailingBtn == null && !backBtn)
                ? const EdgeInsets.symmetric(horizontal: 8)
                : const EdgeInsets.symmetric(horizontal: 42),
            alignment: Alignment.center,
            // Fittedbox resizes the text on overflow, useful for small screens
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          Row(
            children: [
              backBtn
                  ? IconButton(
                      icon: backBtnCustomIcon != null
                          ? Icon(
                              backBtnCustomIcon,
                              color: Theme.of(context).primaryColor,
                            )
                          : Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).primaryColor,
                            ),
                      onPressed: backBtnCustomAction != null
                          ? backBtnCustomAction
                          : () => Navigator.of(context).pop(),
                    )
                  : Container(),
              // Makes the row match the height of the title, avoid misaligns
              Expanded(
                child: Container(),
              ),
              trailingBtn != null
                  ? IconButton(
                      icon: Icon(
                        trailingBtn,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: trailingBtnAction,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
