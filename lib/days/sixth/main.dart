import 'dart:io';

import 'package:aoc/utils.dart';

void main() async {
  final file = Utils.inputFile;

  final firstResult = await FirstTask().solve(file);
  print(firstResult);

  final secondResult = await SecondTask().solve(file);
  print(secondResult);
}

abstract class Task {
  Future<double> solve(File file);
}

class FirstTask extends Task {
  @override
  Future<double> solve(File file) async {
    final lines = Utils.lines(file);

    final times = <int>[];
    final distances = <int>[];
    await for (final line in lines) {
      final numbers = line
          .split(':')
          .last
          .trim()
          .split(' ')
          .where((e) => e.isNotEmpty)
          .map((e) => int.parse(e))
          .toList();

      if (times.isEmpty) {
        times.addAll(List.of(numbers));
        continue;
      }

      distances.addAll(numbers);
    }

    final races = <Race>[];
    for (int i = 0; i < times.length; i++) {
      races.add((times[i], distances[i]));
    }

    final result = races.map((r) => r.waysToBreakRecord).reduce(
          (acc, v) => acc * v,
        );

    return result.toDouble();
  }
}

class SecondTask extends Task {
  @override
  Future<double> solve(File file) async {
    final lines = Utils.lines(file);

    final times = <int>[];
    final distances = <int>[];
    await for (final line in lines) {
      final number = line.split(':').last.trim().replaceAll(' ', '');

      if (times.isEmpty) {
        times.add(int.parse(number));
        continue;
      }

      distances.add(int.parse(number));
    }

    final races = <Race>[];
    for (int i = 0; i < times.length; i++) {
      races.add((times[i], distances[i]));
    }

    final result = races.map((r) => r.waysToBreakRecord).reduce(
          (acc, v) => acc * v,
        );

    return result.toDouble();
  }
}

typedef Race = (int time, int recordDistance);

extension on Race {
  int get time => this.$1;
  int get recordDistance => this.$2;

  int get waysToBreakRecord {
    int ways = 0;

    for (int charching = 0; charching < time; charching++) {
      final distance = (time - charching) * charching;

      if (distance > recordDistance) {
        ways++;
      }
    }

    return ways;
  }
}
