import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/file_utils.dart';

/// HTML to PDF Converter
class FlutterHtmlToPdf {
  static const MethodChannel _channel =
      const MethodChannel('flutter_html_to_pdf');

  /// Creates a PDF document by interpreting the given [htmlContent].
  ///
  /// The file is placed in the directory [targetDirectory] and is named
  /// [targetName].
  static Future<File> convertFromHtmlContent({
    required String htmlContent,
    required String targetDirectory,
    required String targetName,
  }) async {
    final temporaryCreatedHtmlFile =
        await File('$targetDirectory/$targetName.html')
            .writeAsString(htmlContent);
    final generatedPdfFilePath =
        await _convertFromHtmlFilePath(temporaryCreatedHtmlFile.path);
    final generatedPdfFile = FileUtils.copyAndDeleteOriginalFile(
        generatedPdfFilePath, targetDirectory, targetName);
    temporaryCreatedHtmlFile.delete();

    return generatedPdfFile;
  }

  /// Creates a PDF file by reading the HTML file [htmlFile].
  ///
  /// The file is placed in the directory [targetDirectory] and is named
  /// [targetName].
  static Future<File> convertFromHtmlFile({
    required File htmlFile,
    required String targetDirectory,
    required String targetName,
  }) async {
    final generatedPdfFilePath = await _convertFromHtmlFilePath(htmlFile.path);
    final generatedPdfFile = FileUtils.copyAndDeleteOriginalFile(
        generatedPdfFilePath, targetDirectory, targetName);

    return generatedPdfFile;
  }

  /// Invokes the channel to do the PDF creation on the respective platform.
  static Future<String> _convertFromHtmlFilePath(
    String htmlFilePath, {
    bool portraitOrientation = true,
  }) async {
    final result = await _channel.invokeMethod(
      'convertHtmlToPdf',
      <String, dynamic>{
        'htmlFilePath': htmlFilePath,
        'portraitOrientation': portraitOrientation,
      },
    );
    return result as String;
  }
}
