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
}

class FirstTask extends Task {
  @override
  Future<double> solve(File file) async {
    final inputLines = Utils.lines(file);

    double scoreSum = 0;

    await for (final line in inputLines) {
      final card = Card.fromLine(line);
      final matchingCount = card.matchingCount;

      scoreSum += matchingCount == 0 ? 0 : pow(2, matchingCount - 1);
    }

    return scoreSum;
  }
}

class SecondTask extends Task {
  @override
  Future<double> solve(File file) async {
    final inputLines = Utils.lines(file);
    final cards = <Card>[];

    await for (final line in inputLines) {
      cards.add(Card.fromLine(line));
    }

    final cardsCount = List.filled(cards.length, 1).asMap().map(
          (key, value) => MapEntry(key + 1, value),
        );

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final cardCount = cardsCount[card.index] ?? 1;

      for (int j = 0; j < cardCount; j++) {
        final toCopy = card.matchingCount;

        for (int k = 1; k <= toCopy; k++) {
          cardsCount.update(
            i + 1 + k,
            (value) => value + 1,
          );
        }
      }
    }

    return cardsCount.values.reduce((sum, e) => sum + e).toDouble();
  }
}

class Card {
  final int index;
  final List<int> winning;
  final List<int> played;

  Card({
    required this.index,
    required this.winning,
    required this.played,
  });

  List<int> get matching =>
      played.where((played) => winning.contains(played)).toList();

  int get matchingCount => matching.length;

  static Card fromLine(String line) {
    late final int cardId;
    final winning = <int>[];
    final played = <int>[];

    final digits = <String>[];
    bool parsingPlayedNumbers = false;

    for (final code in line.codeUnits) {
      if (48 <= code && code <= 57) {
        digits.add(String.fromCharCode(code));
        continue;
      }

      // colon
      if (code == 58) {
        cardId = int.parse(digits.join());
        digits.clear();
        continue;
      }

      // whitespace
      if (code == 32 && digits.isNotEmpty) {
        if (parsingPlayedNumbers) {
          played.add(int.parse(digits.join()));
        } else {
          winning.add(int.parse(digits.join()));
        }

        digits.clear();
        continue;
      }

      // |
      if (code == 124) {
        parsingPlayedNumbers = true;
      }
    }

    if (digits.isNotEmpty) {
      if (parsingPlayedNumbers) {
        played.add(int.parse(digits.join()));
      } else {
        winning.add(int.parse(digits.join()));
      }
    }

    return Card(index: cardId, winning: winning, played: played);
  }
}
