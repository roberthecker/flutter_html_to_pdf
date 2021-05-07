import 'dart:io';

class FileUtils {
  static File copyAndDeleteOriginalFile(String generatedFilePath, String targetDirectory, String targetName) {
    final fileOriginal = File(generatedFilePath);
    final fileCopy = File('$targetDirectory/$targetName');
    fileCopy.writeAsBytesSync(File.fromUri(fileOriginal.uri).readAsBytesSync());
    fileOriginal.delete();
    return fileCopy;
  }
}
