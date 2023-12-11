import 'package:aoc/utils.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();
  final firstResult = first(lines);
  print(firstResult);
  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  final (matrix, emptyRows, emptyColumns) = lines.parse;

  final galaxies = <Position>[];

  for (int y = 0; y < matrix.length; y++) {
    for (int x = 0; x < matrix.first.length; x++) {
      final char = matrix[y][x];
      if (char == '#') {
        final xOffset = emptyColumns.where((e) => e < x).length;
        final yOffset = emptyRows.where((e) => e < y).length;

        galaxies.add(Position(x: x + xOffset, y: y + yOffset));
      }
    }
  }

  return galaxies.distanceSum;
}

double second(List<String> lines) {
  final (matrix, emptyRows, emptyColumns) = lines.parse;

  final galaxies = <Position>[];

  for (int y = 0; y < matrix.length; y++) {
    for (int x = 0; x < matrix.first.length; x++) {
      final char = matrix[y][x];
      if (char == '#') {
        final xOffset = emptyColumns.where((e) => e < x).length * (1000000 - 1);
        final yOffset = emptyRows.where((e) => e < y).length * (1000000 - 1);

        galaxies.add(Position(x: x + xOffset, y: y + yOffset));
      }
    }
  }

  return galaxies.distanceSum;
}

extension on List<String> {
  (List<List<String>> matrix, List<int> emptyRows, List<int> emptyColumns)
      get parse {
    final matrix = <List<String>>[];
    final emptyRows = <int>[];
    final emptyColumns = <int>[];

    for (int y = 0; y < this.length; y++) {
      final row = this[y].split('');
      if (!row.contains('#')) {
        emptyRows.add(y);
      }

      matrix.add(row);
    }

    for (int x = 0; x < matrix.first.length; x++) {
      final column = matrix.map((e) => e[x]).toList();

      if (!column.contains('#')) {
        emptyColumns.add(x);
      }
    }

    return (matrix, emptyRows, emptyColumns);
  }
}

extension on List<Position> {
  double get distanceSum {
    double sum = 0;

    for (int i = 0; i < this.length; i++) {
      final galaxy = this[i];
      final others = this.skip(i + 1);

      for (final other in others) {
        final distance = galaxy.distance(other);
        sum += distance;
      }
    }

    return sum;
  }
}

class Position {
  final int x;
  final int y;

  Position({
    required this.x,
    required this.y,
  });

  int distance(Position other) => (x - other.x).abs() + (y - other.y).abs();
}
