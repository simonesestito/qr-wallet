import 'package:flutter/material.dart';
import 'package:greenpass/models/data.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GreenPassCardView extends StatelessWidget {
  final GreenPass pass;

  const GreenPassCardView({
    required this.pass,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            pass.alias,
            style: Theme.of(context).textTheme.headline5,
          ),
          QrImage(data: pass.qrData),
        ],
      ),
    );
  }
}
