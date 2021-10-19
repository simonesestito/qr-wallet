import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/utils/globals.dart';

// The top header of each screen. It supports a back button and an action button, just like the appbar
class TitleHeadline extends StatelessWidget {
  final String title;
  final bool backBtn;
  final IconData? backBtnCustomIcon;
  final VoidCallback? backBtnCustomAction;
  final bool backBtnBadge;
  final bool trailingBtnBadge;
  final IconData? trailingBtn;
  final VoidCallback? trailingBtnAction;

  TitleHeadline({
    required this.title,
    this.backBtn = false,
    this.backBtnCustomIcon,
    this.backBtnCustomAction,
    this.backBtnBadge = false,
    this.trailingBtnBadge = false,
    this.trailingBtn,
    this.trailingBtnAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
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
            // Fitted box resizes the text on overflow, useful for small screens
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
                  ? Stack(
                      children: [
                        IconButton(
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
                        ),
                        backBtnBadge
                            ? Container(
                                width: 52,
                                height: double.infinity,
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: Globals.badgeSize,
                                  height: Globals.badgeSize,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )
                  : Container(),
              // Makes the row match the height of the title, avoid misaligns
              Expanded(
                child: Container(),
              ),
              trailingBtn != null
                  ? Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            trailingBtn,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: trailingBtnAction,
                        ),
                        trailingBtnBadge
                            ? Container(
                                width: 52,
                                height: double.infinity,
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: Globals.badgeSize,
                                  height: Globals.badgeSize,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
