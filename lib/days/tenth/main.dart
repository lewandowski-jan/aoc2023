import 'dart:math';

import 'package:aoc/utils.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();

  final firstResult = first(lines);
  print(firstResult);

  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  final height = lines.length;
  final width = lines.first.length;

  final (pipes, start) = Pipe.parsePipeMatrix(lines);

  Pipe current = start;
  Pipe? previous;
  int stepCount = 0;

  while (current.type != 'S' || previous == null) {
    final neighbors = current.position.getNeighbors(width, height);
    for (final p in neighbors) {
      final next = pipes[p.y][p.x];
      final fits = current.fits(next);
      final notPrevious = previous == null
          ? true
          : previous.x != next.x || previous.y != next.y;

      if (fits && notPrevious) {
        previous = current;
        current = next;
        break;
      }
    }
    stepCount++;
  }

  return (stepCount / 2).ceilToDouble();
}

double second(List<String> lines) {
  final height = lines.length;
  final width = lines.first.length;

  final (pipes, start) = Pipe.parsePipeMatrix(lines);

  Pipe current = start;
  Pipe? previous;

  final path = <Position>[current.position];

  while (current.type != 'S' || previous == null) {
    final neighbors = current.position.getNeighbors(width, height);
    for (final p in neighbors) {
      final next = pipes[p.y][p.x];
      final fits = current.fits(next);
      final notPrevious = previous == null
          ? true
          : previous.x != next.x || previous.y != next.y;

      if (fits && notPrevious) {
        previous = current;
        current = next;
        break;
      }
    }
    path.add(current.position);
  }

  double sum = 0;
  path.reduce((l, r) {
    sum += l.x * r.y - r.x * l.y;

    return r;
  });
  final area = 0.5 * sum.abs();
  final pointCount = path.length;

  return area - ((pointCount - 1) / 2).ceil() + 1;
}

class Pipe {
  final Position position;
  final String type;

  const Pipe({required this.type, required this.position});

  factory Pipe.empty() => Pipe(type: '', position: (0, 0));

  int get x => position.x;
  int get y => position.y;

  bool fits(Pipe other) {
    if (!position.isAdjacent(other.position)) {
      return false;
    }

    final direction = position.directionTo(other.position);

    final otherType = other.type;
    return switch (direction) {
      Direction.N => ['S', '|', 'L', 'J'].contains(type) &&
          ['S', '|', '7', 'F'].contains(otherType),
      Direction.E => ['S', '-', 'L', 'F'].contains(type) &&
          ['S', '-', '7', 'J'].contains(otherType),
      Direction.S => ['S', '|', '7', 'F'].contains(type) &&
          ['S', '|', 'L', 'J'].contains(otherType),
      Direction.W => ['S', '-', '7', 'J'].contains(type) &&
          ['S', '-', 'L', 'F'].contains(otherType),
    };
  }

  static (List<List<Pipe>>, Pipe start) parsePipeMatrix(List<String> lines) {
    final height = lines.length;
    final width = lines.first.length;

    final pipes = List.generate(
      height,
      (_) => List.generate(width, (_) => Pipe.empty()),
    );
    late final Pipe start;

    for (int y = 0; y < height; y++) {
      final line = lines[y];
      final types = line.split('');
      for (int x = 0; x < width; x++) {
        final type = types[x];
        final pipe = Pipe(type: type, position: PositionX.from(x: x, y: y));
        pipes[y][x] = pipe;

        if (pipe.type == 'S') {
          start = pipe;
        }
      }
    }

    return (pipes, start);
  }
}

enum Direction { N, E, S, W }

typedef Position = (int, int);

extension PositionX on Position {
  static Position from({required int x, required int y}) => (x, y);

  int get x => this.$1;
  int get y => this.$2;

  List<Position> getNeighbors(int width, int height) {
    final positions = <Position>[];
    final north = (x, y - 1);
    if (north.inside(width, height)) {
      positions.add(north);
    }
    final east = (x + 1, y);
    if (east.inside(width, height)) {
      positions.add(east);
    }
    final south = (x, y + 1);
    if (south.inside(width, height)) {
      positions.add(south);
    }
    final west = (x - 1, y);
    if (west.inside(width, height)) {
      positions.add(west);
    }

    return positions;
  }

  bool inside(int width, int height) =>
      0 <= x && x < width && 0 <= y && y < height;

  Direction directionTo(Position other) {
    final angle = angleTo(other);

    if (angle == 0 || angle == pi * 2) return Direction.E;
    if (angle == pi * 0.5) return Direction.N;
    if (angle == pi) return Direction.W;
    if (angle == pi * 1.5) return Direction.S;

    throw Exception('incorrect angle: $angle');
  }

  double angleTo(Position other) {
    final vector = other - this;
    final unit = (1, 0);

    final angle = acos(vector.dot(unit) / (vector.module * unit.module));

    if (vector.y > 0) {
      return pi + angle;
    }

    return angle;
  }

  double get module => sqrt(pow(x, 2) + pow(y, 2));

  int dot(Position other) => x * other.x + y * other.y;

  Position operator -(Position other) => (x - other.x, y - other.y);

  bool isAdjacent(Position other) => distance(other) == 1;

  double distance(Position other) {
    return sqrt(pow(other.x - x, 2) + pow(other.y - y, 2));
  }
}
