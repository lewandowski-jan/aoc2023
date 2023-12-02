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
  Future<double> solve(File file);
}

class FirstTask extends Task {
  @override
  Future<double> solve(File file) async {
    final inputLines = Utils.lines(file);

    double possibleGameIdsSum = 0;

    final Hand maxPossibleHand = {
      Cube.red: 12,
      Cube.green: 13,
      Cube.blue: 14,
    };

    await for (final line in inputLines) {
      final game = Game.fromLine(line);
      if (game.isPossible(maxPossibleHand: maxPossibleHand)) {
        possibleGameIdsSum += game.id;
      }
    }

    return possibleGameIdsSum;
  }
}

class SecondTask extends Task {
  @override
  Future<double> solve(File file) async {
    final inputLines = Utils.lines(file);

    double powerSum = 0;

    await for (final line in inputLines) {
      powerSum += Game.fromLine(line).power;
    }

    return powerSum;
  }
}

enum Cube {
  red,
  green,
  blue;

  const Cube();

  static Cube fromString(String string) {
    return switch (string) {
      'red' => Cube.red,
      'green' => Cube.green,
      'blue' => Cube.blue,
      _ => throw Exception('unknown cube color: $string'),
    };
  }
}

typedef Hand = Map<Cube, int>;

extension HandX on Hand {
  bool isPossible({
    required Hand maxPossibleHand,
  }) {
    for (final MapEntry(key: cube, value: count) in entries) {
      if (maxPossibleHand[cube]! < count) {
        return false;
      }
    }

    return true;
  }

  double get power => values.reduce((power, value) => power * value).toDouble();

  static Map<Cube, int> fromString(String string) {
    final Hand hand = {};
    final digits = <String>[];
    final letters = <String>[];

    for (final code in string.codeUnits) {
      if (48 <= code && code <= 57) {
        digits.add(String.fromCharCode(code));
      }

      if (97 <= code && code <= 122) {
        letters.add(String.fromCharCode(code));
      }

      // comma
      if (code == 44) {
        final name = letters.join();
        final count = digits.join();
        hand[Cube.fromString(name)] = int.parse(count);
        letters.clear();
        digits.clear();
      }
    }

    final name = letters.join();
    final count = digits.join();
    hand[Cube.fromString(name)] = int.parse(count);

    return hand;
  }
}

class Game {
  final int id;
  final List<Hand> hands;

  const Game({
    required this.id,
    required this.hands,
  });

  bool isPossible({required Hand maxPossibleHand}) => hands.every(
        (hand) => hand.isPossible(maxPossibleHand: maxPossibleHand),
      );

  double get power {
    final Hand minPossibleHand = {
      Cube.red: 0,
      Cube.green: 0,
      Cube.blue: 0,
    };

    for (final hand in hands) {
      for (final MapEntry(key: key, value: value) in hand.entries) {
        if (minPossibleHand[key]! < value) {
          minPossibleHand[key] = value;
        }
      }
    }

    return minPossibleHand.power;
  }

  static Game fromLine(String line) {
    late final int gameId;
    late final int colonIndex;
    final idDigits = <String>[];
    final codeUnits = line.codeUnits;
    for (int i = 0; i < line.length; i++) {
      final code = codeUnits[i];

      if (48 <= code && code <= 57) {
        idDigits.add(String.fromCharCode(code));
      }

      // colon
      if (code == 58) {
        gameId = int.parse(idDigits.join());
        colonIndex = i;
        break;
      }
    }

    return Game(
      id: gameId,
      hands: line
          .substring(colonIndex)
          .split(';')
          .map((string) => HandX.fromString(string.trim()))
          .toList(),
    );
  }
}
