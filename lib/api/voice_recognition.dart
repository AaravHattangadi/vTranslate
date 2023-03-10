import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vtranslate/helper/currentLang.dart';

class SpeechAPI {
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording({
    required Function(String text) onResult,
    required String langCode,
  }) async {
    final isAvailable = await _speech.initialize();

    if (isAvailable) {
      print("isAvailable=true");
      _speech.listen(
          onResult: (value) {
            // print(value);
            onResult(value.recognizedWords);
          },
          localeId: langCode);
    } else {
      print("isAvailable=false");
    }

    return isAvailable;
  }
}
