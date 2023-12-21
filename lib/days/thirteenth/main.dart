import 'package:aoc/utils.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();

  final firstResult = first(lines);
  print(firstResult);

  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  double sum = 0;
  final pattern = <String>[];
  for (final line in lines) {
    if (line.isEmpty) {
      sum += scorePattern(pattern);
      pattern.clear();
      continue;
    }

    pattern.add(line);
  }

  sum += scorePattern(pattern);

  return sum;
}

double second(List<String> lines) {
  double sum = 0;
  final pattern = <String>[];
  for (final line in lines) {
    if (line.isEmpty) {
      sum += scorePattern(pattern, diff: 1);
      pattern.clear();
      continue;
    }

    pattern.add(line);
  }

  sum += scorePattern(pattern, diff: 1);

  return sum;
}

double scorePattern(List<String> pattern, {int diff = 0}) {
  final rowIndex = getMirrorIndex(pattern, orDiff: diff);
  if (rowIndex != 0) {
    return rowIndex * 100;
  }

  final matrix = pattern.map((e) => e.split('')).toList();
  final columns = List.generate(matrix.first.length, (index) => "");
  for (int y = 0; y < matrix.length; y++) {
    for (int x = 0; x < matrix.first.length; x++) {
      columns[x] += matrix[y][x];
    }
  }

  final columnIndex = getMirrorIndex(columns, orDiff: diff);
  return columnIndex.toDouble();
}

int getMirrorIndex(List<String> lines, {int orDiff = 0}) {
  final tempLines = <String>[];
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    tempLines.add(line);

    final mirror = isMirror(tempLines, orDiff: orDiff);
    if (mirror) {
      return i ~/ 2 + 1;
    }
  }

  for (int i = 0; i < tempLines.length; i++) {
    final lines = tempLines.skip(i).toList();
    final mirror = isMirror(lines, orDiff: orDiff);
    if (mirror) {
      return lines.length ~/ 2 + i;
    }
  }

  return 0;
}

bool isMirror(List<String> lines, {int orDiff = 0}) {
  final length = lines.length;
  if (length.isOdd) {
    return false;
  }

  int diff = 0;
  for (int i = 0; i < length / 2; i++) {
    final line = lines[i];
    final mirror = lines[length - 1 - i];
    diff += countDiff(line, mirror);
  }

  return diff == orDiff;
}

int countDiff(String a, String b) {
  int diff = 0;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      diff++;
    }
  }

  return diff;
}
