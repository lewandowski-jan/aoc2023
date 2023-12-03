import 'dart:io';
import 'dart:math';

import 'package:aoc/utils.dart';

Future<void> main() async {
  final inputFile = Utils.inputFile;

  final firstResult = await FirstTask().solve(inputFile);
  print(firstResult);

  final secondResult = await SecondTask().solve(inputFile);
  print(secondResult);
}

abstract class Task {
  Future<double> solve(File file);

  Future<(List<Number>, List<Symbol>)> getNumbersAndSymbols(
    Stream<String> lines,
  ) async {
    final numbers = <Number>[];
    final symbols = <Symbol>[];

    int lineIndex = 0;
    await for (final line in lines) {
      final (lineNumbers, lineSymbols) =
          _getLineNumbersAndSymbols(lineIndex, line);
      numbers.addAll(lineNumbers);
      symbols.addAll(lineSymbols);
      lineIndex++;
    }

    return (numbers, symbols);
  }

  (List<Number>, List<Symbol>) _getLineNumbersAndSymbols(
    int lineIndex,
    String line,
  ) {
    final numbers = <Number>[];
    final symbols = <Symbol>[];

    final digits = <String>[];
    final codeUnits = line.codeUnits;

    for (int i = 0; i < codeUnits.length; i++) {
      final code = codeUnits[i];

      if (48 <= code && code <= 57) {
        digits.add(String.fromCharCode(code));
        continue;
      }

      if (digits.isNotEmpty) {
        final value = int.parse(digits.join());

        numbers.add(
          Number(
            value: value,
            position: Position(
              x: i - digits.length,
              y: lineIndex,
            ),
          ),
        );
        digits.clear();
      }

      // dot
      if (code == 46) {
        continue;
      }

      symbols.add(
        Symbol(
          character: String.fromCharCode(code),
          position: Position(x: i, y: lineIndex),
        ),
      );
    }

    if (digits.isNotEmpty) {
      final value = int.parse(digits.join());

      numbers.add(
        Number(
          value: value,
          position: Position(
            x: line.length - digits.length,
            y: lineIndex,
          ),
        ),
      );
      digits.clear();
    }

    return (numbers, symbols);
  }
}

class FirstTask extends Task {
  @override
  Future<double> solve(File file) async {
    final lines = Utils.lines(file);
    final (numbers, symbols) = await getNumbersAndSymbols(lines);

    double partsSum = 0;

    for (final number in numbers) {
      bool isAdjacent = false;

      for (final symbol in symbols) {
        if (number.isAdjacent(symbol)) {
          isAdjacent = true;
          break;
        }
      }

      if (isAdjacent) {
        partsSum += number.value;
      }
    }

    return partsSum;
  }
}

class SecondTask extends Task {
  @override
  Future<double> solve(File inputFile) async {
    final lines = Utils.lines(inputFile);
    final (numbers, symbols) = await getNumbersAndSymbols(lines);

    double gearRatiosSum = 0;

    final asterisks = symbols.where((symbol) => symbol.character == '*');
    for (final asterisk in asterisks) {
      final adjacentNumbers = <Number>[];
      for (final number in numbers) {
        if (number.isAdjacent(asterisk)) {
          adjacentNumbers.add(number);
        }
      }

      if (adjacentNumbers.length == 2) {
        gearRatiosSum +=
            adjacentNumbers.first.value * adjacentNumbers.last.value;
      }
    }

    return gearRatiosSum;
  }
}

class Number extends Positioned {
  final int value;

  Number({
    required this.value,
    required Position position,
  }) : super(x: position.x, y: position.y);

  List<int> get digits =>
      value.toString().split('').map((e) => int.parse(e)).toList();

  int get length => digits.length;

  List<Position> get digitPositions => List.generate(
        length,
        (index) => Position(
          x: x + index,
          y: y,
        ),
      );

  @override
  double distance(Positioned other) {
    final distances = <double>[];
    for (final digit in digitPositions) {
      distances.add(digit.distance(other));
    }

    return distances.reduce((min, distance) => min < distance ? min : distance);
  }
}

class Symbol extends Positioned {
  final String character;

  Symbol({
    required this.character,
    required Position position,
  }) : super(x: position.x, y: position.y);
}

class Position extends Positioned {
  Position({
    required super.x,
    required super.y,
  });
}

abstract class Positioned {
  final int x;
  final int y;

  const Positioned({
    required this.x,
    required this.y,
  });

  double distance(Positioned other) => sqrt(
        pow(x - other.x, 2) + pow(y - other.y, 2),
      );

  bool isAdjacent(Positioned other) {
    return distance(other) < 2;
  }
}
