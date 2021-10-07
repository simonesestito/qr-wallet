import 'package:flutter/material.dart';

class ButtonRoundMini extends StatelessWidget {
  final VoidCallback action;
  final IconData icon;
  final String label;

  ButtonRoundMini({
    required this.action,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          width: 42,
          height: 42,
          decoration: new BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          // Material is necessary to show the ripple effect, for some reason
          child: Material(
            borderRadius: BorderRadius.circular(32),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 24,
              ),
              padding: const EdgeInsets.all(0),
              onPressed: action,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 8),
          width: 96,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
        ),
      ],
    );
  }
}
