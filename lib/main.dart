import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/lang/locales.dart';
import 'package:qrwallet/screens/home_screen.dart';
import 'package:qrwallet/widgets/in_app_broadcast.dart';

import 'lang/localization.dart';
import 'models/data.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  runApp(InAppBroadcast(
    child: (context) => ChangeNotifierProvider(
      create: (_) => QrListData(),
      child: StreamProvider(
        create: (_) => InAppBroadcast.of(context).isUserPremium,
        initialData: PremiumStatus.UNKNOWN,
        child: MyApp(),
      ),
    ),
  ));
}

const APP_NAME = 'QRWallet';

class MyApp extends StatelessWidget {
  final Locale? locale;
  final ThemeMode themeMode;
  final bool showDebugBanner;

  MyApp({
    Key? key,
    this.locale,
    this.themeMode = ThemeMode.system,
    this.showDebugBanner = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: showDebugBanner,
      supportedLocales: LOCALES,
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        Localization.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        return supportedLocales.firstWhere(
          (supportedLocale) =>
              supportedLocale.languageCode == locale?.languageCode ||
              supportedLocale.countryCode == locale?.countryCode,
          orElse: () => supportedLocales.first,
        );
      },
      locale: locale,

      themeMode: themeMode,
      theme: ThemeData(
        highlightColor: Color(0x2fB2753F),
        // Selection color
        splashColor: Color(0x2fB2753F),
        // Ripple color
        primaryColor: Color(0xff1A753F),
        primaryColorDark: Color(0xff2ECB6D),
        // Main colors
        colorScheme: ColorScheme(
          primary: Color(0xff1A753F),
          primaryVariant: Color(0xff0A652F),
          secondary: Color(0xff2ECB6D),
          secondaryVariant: Color(0xff3EDB7D),
          surface: Color(0xffefefef),
          background: Color(0xffffffff),
          error: Color(0xffB2753F),
          onPrimary: Color(0xffeeeeee),
          onSecondary: Color(0xff313131),
          onSurface: Color(0xffdddddd),
          onBackground: Color(0xff333333),
          onError: Color(0xffB2753F),
          brightness: Brightness.light,
        ),
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: Color(0xff1A753F)),
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: TextStyle(
                fontSize: 16,
                color: Color(0xff505050),
              ),
              bodyText2: TextStyle(
                fontSize: 16,
                color: Color(0xff797979),
              ),
              subtitle1: TextStyle(
                color: Color(0xff505050),
                fontSize: 18,
              ),
              subtitle2: TextStyle(
                color: Color(0xff505050),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              headline1: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Color(0xff505050),
              ),
              headline2: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xff797979),
              ),
              headline3: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xff505050),
              ),
              headline4: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xff797979),
              ),
              headline5: TextStyle(
                fontSize: 20,
                color: Color(0xff505050),
                fontWeight: FontWeight.w700,
              ),
              headline6: TextStyle(
                fontSize: 18,
                color: Color(0xff797979),
              ),
              button: TextStyle(
                fontSize: 14,
                color: Color(0xffffffff),
                fontWeight: FontWeight.w700,
              ),
            ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF323232),
        ),
      ),
      darkTheme: ThemeData(
        highlightColor: Color(0x2fB2753F),
        // Selection color
        splashColor: Color(0x2fB2753F),
        // Ripple color
        primaryColor: Color(0xff2ECB6D),
        primaryColorDark: Color(0xff1A753F),
        // Main colors
        colorScheme: ColorScheme(
          primary: Color(0xff3A955F),
          primaryVariant: Color(0xff1A753F),
          secondary: Color(0xff4EEB8D),
          secondaryVariant: Color(0xff5EFB9D),
          surface: Color(0xff414141),
          background: Color(0xff313131),
          error: Color(0xffB2753F),
          onPrimary: Color(0xffeeeeee),
          onSecondary: Color(0xff313131),
          onSurface: Color(0xff919191),
          onBackground: Color(0xffdddddd),
          onError: Color(0xffB2753F),
          brightness: Brightness.dark,
        ),
        backgroundColor: Color(0xff313131),
        scaffoldBackgroundColor: Color(0xff313131),
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: Color(0xff3A955F)),
        textTheme: ThemeData.dark().textTheme.copyWith(
              bodyText1: TextStyle(
                fontSize: 16,
                color: Color(0xffeeeeee),
              ),
              bodyText2: TextStyle(
                fontSize: 16,
                color: Color(0xffeeeeee),
              ),
              subtitle1: TextStyle(
                color: Color(0xffeeeeee),
                fontSize: 18,
              ),
              subtitle2: TextStyle(
                color: Color(0xffeeeeee),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              headline1: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Color(0xffeeeeee),
              ),
              headline2: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xffeeeeee),
              ),
              headline3: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xffeeeeee),
              ),
              headline4: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xffeeeeee),
              ),
              headline5: TextStyle(
                fontSize: 20,
                color: Color(0xffeeeeee),
                fontWeight: FontWeight.w700,
              ),
              headline6: TextStyle(
                fontSize: 18,
                color: Color(0xffeeeeee),
              ),
              button: TextStyle(
                fontSize: 14,
                color: Color(0xffffffff),
                fontWeight: FontWeight.w700,
              ),
            ),
      ),
      // Route of every possible screen
      routes: {
        '/': (ctx) => _decorate(HomeScreen()),
        SettingsScreen.routeName: (ctx) => _decorate(SettingsScreen()),
      },
      initialRoute: '/',
    );
  }

  Widget _decorate(Widget route) {
    return Builder(builder: (context) {
      final systemUiStyle = Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xff313131),
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarDividerColor: Colors.transparent,
            )
          : SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xffffffff),
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        child: route,
        value: systemUiStyle,
      );
    });
  }
}

/*
class ScreenshotInstrument extends StatefulWidget {
  const ScreenshotInstrument({Key? key}) : super(key: key);

  @override
  _ScreenshotInstrumentState createState() => _ScreenshotInstrumentState();
}

class _ScreenshotInstrumentState extends State<ScreenshotInstrument> {
  final demoPass = GreenPass(
    alias: 'Green Pass - John',
    qrData: 'This is a fake QR code, of course\n' * 40,
    greenPassData: GreenPassData(
      name: 'John',
      surname: 'Wick',
      issueDate: '2021-01-01',
      type: GreenPassType.VACCINATION,
    ),
  );
  Locale? locale;
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    UDP.bind(Endpoint.any(port: Port(12345))).then((udp) {
      udp.listen((data) {
        final text = String.fromCharCodes(data.data);
        if (!text.startsWith("qrwallet ")) return;

        final textParts = text.split(" ");
        final locale = Locale(textParts[1]);
        final theme =
            textParts[2] == 'light' ? ThemeMode.light : ThemeMode.dark;
        setState(() {
          this.locale = locale;
          this.themeMode = theme;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<QrListData>().storeData([demoPass]);

    if (locale == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Waiting")),
        ),
      );
    } else {
      return MyApp(
        locale: locale,
        themeMode: themeMode,
        showDebugBanner: false,
      );
    }
  }
}
*/
