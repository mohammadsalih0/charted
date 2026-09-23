import 'dart:io';

import 'package:pdf/widgets.dart' as pw;

Future<void> main(List<String> arguments) async {
  final options = _parseArguments(arguments);
  if (options.help || options.input == null) {
    _printUsage();
    if (options.help) return;
    exitCode = 64;
    return;
  }

  final input = File(options.input!);
  if (!await input.exists()) {
    stderr.writeln('Input file does not exist: ${input.path}');
    exitCode = 66;
    return;
  }

  final output = File(
    options.output ??
        '${input.parent.path}/${_withoutExtension(input.uri.pathSegments.last)}.pdf',
  );
  final temporaryDirectory = await Directory.systemTemp.createTemp('charted-');
  final outputBase = '${temporaryDirectory.path}/ocr';
  try {
    final result = await Process.run(
      'tesseract',
      [input.path, outputBase, '-l', options.language],
    );
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr.toString().trim());
      exitCode = 1;
      return;
    }
    final text = await File('$outputBase.txt').readAsString();
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Charted document'),
          pw.Paragraph(text: text.trim().isEmpty ? 'No text detected.' : text),
        ],
      ),
    );
    await output.writeAsBytes(await document.save());
    stdout.writeln('PDF written to ${output.absolute.path}');
  } on ProcessException {
    stderr.writeln(
      'Tesseract is not available. Install tesseract-ocr and try again.',
    );
    exitCode = 69;
  } finally {
    await temporaryDirectory.delete(recursive: true);
  }
}

class _Options {
  const _Options({
    this.help = false,
    this.input,
    this.output,
    this.language = 'eng',
  });

  final bool help;
  final String? input;
  final String? output;
  final String language;
}

_Options _parseArguments(List<String> arguments) {
  String? input;
  String? output;
  var language = 'eng';
  var help = false;
  for (var index = 0; index < arguments.length; index++) {
    switch (arguments[index]) {
      case '-h':
      case '--help':
        help = true;
      case '-i':
      case '--input':
        if (index + 1 < arguments.length) input = arguments[++index];
      case '-o':
      case '--output':
        if (index + 1 < arguments.length) output = arguments[++index];
      case '-l':
      case '--language':
        if (index + 1 < arguments.length) language = arguments[++index];
    }
  }
  return _Options(
    help: help,
    input: input,
    output: output,
    language: language,
  );
}

void _printUsage() {
  stdout.writeln('Charted CLI - local OCR to searchable PDF');
  stdout.writeln('');
  stdout.writeln('Usage: flutter pub run bin/charted.dart [options]');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln('  -i, --input FILE       Image to recognize (required)');
  stdout.writeln('  -o, --output FILE      PDF destination');
  stdout.writeln('  -l, --language LANG    Tesseract language(s), default: eng');
  stdout.writeln('  -h, --help             Show this help');
}

String _withoutExtension(String filename) {
  final separator = filename.lastIndexOf('.');
  return separator <= 0 ? filename : filename.substring(0, separator);
}
