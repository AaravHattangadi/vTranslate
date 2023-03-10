// ignore_for_file: file_names, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:vtranslate/api/voice_recognition.dart';
import 'package:vtranslate/components/action-button.dart';
import 'package:vtranslate/components/chooselang.dart';
import 'package:vtranslate/components/translateinput.dart';
import 'package:vtranslate/models/lang.dart';
import 'package:vtranslate/screens/camera-translation.dart';
import 'package:vtranslate/screens/language-pages.dart';
import 'package:vtranslate/helper/currentLang.dart';
import 'package:camera/camera.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var sourceLang = CurrentLanguages.sourceLang.value;
  var outputLang = CurrentLanguages.outputLang.value;
  String recognizedWords = "text";

  @override
  void initState() {
    CurrentLanguages.sourceLang
        .addListener(() => sourceLang = CurrentLanguages.sourceLang.value);

    CurrentLanguages.outputLang
        .addListener(() => outputLang = CurrentLanguages.outputLang.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("vTranslate"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            color: Color.fromARGB(255, 230, 229, 229),
            elevation: 5.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ValueListenableBuilder<Lang>(
                  valueListenable: CurrentLanguages.sourceLang,
                  builder: (context, value, child) {
                    return ChooseLangWidget(
                      language: sourceLang.name,
                      title: "Source Language",
                    );
                  },
                ),
                IconButton(
                    onPressed: () {
                      Lang temp;
                      temp = CurrentLanguages.sourceLang.value;
                      CurrentLanguages.sourceLang.value =
                          CurrentLanguages.outputLang.value;
                      CurrentLanguages.outputLang.value = temp;
                    },
                    icon: Icon(
                      Icons.compare_arrows,
                      color: Colors.blue[600],
                    )),
                ValueListenableBuilder<Lang>(
                  valueListenable: CurrentLanguages.outputLang,
                  builder: (context, value, child) {
                    return ChooseLangWidget(
                      language: outputLang.name,
                      title: "Translation Language",
                    );
                  },
                ),
              ],
            ),
          ),
          TranslateInput(),
          SizedBox(height: 18.0),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ActionButton(
                  icon: Icons.camera_alt_rounded,
                  text: "Camera",
                  onPress: () async {
                    await availableCameras().then((value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                CameraTranslation(cameras: value))));
                  },
                ),
                ActionButton(
                    icon: Icons.mic,
                    text: "Voice",
                    onPress: () =>
                        doesSupportSTT(CurrentLanguages.sourceLang.value)
                            ? toggleRecording()
                            : sttNotTestedErr())
              ],
            ),
          ),
        ],
      ),
    );
  }

  sttNotTestedErr() {
    print("reaching point sttNotTestedErr");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Language has not been tested. You may experience bugs."),
        action: SnackBarAction(
          label: "Ok",
          onPressed: () {},
        ),
      ),
    );
    toggleRecording();
  }

  doesSupportSTT(Lang lang) {
    print("reaching point doesSupportSTT");
    List<String> supportedLangs = ["English", "French", "German", "Hindi"];
    if (supportedLangs.contains(lang.name)) {
      return true;
    } else {
      return false;
    }
  }

  Future? toggleRecording() {
    print("reached point toggleRecording");
    SpeechAPI.toggleRecording(
        langCode: CurrentLanguages.sourceLang.value.code,
        onResult: (text) {
          TranslateInputState.iptTextEditingController.text = text;

          GoogleTranslator()
              .translate('$text ',
                  from: CurrentLanguages.sourceLang.value.code,
                  to: CurrentLanguages.outputLang.value.code)
              .then((value) => setState(
                    () {
                      TranslateInputState.optTextEditingController.text =
                          value.text;
                    },
                  ));
        });
  }
}
