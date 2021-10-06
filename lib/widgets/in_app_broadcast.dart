import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class InAppBroadcast extends InheritedWidget {
  final Map<InAppEvent, List<Runnable>> _inAppListeners = Map.fromEntries(
    InAppEvent.values.map((e) => MapEntry(e, List.empty(growable: true))),
  );
  static final _inAppDataKey = GlobalKey<_InAppBroadcastDataState>();

  InAppBroadcast({
    required WidgetBuilder child,
  }) : super(child: _InAppBroadcastData(child: child));

  void emitEventType(InAppEvent type) {
    _inAppListeners[type]!.forEach((callback) => callback());
  }

  Runnable listenForEvent(InAppEvent type, Runnable runnable) {
    _inAppListeners[type]!.add(runnable);
    return () => _inAppListeners[type]!.remove(runnable);
  }

  Future<List<ProductDetails>> get productDetails =>
      _inAppDataKey.currentState!.productDetails!;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static InAppBroadcast of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InAppBroadcast>()!;
}

enum InAppEvent {
  ERROR,
  SUCCESS,
}

typedef Runnable = void Function();

class _InAppBroadcastData extends StatefulWidget {
  final WidgetBuilder child;

  const _InAppBroadcastData({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _InAppBroadcastDataState createState() => _InAppBroadcastDataState();
}

class _InAppBroadcastDataState extends State<_InAppBroadcastData> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<List<ProductDetails>>? productDetails;

  @override
  void initState() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }
    InAppPurchase.instance.restorePurchases();

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print(error),
    );
    productDetails = _productDetails();
    super.initState();
  }

  Future<List<ProductDetails>> _productDetails() async {
    final details = await InAppPurchase.instance.queryProductDetails({
      '', // TODO: Add in-app product SKUs
    });
    return details.productDetails;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child(context);

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.error) {
        print(purchaseDetails.error);
        InAppBroadcast.of(context).emitEventType(InAppEvent.ERROR);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (await _verifyPurchase(purchaseDetails)) {
          print(purchaseDetails.productID);
          InAppBroadcast.of(context).emitEventType(InAppEvent.SUCCESS);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
      // TODO: Find already purchased items, maybe it's from this list?
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return true; // TODO: Validate in-app purchase
  }
}
