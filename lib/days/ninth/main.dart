import 'package:aoc/utils.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();

  final firstResult = first(lines);
  print(firstResult);

  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  final extrapolatedValues = <double>[];
  for (final line in lines) {
    final numbers = line.split(' ').map((e) => double.parse(e)).toList();
    final sequences = [numbers];

    while (true) {
      final diffs = <double>[];
      sequences.last.reduce((l, r) {
        diffs.add(r - l);
        return r;
      });

      sequences.add(diffs);

      if (diffs.every((e) => e == 0)) {
        break;
      }
    }
    final sequencesLength = sequences.length;
    for (int i = 1; i < sequencesLength; i++) {
      final diff = sequences[sequencesLength - i - 1].last;
      final value = sequences[sequencesLength - i].last + diff;
      sequences[sequencesLength - i - 1].add(value);
    }

    extrapolatedValues.add(sequences.first.last);
  }

  return extrapolatedValues.reduce((acc, v) => acc + v);
}

double second(List<String> lines) {
  final extrapolatedValues = <double>[];
  for (final line in lines) {
    final numbers = line.split(' ').map((e) => double.parse(e)).toList();
    final sequences = [numbers];

    while (true) {
      final diffs = <double>[];
      sequences.last.reduce((l, r) {
        diffs.add(r - l);
        return r;
      });

      sequences.add(diffs);

      if (diffs.every((e) => e == 0)) {
        break;
      }
    }

    final sequencesLength = sequences.length;
    for (int i = 1; i < sequencesLength; i++) {
      final diff = sequences[sequencesLength - i - 1].first;
      final value = diff - sequences[sequencesLength - i].first;
      sequences[sequencesLength - i - 1].insert(0, value);
    }

    extrapolatedValues.add(sequences.first.first);
  }

  return extrapolatedValues.reduce((acc, v) => acc + v);
}
