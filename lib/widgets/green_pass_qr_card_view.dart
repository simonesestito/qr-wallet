import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrwallet/models/data.dart';
import 'package:qrwallet/widgets/simple_qr_card_view.dart';

///
/// At the moment, they are the same
///
class GreenPassCardView extends QrCardView<GreenPass> {
  GreenPassCardView({
    required GreenPass qr,
    Key? key,
  }) : super(key: key, qr: qr);

  @override
  Widget buildInnerView(BuildContext context, GreenPass qr) {
    return GreenPassQrView(pass: qr, qrPadding: const EdgeInsets.all(16));
  }
}

class GreenPassQrView extends SimpleQrView {
  final GreenPass pass;

  const GreenPassQrView({
    required this.pass,
    EdgeInsetsGeometry qrPadding = const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 24,
    ),
    Key? key,
  }) : super(key: key, qr: pass, qrPadding: qrPadding);
}
