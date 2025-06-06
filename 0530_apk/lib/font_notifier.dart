import 'package:flutter/material.dart';

final fontNotifier = ValueNotifier<String>('Gothic');

extension FontChanger on ValueNotifier<String> {
  void changeFont(String newFont) {
    value = newFont;
  }
}
