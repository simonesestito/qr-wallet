import 'dart:async';

import 'package:flutter/material.dart';

import './localization.dart';

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'it'].contains(locale.languageCode);
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
