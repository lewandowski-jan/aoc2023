import 'dart:io';
import 'package:aoc/utils.dart';

Future<void> main() async {
  final inputFile = Utils.inputFile;

  final firstResult = await FirstTask().solve(inputFile);
  print(firstResult);

  final secondResult = await SecondTask().solve(inputFile);
  print(secondResult);
}

abstract class Task {
  Future<double> solve(File file) async {
    final inputLines = Utils.lines(file);

    try {
      double sum = 0;

      await for (final line in inputLines) {
        sum += getLeftmostDigit(line) * 10 + getRightmostDigit(line);
      }

      return sum;
    } catch (e) {
      print('Error: $e');

      return -1;
    }
  }

  int getLeftmostDigit(String line);

  int getRightmostDigit(String line);
}

class FirstTask extends Task {
  @override
  int getLeftmostDigit(String line) {
    for (final code in line.codeUnits) {
      if (49 <= code && code <= 57) {
        return code - 48;
      }
    }

    throw Exception('no digit found');
  }

  @override
  int getRightmostDigit(String line) {
    for (final code in line.codeUnits.reversed) {
      if (49 <= code && code <= 57) {
        return code - 48;
      }
    }

    throw Exception('no digit found');
  }
}

class SecondTask extends Task {
  static const digitNames = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
  };

  @override
  int getLeftmostDigit(String line) {
    final lettersBuffer = <String>[];

    for (final code in line.codeUnits) {
      if (49 <= code && code <= 57) {
        return code - 48;
      }

      if (97 <= code && code <= 122) {
        lettersBuffer.add(String.fromCharCode(code));

        final word = lettersBuffer.join();
        for (final name in digitNames.keys) {
          if (word.endsWith(name)) {
            lettersBuffer.clear();
            return digitNames[name]!;
          }
        }
      }
    }

    throw Exception('no digit found');
  }

  @override
  int getRightmostDigit(String line) {
    final lettersBuffer = <String>[];

    for (final code in line.codeUnits.reversed) {
      if (49 <= code && code <= 57) {
        return code - 48;
      }

      if (97 <= code && code <= 122) {
        lettersBuffer.insert(0, String.fromCharCode(code));

        final word = lettersBuffer.join();
        for (final name in digitNames.keys) {
          if (word.startsWith(name)) {
            lettersBuffer.clear();
            return digitNames[name]!;
          }
        }
      }
    }

    throw Exception('no digit found');
  }
}
