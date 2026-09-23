import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String> recognize(File image) async {
    if (Platform.isAndroid) {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final result = await recognizer.processImage(
          InputImage.fromFilePath(image.path),
        );
        return result.text;
      } finally {
        await recognizer.close();
      }
    }
    if (Platform.isLinux) {
      return _recognizeWithTesseract(image);
    }
    throw UnsupportedError(
      'Local OCR is currently supported on Android and Linux.',
    );
  }

  Future<String> _recognizeWithTesseract(File image) async {
    final outputDirectory =
        '${Directory.systemTemp.path}/charted-${DateTime.now().microsecondsSinceEpoch}';
    await Directory(outputDirectory).create();
    final outputBase = '$outputDirectory/result';
    try {
      final result = await Process.run(
        'tesseract',
        [image.path, outputBase, '-l', 'eng'],
      );
      if (result.exitCode != 0) {
        throw StateError(result.stderr.toString().trim());
      }
      return await File('$outputBase.txt').readAsString();
    } on ProcessException {
      throw StateError(
        'Tesseract is not available. Install the local tesseract-ocr package '
        'and try again.',
      );
    } finally {
      final directory = Directory(outputDirectory);
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  }
}
