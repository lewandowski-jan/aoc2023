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
    final seeds = <Seed>[];
    final maps = <Map>[];

    String mappingName = '';
    final mappings = <Mapping>[];
    await for (final line in lines) {
      if (seeds.isEmpty) {
        final numbers = line.split(':').last.trim().split(' ').map(int.parse);
        seeds.addAll(numbers);
        continue;
      }

      if (line.isEmpty) {
        continue;
      }

      if (line.contains('map')) {
        if (mappingName.isNotEmpty) {
          maps.add(Map(name: mappingName, mappings: List.of(mappings)));
          mappingName = '';
          mappings.clear();
        }

        mappingName = line.split(' ').first;

        continue;
      }

      mappings.add(Mapping.fromString(line));
    }

    maps.add(Map(name: mappingName, mappings: List.of(mappings)));

    return getLowestLocation(seeds, maps);
  }

  double getLowestLocation(List<Seed> seeds, List<Map> maps) {
    final locations = <int>[];

    final length = seeds.length;

    for (int i = 0; i < length; i++) {
      final seed = seeds[i];

      int current = seed;
      for (final map in maps) {
        current = map.map(current);
      }

      locations.add(current);
    }

    return locations.reduce((acc, val) => acc < val ? acc : val).toDouble();
  }
}

class SecondTask extends Task {
  @override
  Future<double> solve(File file) async {
    final lines = Utils.lines(file);
    var ranges = <Range>[];
    final maps = <Map>[];

    String mappingName = '';
    final mappings = <Mapping>[];
    await for (final line in lines) {
      if (ranges.isEmpty) {
        final numbers =
            line.split(':').last.trim().split(' ').map(int.parse).toList();

        for (int i = 0; i < numbers.length; i += 2) {
          final start = numbers[i];
          final range = numbers[i + 1];

          ranges.add(Range(start: start, end: start + range));
        }
        continue;
      }

      if (line.isEmpty) {
        continue;
      }

      if (line.contains('map')) {
        if (mappingName.isNotEmpty) {
          maps.add(Map(name: mappingName, mappings: List.of(mappings)));
          mappingName = '';
          mappings.clear();
        }

        mappingName = line.split(' ').first;

        continue;
      }

      mappings.add(Mapping.fromString(line));
    }

    maps.add(Map(name: mappingName, mappings: List.of(mappings)));

    var currentRanges = ranges;

    // walk
    for (final map in maps) {
      final newRanges = <Range>[];

      for (final range in currentRanges) {
        if (!map.mappings.any((m) => m.range.intersects(range))) {
          newRanges.add(range);
          continue;
        }

        for (final mapping in map.mappings) {
          if (range.intersects(mapping.range)) {
            newRanges.add(mapping.mapRange(range));
          }
        }
      }

      currentRanges = List.of(newRanges);
    }

    return currentRanges
        .map((r) => r.start)
        .reduce((acc, v) => acc < v ? acc : v)
        .toDouble();
  }
}

typedef Seed = int;

class Map {
  final String name;
  final List<Mapping> mappings;

  const Map({
    required this.name,
    required this.mappings,
  });

  @override
  String toString() => 'Map(name: $name)';

  int map(int value) {
    final values = mappings.map((mapping) => mapping.map(value)).toSet();

    if (values.length == 1) {
      return value;
    }

    return values.firstWhere((v) => v != value);
  }
}

class Mapping {
  final int shift;
  final Range range;

  Mapping._({
    required int destinationStart,
    required int sourceStart,
    required int length,
  })  : shift = destinationStart - sourceStart,
        range = Range(start: sourceStart, end: sourceStart + length);

  factory Mapping.fromString(String string) {
    final values = string.split(' ').map((e) => int.parse(e)).toList();

    return Mapping._(
      destinationStart: values[0],
      sourceStart: values[1],
      length: values[2],
    );
  }

  int map(int value) {
    if (range.start <= value && value <= range.end) {
      return value + shift;
    }

    return value;
  }

  Range mapRange(Range otherRange) {
    if (!otherRange.intersects(range)) {
      return otherRange;
    }

    return Range(
      start: otherRange.start.clamp(range.start, range.end) + shift,
      end: otherRange.end.clamp(range.start, range.end) + shift,
    );
  }

  @override
  String toString() => 'Mapping(shift: $shift, range: $range)';
}

class Range {
  final int start;
  final int end;

  const Range({
    required this.start,
    required this.end,
  });

  bool intersects(Range other) {
    return start < other.end && end > other.start ||
        end > other.start && start < other.end;
  }

  bool contains(int value) => start <= value && value <= end;

  @override
  String toString() => 'Range(start: $start, end: $end)';
}
