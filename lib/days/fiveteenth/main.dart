import 'package:aoc/utils.dart';
import 'package:collection/collection.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();

  final firstResult = first(lines.first);
  print(firstResult);

  final secondResult = second(lines.first);
  print(secondResult);
}

double first(String line) {
  double sum = 0;
  final length = line.length;

  String temp = "";
  for (int i = 0; i < length; i++) {
    final char = line[i];

    if (char == ',') {
      sum += hash(temp);
      temp = "";
      continue;
    }

    temp += char;
  }

  return sum + hash(temp);
}

double second(String line) {
  final config = LenseConfig();
  final length = line.length;

  String temp = "";
  for (int i = 0; i < length; i++) {
    final char = line[i];

    if (char == ',') {
      config.execute(Instruction.fromString(temp));
      temp = "";
      continue;
    }

    temp += char;
  }

  config.execute(Instruction.fromString(temp));

  return config.entries.fold(0, (acc, box) {
    final boxNumber = box.key + 1;

    return acc +
        box.value.foldIndexed(
          0,
          (index, sum, lens) => sum + boxNumber * (index + 1) * lens.focus,
        );
  });
}

typedef LenseConfig = Map<int, Iterable<Lense>>;

extension on LenseConfig {
  void execute(Instruction instruction) {
    this.update(
      instruction.box,
      (lenses) {
        if (instruction.op == '=') {
          if (lenses.map((l) => l.label).contains(instruction.lens.label)) {
            return lenses.map(
              (l) => l.label == instruction.lens.label ? instruction.lens : l,
            );
          }

          return [...lenses, instruction.lens];
        }

        return lenses.where((lens) => lens.label != instruction.lens.label);
      },
      ifAbsent: () {
        return [instruction.lens];
      },
    );
  }
}

class Lense {
  final String label;
  final int focus;

  const Lense({
    required this.label,
    required this.focus,
  });

  @override
  String toString() => '[$label $focus]';
}

class Instruction {
  final int box;
  final String op;
  final Lense lens;

  const Instruction._({
    required this.box,
    required this.op,
    required this.lens,
  });

  factory Instruction.fromString(String str) {
    String label = "";
    String op = "";
    int? focus;

    for (final char in str.split('')) {
      if (char == '=' || char == '-') {
        op = char;
        continue;
      }

      if (op.isNotEmpty) {
        focus = int.parse(char);
        continue;
      }

      label += char;
    }

    return Instruction._(
      box: hash(label),
      op: op,
      lens: Lense(label: label, focus: focus ?? 0),
    );
  }
}

int hash(String str) =>
    str.codeUnits.fold(0, (acc, e) => ((acc + e) * 17) % 256);
