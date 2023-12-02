import 'dart:convert';
import 'dart:io';

abstract class Utils {
  static File get inputFile {
    final pathSegments = Platform.script.pathSegments;
    final path = pathSegments.sublist(0, pathSegments.length - 1).join('/');
    return File('/' + path + '/input.txt');
  }

  static Stream<String> lines(File file) {
    return file.openRead().transform(utf8.decoder).transform(LineSplitter());
  }
}
