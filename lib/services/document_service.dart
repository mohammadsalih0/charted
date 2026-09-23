import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'ocr_service.dart';

class DocumentService {
  final OcrService _ocr = OcrService();

  Future<String> recognizeText(File image) => _ocr.recognize(image);

  Future<String> createPdf(String text) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Charted document'),
          pw.Paragraph(text: text.trim().isEmpty ? 'No text detected.' : text),
        ],
      ),
    );
    final bytes = await document.save();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (Platform.isAndroid) {
      final uri = await FilePicker.saveFile(
        fileName: 'charted-$timestamp.pdf',
        bytes: Uint8List.fromList(bytes),
        mimeType: 'application/pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Save Charted PDF in Documents',
      );
      if (uri == null) {
        throw StateError('PDF export was canceled.');
      }
      return uri.toString();
    }
    final directory = await getApplicationDocumentsDirectory();
    await directory.create(recursive: true);
    final file = File('${directory.path}/charted-$timestamp.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
