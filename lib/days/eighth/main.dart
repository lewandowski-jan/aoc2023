import 'package:aoc/utils.dart';

void main() async {
  final file = Utils.inputFile;
  final lines = await Utils.lines(file).toList();

  final firstResult = first(lines);
  print(firstResult);

  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  final directions = lines.first.split('');
  final nodes = Nodes.fromLines(lines);

  final start = nodes.firstWhere((n) => n.data.name == 'AAA');
  double stepCount = 0;
  final directionsCount = directions.length;
  Node current = start;
  while (current.data.name != 'ZZZ') {
    final directionIndex = stepCount.round() % directionsCount;
    final direction = directions[directionIndex];

    if (direction == 'L') {
      current = current.left!;
    } else {
      current = current.right!;
    }
    stepCount++;
  }

  return stepCount;
}

double second(List<String> lines) {
  final directions = lines.first.split('');
  final nodes = Nodes.fromLines(lines);

  final starts = nodes.where((n) => n.lastLetter == 'A').toList();
  List<double> stepCounts = [];
  final directionsCount = directions.length;

  for (int i = 0; i < starts.length; i++) {
    double stepCount = 0;
    Node current = starts[i];
    while (current.lastLetter != 'Z') {
      final directionIndex = stepCount.round() % directionsCount;
      final direction = directions[directionIndex];

      if (direction == 'L') {
        current = current.left!;
      } else {
        current = current.right!;
      }
      stepCount++;
    }

    stepCounts.add(stepCount);
  }

  return lcm(stepCounts);
}

double gcd(double a, double b) {
  if (b == 0) {
    return a;
  }

  return gcd(b, a % b);
}

double lcm(List<double> numbers) {
  final length = numbers.length;

  if (length == 0) {
    return -1;
  }

  double result = numbers.first;

  for (int i = 1; i < length; i++) {
    result = (numbers[i] * result) / gcd(numbers[i], result);
  }

  return result;
}

extension Nodes on List<Node> {
  static List<Node> fromLines(List<String> lines) {
    final parsedNodes = <NodeData>[];

    for (final line in lines.skip(2)) {
      final parts = line.split('=');
      final name = parts.first.trim();
      final nodeNames = parts.last
          .trim()
          .replaceFirst('(', '')
          .replaceFirst(')', '')
          .split(',');

      parsedNodes.add(
        NodeData(
          name: name,
          leftName: nodeNames.first.trim(),
          rightName: nodeNames.last.trim(),
        ),
      );
    }

    final nodes = parsedNodes.map((e) => Node(data: e)).toList();
    for (final node in nodes) {
      node.left = nodes.firstWhere((e) => e.data.name == node.data.leftName);
      node.right = nodes.firstWhere((e) => e.data.name == node.data.rightName);
    }

    return nodes;
  }
}

class Node {
  final NodeData data;
  Node? left;
  Node? right;

  Node({
    required this.data,
    this.left,
    this.right,
  });

  String get lastLetter => data.name.split('').last;

  @override
  String toString() => 'Node(data: $data, left: $left, right: $right)';
}

class NodeData {
  final String name;
  final String leftName;
  final String rightName;

  const NodeData({
    required this.name,
    required this.leftName,
    required this.rightName,
  });

  @override
  String toString() =>
      'Node(name: $name, leftName: $leftName, rightName: $rightName)';
}
