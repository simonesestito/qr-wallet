import 'dart:ui';

import 'package:admob_consent/admob_consent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qrwallet/screens/home_screen.dart';

import 'lang/localization.dart';
import 'models/data.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ChangeNotifierProvider(
    create: (_) => QrListData(),
    child: MyApp(),
  ));
}

const APP_NAME = 'Green Pass Keeper';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AdmobConsent().show();

    return MaterialApp(
      title: APP_NAME,
      supportedLocales: [
        const Locale('en', 'US'), // Default locale, since it's the first one
        const Locale('it', 'IT'),
      ],
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

      themeMode: ThemeMode.system,
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
          primary: Color(0xff1A753F),
          primaryVariant: Color(0xff0A652F),
          secondary: Color(0xff2ECB6D),
          secondaryVariant: Color(0xff3EDB7D),
          surface: Color(0xff1A753F),
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
        TextSelectionThemeData(cursorColor: Color(0xff1A753F)),
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
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
      },
      home: HomeScreen(),
    );
  }
}

// Check if dark mode is enabled
extension DarkMode on BuildContext {
  bool isDarkMode() {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}
