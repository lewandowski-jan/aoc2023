import 'dart:io';

import 'package:aoc/utils.dart';

void main() async {
  final lines = await getLines(Utils.inputFile);

  final firstResult = firstTask(lines);
  print(firstResult);

  final secondResult = secondTask(lines);
  print(secondResult);
}

double firstTask(List<String> lines) {
  final hands = lines.map(Hand.fromLine).toList();
  hands.sort((l, r) => l.compareTo(r));

  double totalWinnings = 0;
  for (int i = 0; i < hands.length; i++) {
    totalWinnings += hands[i].bid * (i + 1);
  }

  return totalWinnings;
}

double secondTask(List<String> lines) {
  final hands = lines.map(Hand.fromLine).toList();
  hands.sort((l, r) => l.compareTo2(r));

  double totalWinnings = 0;
  for (int i = 0; i < hands.length; i++) {
    totalWinnings += hands[i].bid * (i + 1);
  }

  return totalWinnings;
}

class Hand {
  final List<String> faces;
  final int bid;

  const Hand({
    required this.faces,
    required this.bid,
  });

  int compareTo2(Hand other) {
    final value = typeValue2;
    final otherValue = other.typeValue2;

    if (value != otherValue) {
      return value > otherValue ? 1 : -1;
    }

    for (int i = 0; i < 5; i++) {
      final face = faces[i];
      final otherFace = other.faces[i];
      final allFacesLength = allFaces2.length;

      final value = allFacesLength - allFaces2.indexOf(face);
      final otherValue = allFacesLength - allFaces2.indexOf(otherFace);

      if (value != otherValue) {
        return value > otherValue ? 1 : -1;
      }
    }

    return 0;
  }

  int compareTo(Hand other) {
    final value = typeValue;
    final otherValue = other.typeValue;

    if (value != otherValue) {
      return value > otherValue ? 1 : -1;
    }

    for (int i = 0; i < 5; i++) {
      final face = faces[i];
      final otherFace = other.faces[i];
      final allFacesLength = allFaces.length;

      final value = allFacesLength - allFaces.indexOf(face);
      final otherValue = allFacesLength - allFaces.indexOf(otherFace);

      if (value != otherValue) {
        return value > otherValue ? 1 : -1;
      }
    }

    return 0;
  }

  int get typeValue2 {
    if (!faces.contains('J')) {
      return typeValue;
    }

    final faceSet = faces.toSet();
    final uniqueFaces = faceSet.length;

    if (uniqueFaces == 5) {
      return 2;
    }

    if (uniqueFaces == 4) {
      return 4;
    }

    if (uniqueFaces == 3) {
      final faceMap = faceSet.toList().asMap().map(
            (_, face) => MapEntry(face, faces.where((e) => e == face).length),
          );

      if (faceMap['J']! >= 2 || faceMap.values.any((e) => e == 3)) {
        return 6;
      }

      return 5;
    }

    if (uniqueFaces == 2 || uniqueFaces == 1) {
      return 7;
    }

    throw (Exception('unhandled case: ${faces}'));
  }

  int get typeValue {
    final faceSet = faces.toSet();
    final uniqueFaces = faceSet.length;

    if (uniqueFaces == 5) {
      return 1;
    }

    if (uniqueFaces == 4) {
      return 2;
    }

    if (uniqueFaces == 3) {
      final faceMap = faceSet.toList().asMap().map(
            (_, face) => MapEntry(face, faces.where((e) => e == face).length),
          );

      if (faceMap.values.any((count) => count == 3)) {
        return 4;
      }

      return 3;
    }

    if (uniqueFaces == 2) {
      final faceMap = faceSet.toList().asMap().map(
            (_, face) => MapEntry(face, faces.where((e) => e == face).length),
          );

      if (faceMap.values.any((count) => count == 4)) {
        return 6;
      }

      return 5;
    }

    if (uniqueFaces == 1) {
      return 7;
    }

    throw (Exception('unhandled case: ${faces}'));
  }

  static Hand fromLine(String line) {
    final parts = line.split(' ');
    final handFaces = parts.first;
    final bid = parts.last;

    return Hand(
      faces: handFaces.split(''),
      bid: int.parse(bid),
    );
  }

  @override
  String toString() => 'Hand(faces: $faces, bid: $bid)';
}

final List<String> allFaces = [
  'A',
  'K',
  'Q',
  'J',
  'T',
  '9',
  '8',
  '7',
  '6',
  '5',
  '4',
  '3',
  '2',
];

final List<String> allFaces2 = [
  'A',
  'K',
  'Q',
  'T',
  '9',
  '8',
  '7',
  '6',
  '5',
  '4',
  '3',
  '2',
  'J',
];

Future<List<String>> getLines(File file) async =>
    await Utils.lines(file).toList();
