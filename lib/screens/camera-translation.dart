import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:vtranslate/helper/currentLang.dart';
import 'package:image/image.dart' as img;

class CameraTranslation extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraTranslation({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraTranslation> createState() => _CameraTranslationState();
}

class _CameraTranslationState extends State<CameraTranslation> {
  late CameraController _cameraController;
  late final InputImage _inputImage;
  late String result;

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        return setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    initCamera(widget.cameras![0]);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _showPopup(String source, String output) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Translation"),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                Text(
                  "In ${CurrentLanguages.sourceLang.value.name}\n${source}",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
                Text("\n"),
                Text("In ${CurrentLanguages.outputLang.value.name}\n${output}")
              ],
            )),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ok"))
            ],
          );
        });
  }

  Future takeImageToTranslate() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }

    if (_cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      XFile picture = await _cameraController.takePicture();
      imageToText(File(picture.path));
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("An unhandled error occured")));
    }
  }

  Future imageToText(inputImage) async {
    result = '';

    final TextRecognizer _textDetector = TextRecognizer();
    // final XFile = inputImage;
    // final path = XFile.path;
    // final bytes = await File(path).readAsBytes();
    // final img.Image image = img.decodeImage(bytes)!;
    // final XFile xfile = inputImage;
    final File file = File(inputImage.path);
    final RecognizedText recognizedText =
        await _textDetector.processImage(InputImage.fromFile(file));

    String text = recognizedText.text;
    for (TextBlock block in recognizedText.blocks) {
      result = block.text;
    }
    String translatedTextA = "";
    GoogleTranslator translator = new GoogleTranslator();
    translator
        .translate(result,
            from: CurrentLanguages.sourceLang.value.code,
            to: CurrentLanguages.outputLang.value.code)
        .then((translatedText) {
      print(translatedText.text);
      translatedTextA = translatedText.text;
      _showPopup(result, translatedText.text);
    });

    // _showPopup(result, translatedTextA);

    result += "\n\n";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          takeImageToTranslate();
        },
        label: const Text("Translate"),
        icon: Icon(Icons.translate),
        backgroundColor: Colors.blue[800],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
          child: Column(
        children: [
          _cameraController.value.isInitialized
              ? CameraPreview(_cameraController)
              : const Center(
                  child: CircularProgressIndicator(),
                ),
          // TextButton(
          //     style: ButtonStyle(
          //         backgroundColor: MaterialStateProperty.all(Colors.blue[600])),
          //     onPressed: () async {
          //       takeImageToTranslate();
          //     },
          //     child: Text(
          //       "Translate from ${CurrentLanguages.sourceLang.value.name} to ${CurrentLanguages.outputLang.value.name}",
          //       style: TextStyle(color: Colors.white),
          //     ))
        ],
      )),
    );
  }
}
