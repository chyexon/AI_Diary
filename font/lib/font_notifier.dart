import 'package:flutter/material.dart';

final fontNotifier = ValueNotifier<String>('Gothic');
final fontSizeNotifier = ValueNotifier<double>(fontSizeDefaults['Gothic'] ?? 14.0);

extension FontChanger on ValueNotifier<String> {
  void changeFont(String newFont) {
    value = newFont;
    fontSizeNotifier.value = fontSizeDefaults[newFont] ?? 14.0;
  }
}

const Map<String, double> fontSizeDefaults = {
  'Gothic': 14.0,
  'Myungjo': 15.0,
  'CookieRun': 13.0,
  'Bazzi': 14.5,
  'Maplestory_Light': 13.5,
  'Highschool': 16.0,
  'BMYEONSUNG': 15.0,
};
