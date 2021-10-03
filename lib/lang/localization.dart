import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './localization_delegate.dart';

class Localization {
  final Locale locale;

  Localization(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static Localization? of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<Localization> delegate =
      LocalizationDelegate();

  Map<String, String> _localizedStrings = Map();

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString = await rootBundle
        .loadString('assets/languages/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String? translate(String key) {
    return _localizedStrings[key];
  }
}
