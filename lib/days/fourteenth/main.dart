import 'package:aoc/utils.dart';
import 'package:collection/collection.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();

  final firstResult = first(lines);
  print(firstResult);

  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  final length = lines.length;
  final rowLength = lines.first.length;

  final columns = List.generate(length, (_) => "");
  for (final line in lines) {
    for (int i = 0; i < rowLength; i++) {
      columns[i] += line[i];
    }
  }

  return columns.map(shift).fold(0, (acc, e) => acc + countWeight(e));
}

typedef Cache = Map<String, String>;
final SHIFT_CACHE = Cache();
final CYCLE_CACHE = Cache();
final TEN_THOUSAND_CACHE = Cache();

double second(List<String> lines) {
  final length = lines.length;
  final rowLength = lines.first.length;

  Direction direction = Direction.N;

  Iterable<String> currentLines = lines;

  for (int a = 0; a < 100000; a++) {
    final tenThousandKey = currentLines.join('-');
    if (TEN_THOUSAND_CACHE.containsKey(tenThousandKey)) {
      currentLines = TEN_THOUSAND_CACHE[tenThousandKey]!.split('-');
      continue;
    }

    for (int b = 0; b < 10000; b++) {
      final cycleKey = currentLines.join('-');
      if (CYCLE_CACHE.containsKey(cycleKey)) {
        currentLines = CYCLE_CACHE[cycleKey]!.split('-');
        continue;
      }

      for (int j = 0; j < 4; j++) {
        switch (direction) {
          case Direction.N || Direction.S:
            final columns = List.generate(length, (_) => "");
            for (final row in currentLines) {
              for (int i = 0; i < rowLength; i++) {
                columns[i] += row[i];
              }
            }
            final toFront = direction == Direction.N;
            currentLines = columns.map((col) => shift(col, toFront)).toList();
          case Direction.E || Direction.W:
            final rows = List.generate(length, (_) => "");
            for (final col in currentLines) {
              for (int i = 0; i < length; i++) {
                rows[i] += col[i];
              }
            }
            final toFront = direction == Direction.W;
            currentLines = rows.map((row) => shift(row, toFront)).toList();
        }

        direction = direction.next;
      }

      CYCLE_CACHE[cycleKey] = currentLines.join('-');
    }

    TEN_THOUSAND_CACHE[tenThousandKey] = currentLines.join('-');
  }

  final columns = List.generate(length, (_) => "");
  for (final row in currentLines) {
    for (int i = 0; i < rowLength; i++) {
      columns[i] += row[i];
    }
  }

  return columns.fold(0, (acc, e) => acc + countWeight(e));
}

enum Direction { N, W, S, E }

extension on Direction {
  Direction get next => switch (this) {
        Direction.N => Direction.W,
        Direction.W => Direction.S,
        Direction.S => Direction.E,
        Direction.E => Direction.N,
      };
}

int countWeight(String line) {
  final length = line.length;
  return line.split('').foldIndexed(
        0,
        (i, acc, e) => acc + (e == 'O' ? length - i : 0),
      );
}

String shift(String line, [bool toFront = true]) {
  final key = line + '-' + toFront.toString();
  if (SHIFT_CACHE.containsKey(key)) {
    return SHIFT_CACHE[key]!;
  }

  String result = "";

  int tempRockCount = 0;
  int tempDotCount = 0;
  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    switch (char) {
      case '#':
        if (toFront) {
          result += 'O' * tempRockCount + '.' * tempDotCount + '#';
        } else {
          result += '.' * tempDotCount + 'O' * tempRockCount + '#';
        }
        tempRockCount = 0;
        tempDotCount = 0;
      case 'O':
        tempRockCount++;
      case _:
        tempDotCount++;
    }
  }

  if (toFront) {
    result += 'O' * tempRockCount + '.' * tempDotCount;
  } else {
    result += '.' * tempDotCount + 'O' * tempRockCount;
  }

  SHIFT_CACHE[key] = result;

  return result;
}
