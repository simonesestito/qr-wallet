import 'package:flutter/material.dart';
import 'package:qrwallet/models/simple_code.dart';
import 'package:qrwallet/providers/data.dart';
import 'package:qrwallet/widgets/qr_background_image.dart';
import 'package:qrwallet/widgets/title_headline.dart';

class FullScreenQR extends StatelessWidget {
  final SimpleCode qr;

  const FullScreenQR({required this.qr, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            children: [
              TitleHeadline(
                backBtn: true,
                backBtnCustomIcon: Icons.arrow_back,
                backBtnCustomAction: () => Navigator.pop(context),
                title: qr.alias,
              ),
              Expanded(
                child: Center(
                  child: Hero(
                    tag: qr.qrData,
                    child: QrBackgroundImage(qr.qrData, qr.format),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
