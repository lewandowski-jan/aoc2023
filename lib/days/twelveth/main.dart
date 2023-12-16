import 'package:aoc/utils.dart';

void main() async {
  final lines = await Utils.lines(Utils.inputFile).toList();

  final firstResult = first(lines);
  print(firstResult);

  final secondResult = second(lines);
  print(secondResult);
}

double first(List<String> lines) {
  double sum = 0;

  for (final line in lines) {
    final [_config, _groups] = line.split(' ');
    final config = '.' + _config + '.';
    final groups = _groups.split(',').map(int.parse);
    sum += countConfigurations(config, groups);
  }

  return sum;
}

typedef Cache = Map<String, int>;
final cache = Cache();

double second(List<String> lines) {
  cache.clear();
  double sum = 0;

  for (final line in lines) {
    final [_config, _groups] = line.split(' ');
    final config = '.' + List.generate(5, (_) => _config).join('?') + '.';
    final groups = List.generate(5, (_) => _groups.split(',').map(int.parse))
        .expand((e) => e);

    sum += countConfigurations(config, groups);
  }

  return sum;
}

int countConfigurations(String config, Iterable<int> groups) {
  final key = config + '-' + groups.join(',');
  if (cache.containsKey(key)) {
    return cache[key]!;
  }

  if (groups.isEmpty) {
    return config.contains('#') ? 0 : 1;
  }

  int count = 0;
  for (int end = 0; end < config.length; end++) {
    final start = end - (groups.first - 1);

    if (matches(config, start, end)) {
      count += countConfigurations(config.substring(end + 1), groups.skip(1));
    }
  }

  cache[key] = count;
  return count;
}

bool matches(String config, int start, int end) {
  if (start - 1 < 0 || end + 1 >= config.length) return false;

  if (config[start - 1] == "#" || config[end + 1] == '#') return false;

  if (config.substring(0, start).contains('#')) return false;

  if (config.substring(start, end + 1).contains('.')) return false;

  return true;
}
