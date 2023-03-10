import 'package:vtranslate/models/lang.dart';
import 'package:flutter/material.dart';

class CurrentLanguages extends ChangeNotifier {
  static ValueNotifier<Lang> sourceLang =
      ValueNotifier<Lang>(Lang('English', 'en', false));
  static ValueNotifier<Lang> outputLang =
      ValueNotifier<Lang>(Lang('French', 'fr', false));

  changeSource(Lang language) {
    sourceLang.value = language;
    notifyListeners();
  }

  changeOutput(Lang language) {
    outputLang.value = language;
    notifyListeners();
  }
}
