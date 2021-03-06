import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qrwallet/lang/locales.dart';

import './localization.dart';

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return LOCALES
        .any((appLocale) => appLocale.languageCode == locale.languageCode);
  }

  @override
  Future<Localization> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    Localization localizations = new Localization(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
