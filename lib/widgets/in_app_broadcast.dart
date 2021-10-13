import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:qrwallet/models/free_purchases_status.dart';
import 'package:qrwallet/utils/completable_future.dart';
import 'package:qrwallet/utils/google_play_verification.dart';

///
/// Force ads status on debug builds:
/// - [true]: User is Premium
/// - [false]: User is Basic
/// - [null]: Don't force a status
///
const bool? DEBUG_FORCE_PREMIUM_ADS_STATUS = null;

class InAppBroadcast extends InheritedWidget {
  static const REMOVE_ADS_SKU = 'remove_ads';

  final Map<InAppEvent, List<Runnable>> _inAppListeners = Map.fromEntries(
    InAppEvent.values.map((e) => MapEntry(e, List.empty(growable: true))),
  );
  static final _inAppDataKey = GlobalKey<_InAppBroadcastDataState>();

  InAppBroadcast({
    required WidgetBuilder child,
  }) : super(child: _InAppBroadcastData(child: child, key: _inAppDataKey));

  void emitEventType(InAppEvent type) {
    _inAppListeners[type]!.forEach((callback) => callback());
  }

  Runnable listenForEvent(InAppEvent type, Runnable runnable) {
    _inAppListeners[type]!.add(runnable);
    return () => _inAppListeners[type]!.remove(runnable);
  }

  Runnable listenForEvents(List<InAppEvent> types,
      Callback callback,) {
    final cancelActions = List<Runnable>.empty(growable: true);
    for (InAppEvent type in types) {
      cancelActions.add(listenForEvent(type, () => callback(type)));
    }
    return () => cancelActions.forEach((cancelAction) => cancelAction());
  }

  Runnable listenAll(Callback callback) {
    return listenForEvents(InAppEvent.values, callback);
  }

  Future<List<ProductDetails>> get productDetails =>
      _inAppDataKey.currentState!.productDetails;

  Stream<PremiumStatus> get isUserPremium =>
      _inAppDataKey.currentState!._isUserPremium.stream
          .map((event) => event ? PremiumStatus.PREMIUM : PremiumStatus.BASIC);

  Future<void> refreshStatus() async {
    _inAppDataKey.currentState!._productDetails = null;
    await _inAppDataKey.currentState!.productDetails;
  }

  @override
  bool updateShouldNotify(InAppBroadcast oldWidget) => false;

  static InAppBroadcast of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InAppBroadcast>()!;
}

enum InAppEvent {
  ERROR,
  SUCCESS,
  PENDING,
}

extension InAppEventString on InAppEvent {
  String get translationKey => {
        InAppEvent.SUCCESS: 'in_app_purchase_success',
        InAppEvent.ERROR: 'in_app_purchase_error',
        InAppEvent.PENDING: 'in_app_purchase_pending',
      }[this]!;
}

enum PremiumStatus {
  PREMIUM,
  BASIC,
  UNKNOWN,
}

typedef Runnable = void Function();
typedef Callback = void Function(InAppEvent);

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
  CompletableFuture<List<ProductDetails>>? _productDetails;
  final _isUserPremium = StreamController<bool>();

  Future<List<ProductDetails>> get productDetails {
    if (_productDetails == null ||
        _productDetails?.cachedResult?.isEmpty == true)
      // Reload products when:
      // - has finished loading
      // - last fetched products list is empty
      _productDetails = CompletableFuture(future: _loadProductDetails());

    return _productDetails!.future;
  }

  @override
  void initState() {
    super.initState();
    FreePurchasesStatus.instance
        .getFreePurchaseStatus(InAppBroadcast.REMOVE_ADS_SKU)
        .then((isFreePeriod) {
      if (isFreePeriod) {
        _isUserPremium.add(true);
      }
    });

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print(error),
    );
    InAppPurchase.instance
        .isAvailable()
        .then((value) => value ? productDetails : Future.value());
  }

  Future<List<ProductDetails>> _loadProductDetails() async {
    await InAppPurchase.instance.isAvailable();
    final details = await InAppPurchase.instance.queryProductDetails({
      InAppBroadcast.REMOVE_ADS_SKU,
    });
    await InAppPurchase.instance.restorePurchases();
    return details.productDetails;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child(context);

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
    var eventEmitted = false;

    if (kDebugMode && DEBUG_FORCE_PREMIUM_ADS_STATUS != null) {
      eventEmitted = true;
      _isUserPremium.add(DEBUG_FORCE_PREMIUM_ADS_STATUS!);
    }

    final isFreePeriod = await FreePurchasesStatus.instance
        .getFreePurchaseStatus(InAppBroadcast.REMOVE_ADS_SKU);
    if (isFreePeriod) {
      eventEmitted = true;
      _isUserPremium.add(true);
    }

    for (PurchaseDetails purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        // Error purchase
        print(purchase.error);
        InAppBroadcast.of(context).emitEventType(InAppEvent.ERROR);
      } else if (purchase.status == PurchaseStatus.pending) {
        InAppBroadcast.of(context).emitEventType(InAppEvent.PENDING);
      } else {
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }

        final isValid = await PurchaseVerification.verify(purchase);

        // Handle slow card, expired purchase test case
        if (isValid && purchase is GooglePlayPurchaseDetails) {
          final payload = jsonDecode(
            purchase.billingClientPurchase.originalJson,
          ) as Map<dynamic, dynamic>;
          if (payload['purchaseState'] == 4 &&
              purchase.pendingCompletePurchase) {
            // Slow card failing test case
            // Ignore this purchase.
            continue;
          }
        }

        if (!eventEmitted && isValid) {
          eventEmitted = true;
          _isUserPremium.add(true);
        }

        if (!isValid)
          InAppBroadcast.of(context).emitEventType(InAppEvent.ERROR);

        if (isValid && purchase.pendingCompletePurchase)
          InAppBroadcast.of(context).emitEventType(InAppEvent.SUCCESS);
      }
    }

    if (!eventEmitted) _isUserPremium.add(false);
  }
}
