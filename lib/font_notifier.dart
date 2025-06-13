import 'package:flutter/material.dart';

final fontNotifier = ValueNotifier<String>('Cafe24Ssurround');

extension FontChanger on ValueNotifier<String> {
  void changeFont(String newFont) {
    value = newFont;
  }
}
